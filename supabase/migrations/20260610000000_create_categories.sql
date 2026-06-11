-- Migration: Create categories table for hierarchical content organization
-- Requirements: Req 1 - Database Schema - Hierarchical Categories

-- Create categories table
create table public.categories (
  id uuid primary key default gen_random_uuid(),
  slug text not null,
  name text not null,
  description text,
  parent_id uuid,
  level integer not null default 0,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  seo_title text,
  seo_description text,
  "createdAt" timestamp with time zone not null default now(),
  "updatedAt" timestamp with time zone not null default now(),

  -- UNIQUE constraint on slug (globally unique across all categories)
  constraint categories_slug_unique unique (slug),

  -- CHECK constraint: level must be between 0 and 3 (max hierarchy depth of 3)
  constraint categories_level_valid check (level >= 0 and level <= 3),

  -- Self-referential FOREIGN KEY: parent_id references categories.id
  constraint categories_parent_id_fkey foreign key (parent_id)
    references public.categories (id)
    on delete restrict
    on update cascade
);

-- Index on slug for fast slug-based lookups (used heavily in routing)
create index if not exists idx_categories_slug
  on public.categories (slug);

-- Index on parent_id for fast hierarchy traversal
create index if not exists idx_categories_parent_id
  on public.categories (parent_id);

-- Index on is_active for filtering active categories
create index if not exists idx_categories_active
  on public.categories (is_active);

-- Enable Row Level Security
alter table public.categories enable row level security;

-- Allow public read access to active categories
create policy "Allow public read access to active categories"
  on public.categories for select
  using (is_active = true);

-- Allow admin and dev roles to manage categories
create policy "Allow admin to manage categories"
  on public.categories for all
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid()
      and role in ('admin', 'dev')
    )
  )
  with check (
    exists (
      select 1 from public.profiles
      where id = auth.uid()
      and role in ('admin', 'dev')
    )
  );

-- Trigger to automatically update "updatedAt" on row modification
create or replace function public.categories_set_updated_at()
returns trigger as $$
begin
  new."updatedAt" = now();
  return new;
end;
$$ language plpgsql;

create trigger categories_updated_at
  before update on public.categories
  for each row execute function public.categories_set_updated_at();
