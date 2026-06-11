-- Migration: Create media table for centralized media asset management
-- Requirements: Req 4 - Database Schema - Media Management

create table if not exists public.media (
  id            uuid primary key default gen_random_uuid(),
  filename      text not null,
  storage_path  text not null,
  public_url    text not null,
  mime_type     text not null,
  file_size     integer not null,
  width         integer,
  height        integer,
  alt_text      text not null,
  caption       text,
  credit        text,
  uploaded_by   uuid not null references public.profiles(id) on delete restrict,
  "uploadedAt"  timestamptz not null default now(),

  -- Req 4.3: mime_type must be one of the allowed image types
  constraint media_mime_type_check
    check (mime_type in ('image/jpeg', 'image/png', 'image/webp', 'image/gif')),

  -- Req 4.4: file_size must not exceed 10MB (10485760 bytes)
  constraint media_file_size_check
    check (file_size <= 10485760),

  -- Req 4.5: width and height must be between 100 and 4000 pixels when provided
  constraint media_width_check
    check (width is null or (width >= 100 and width <= 4000)),

  constraint media_height_check
    check (height is null or (height >= 100 and height <= 4000))

  -- Req 4.2: alt_text is enforced NOT NULL at the column level above
);

-- Index on uploaded_by for querying media by uploader
create index if not exists idx_media_uploaded_by
  on public.media (uploaded_by);

-- Index on mime_type for filtering by file type
create index if not exists idx_media_mime_type
  on public.media (mime_type);

-- Enable Row Level Security
alter table public.media enable row level security;

-- Allow public read access to media assets (images used in published articles)
create policy "Allow public read access to media"
  on public.media for select
  using (true);

-- Allow authenticated users to insert their own media
create policy "Allow authenticated users to upload media"
  on public.media for insert
  with check (auth.uid() is not null and uploaded_by = auth.uid());

-- Allow uploader or admin/dev to update media metadata
create policy "Allow uploader or admin to update media"
  on public.media for update
  using (
    uploaded_by = auth.uid() or public.is_admin_or_dev()
  );

-- Allow uploader or admin/dev to delete media
create policy "Allow uploader or admin to delete media"
  on public.media for delete
  using (
    uploaded_by = auth.uid() or public.is_admin_or_dev()
  );
