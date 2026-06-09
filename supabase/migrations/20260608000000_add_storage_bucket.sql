-- Create a public storage bucket for article images
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'images',
  'images',
  true,
  52428800, -- 50 MiB
  array['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml']
)
on conflict (id) do update set
  public = true,
  file_size_limit = 52428800,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml'];

-- Allow public read access
create policy "Public read access for images"
  on storage.objects for select
  using (bucket_id = 'images');

-- Allow authenticated users (admin/dev/poster) to upload
create policy "Authenticated users can upload images"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'images');

-- Allow authenticated users to delete their own uploads
create policy "Authenticated users can delete images"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'images');
