-- Migration: Create authors table
-- Separates author metadata from user profiles, supporting both staff writers
-- and external contributors without user accounts.
-- Also defines the update_author_article_count() trigger function (covers task 3.2).
-- Requirements: Req 3

-- ============================================================
-- authors table
-- ============================================================
create table public.authors (
  id uuid primary key default gen_random_uuid(),

  -- Req 3.7: profile_id is nullable to support contributors without accounts
  profile_id uuid references public.profiles(id) on delete set null,

  -- Req 3.3: name is required
  name text not null,

  -- Req 3.2: slug must be globally unique
  slug text not null,

  -- Req 3.4: bio is max 500 characters when provided
  bio text,

  avatar_url  text,
  email       text,
  twitter_handle text,
  linkedin_url   text,
  website_url    text,

  is_staff  boolean not null default false,
  is_active boolean not null default true,

  -- Req 3.6: auto-maintained via trigger below
  article_count integer not null default 0,

  "createdAt" timestamp with time zone not null default now(),
  "updatedAt" timestamp with time zone not null default now(),

  -- Req 3.2: globally unique slug
  constraint authors_slug_unique unique (slug),

  -- Req 3.3: name max 100 characters
  constraint authors_name_length check (char_length(name) <= 100),

  -- Req 3.4: bio max 500 characters when provided
  constraint authors_bio_length check (
    bio is null or char_length(bio) <= 500
  ),

  -- Req 3.5: email must be valid format when provided
  constraint authors_email_format check (
    email is null or
    email ~* '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$'
  ),

  -- article_count must be non-negative
  constraint authors_article_count_nonneg check (article_count >= 0)
);

comment on table  public.authors                   is 'Author profiles, decoupled from auth user accounts.';
comment on column public.authors.slug              is 'Globally unique, URL-friendly identifier for author pages.';
comment on column public.authors.profile_id        is 'Optional FK to profiles.id; NULL for contributors without accounts.';
comment on column public.authors.article_count     is 'Denormalised count of published articles; maintained by trigger.';
comment on column public.authors.bio               is 'Short biography; max 500 characters.';
comment on column public.authors.email             is 'Public contact email; validated via CHECK constraint.';

-- ============================================================
-- Indexes for common access patterns
-- ============================================================
create index if not exists idx_authors_slug
  on public.authors (slug);

create index if not exists idx_authors_profile_id
  on public.authors (profile_id);

-- ============================================================
-- Row Level Security
-- ============================================================
alter table public.authors enable row level security;

-- Public can read active authors
create policy "Allow public read access to active authors"
  on public.authors for select
  using (is_active = true);

-- Only admin/dev can manage authors
create policy "Allow admin and dev to insert authors"
  on public.authors for insert
  with check (public.is_admin_or_dev());

create policy "Allow admin and dev to update authors"
  on public.authors for update
  using (public.is_admin_or_dev());

create policy "Allow admin and dev to delete authors"
  on public.authors for delete
  using (public.is_admin_or_dev());

-- ============================================================
-- Trigger: auto-update "updatedAt" on row change
-- ============================================================
create or replace function public.set_authors_updated_at()
returns trigger as $$
begin
  new."updatedAt" = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_authors_updated_at
  before update on public.authors
  for each row execute function public.set_authors_updated_at();

-- ============================================================
-- Trigger function: maintain authors.article_count
-- Req 3.6: When an article with author_id is published or
--          unpublished, automatically update article_count.
--
-- Logic:
--   INSERT with status='published'         → count +1
--   UPDATE old='published' → new≠'published' → count -1
--   UPDATE old≠'published' → new='published' → count +1
--   DELETE with status='published'         → count -1
--
-- The trigger is attached to articles in migration
-- 20260610400000_enhance_articles_table.sql AFTER the
-- author_id column is added to that table.  The function is
-- defined here so it is available as soon as the authors table
-- exists.
-- ============================================================
create or replace function public.update_author_article_count()
returns trigger as $$
begin
  if (TG_OP = 'INSERT') then
    -- New article published with a known author
    if new.status = 'published' and new.author_id is not null then
      update public.authors
        set article_count = article_count + 1
        where id = new.author_id;
    end if;

  elsif (TG_OP = 'UPDATE') then
    -- Transition: published → not-published (unpublish)
    if old.status = 'published' and new.status <> 'published' then
      if old.author_id is not null then
        update public.authors
          set article_count = greatest(article_count - 1, 0)
          where id = old.author_id;
      end if;

    -- Transition: not-published → published (publish)
    elsif old.status <> 'published' and new.status = 'published' then
      if new.author_id is not null then
        update public.authors
          set article_count = article_count + 1
          where id = new.author_id;
      end if;

    -- Same status but author reassigned while published
    elsif new.status = 'published' and old.author_id is distinct from new.author_id then
      if old.author_id is not null then
        update public.authors
          set article_count = greatest(article_count - 1, 0)
          where id = old.author_id;
      end if;
      if new.author_id is not null then
        update public.authors
          set article_count = article_count + 1
          where id = new.author_id;
      end if;
    end if;

  elsif (TG_OP = 'DELETE') then
    -- Article deleted while published
    if old.status = 'published' and old.author_id is not null then
      update public.authors
        set article_count = greatest(article_count - 1, 0)
        where id = old.author_id;
    end if;
  end if;

  return null;
end;
$$ language plpgsql;

-- NOTE: The CREATE TRIGGER statement that attaches
-- update_author_article_count() to the articles table is located in
-- 20260610400000_enhance_articles_table.sql, after the author_id
-- column has been added to articles.  Defining the function here
-- ensures it is available (and can be tested) as soon as the
-- authors table is created.
