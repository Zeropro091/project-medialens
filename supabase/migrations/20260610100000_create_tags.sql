-- Migration: Create tags table and article_tags junction table
-- Requirements: Req 2 - Database Schema - Tag Management

-- ============================================================
-- tags table
-- ============================================================
create table public.tags (
  id uuid primary key default gen_random_uuid(),
  slug text not null,
  name text not null,
  description text,
  usage_count integer not null default 0,
  is_active boolean not null default true,
  "createdAt" timestamp with time zone not null default now(),
  "updatedAt" timestamp with time zone not null default now(),

  -- Req 2.2: globally unique slug
  constraint tags_slug_unique unique (slug),

  -- Req 2.3: name is required and max 50 characters
  constraint tags_name_length check (char_length(name) <= 50),

  -- usage_count must never go negative
  constraint tags_usage_count_nonneg check (usage_count >= 0)
);

comment on table public.tags is 'Non-hierarchical content labels for many-to-many article associations.';
comment on column public.tags.slug is 'Globally unique, URL-friendly identifier.';
comment on column public.tags.usage_count is 'Denormalized count of articles using this tag; maintained by trigger.';

-- ============================================================
-- article_tags junction table
-- ============================================================
create table public.article_tags (
  -- articles.id is type text (see init migration)
  article_id text not null,
  tag_id uuid not null,
  created_at timestamp with time zone not null default now(),

  -- Req 2.4 / 2.5: composite PK prevents duplicate associations
  constraint article_tags_pkey primary key (article_id, tag_id),

  -- Req 2.8: CASCADE DELETE when article is deleted
  constraint article_tags_article_id_fkey foreign key (article_id)
    references public.articles (id)
    on delete cascade,

  -- Req 2.8: CASCADE DELETE when tag is deleted
  constraint article_tags_tag_id_fkey foreign key (tag_id)
    references public.tags (id)
    on delete cascade
);

comment on table public.article_tags is 'Junction table for many-to-many article ↔ tag associations.';

-- Req 2.7: Enforce maximum of 10 tags per article via check function + constraint
create or replace function public.check_article_tag_limit()
returns trigger as $$
begin
  if (
    select count(*)
    from public.article_tags
    where article_id = new.article_id
  ) >= 10 then
    raise exception 'Article cannot have more than 10 tags';
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trg_article_tags_limit
  before insert on public.article_tags
  for each row execute function public.check_article_tag_limit();

-- ============================================================
-- Indexes
-- Req 22.3 / 22.4: idx_article_tags_article_id, idx_article_tags_tag_id
-- ============================================================
create index if not exists idx_tags_slug
  on public.tags (slug);

create index if not exists idx_article_tags_article_id
  on public.article_tags (article_id);

create index if not exists idx_article_tags_tag_id
  on public.article_tags (tag_id);

-- ============================================================
-- Trigger: auto-update tags."updatedAt" on row update
-- ============================================================
create or replace function public.set_tags_updated_at()
returns trigger as $$
begin
  new."updatedAt" = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_tags_updated_at
  before update on public.tags
  for each row execute function public.set_tags_updated_at();

-- ============================================================
-- Trigger: maintain tags.usage_count on article_tags insert/delete
-- Req 2.6: auto-update usage_count when association created or deleted
-- ============================================================
create or replace function public.update_tag_usage_count()
returns trigger as $$
begin
  if (TG_OP = 'INSERT') then
    update public.tags
    set usage_count = usage_count + 1
    where id = new.tag_id;
  elsif (TG_OP = 'DELETE') then
    update public.tags
    set usage_count = greatest(usage_count - 1, 0)
    where id = old.tag_id;
  end if;
  return null;
end;
$$ language plpgsql;

create trigger trg_article_tags_usage_count
  after insert or delete on public.article_tags
  for each row execute function public.update_tag_usage_count();

-- ============================================================
-- Row Level Security
-- ============================================================
alter table public.tags enable row level security;
alter table public.article_tags enable row level security;

-- tags: public read for active tags; admin/dev manage
create policy "Public read active tags"
  on public.tags for select
  using (is_active = true);

create policy "Admin full access to tags"
  on public.tags for all
  using (public.is_admin())
  with check (public.is_admin());

-- article_tags: public can read associations; admin manages
create policy "Public read article_tags"
  on public.article_tags for select
  using (true);

create policy "Admin full access to article_tags"
  on public.article_tags for all
  using (public.is_admin())
  with check (public.is_admin());
