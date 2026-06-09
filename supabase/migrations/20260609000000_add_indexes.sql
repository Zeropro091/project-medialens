-- Add indexes on the articles table for faster queries and pagination

-- Index on createdAt for ordering in admin dashboard and public pages
create index if not exists idx_articles_created_at
  on public.articles ("createdAt" desc);

-- Index on status for filtering published articles (used by public pages and SSR)
create index if not exists idx_articles_status
  on public.articles (status);

-- Index on category for category filter queries
create index if not exists idx_articles_category
  on public.articles (category);

-- Index on author_id for poster/journalist queries (filtering their own articles)
create index if not exists idx_articles_author_id
  on public.articles ("author_id");

-- Composite index for the most common public query: published articles ordered by date
create index if not exists idx_articles_status_created_at
  on public.articles (status, "createdAt" desc);

-- Gallery table index
create index if not exists idx_gallery_uploaded_at
  on public.gallery ("uploadedAt" desc);
