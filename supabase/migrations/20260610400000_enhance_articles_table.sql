-- Migration: Enhance articles table with SEO and relational columns
-- Depends on: 20260610000000_create_categories.sql (categories table)
--             20260610200000_create_authors.sql    (authors table)
--             20260610300000_create_media.sql       (media table)
-- Requirements: Req 5

-- ============================================================
-- 1. Add new columns
-- ============================================================

-- SEO slug (unique within category scope, enforced via index below)
ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS slug text;

-- Relational FK columns
ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS author_id uuid
    REFERENCES public.authors(id) ON DELETE SET NULL;

ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS category_id uuid
    REFERENCES public.categories(id) ON DELETE SET NULL;

ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS featured_image_id uuid
    REFERENCES public.media(id) ON DELETE SET NULL;

ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS og_image_id uuid
    REFERENCES public.media(id) ON DELETE SET NULL;

-- SEO metadata columns
ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS meta_description text;

ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS meta_keywords text;

ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS canonical_url text;

-- Publication timestamp
ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS published_at timestamptz;

-- ============================================================
-- 2. Extend status CHECK to include 'draft' (was only 'published'/'archived')
-- ============================================================

ALTER TABLE public.articles
  DROP CONSTRAINT IF EXISTS articles_status_check;

ALTER TABLE public.articles
  ADD CONSTRAINT articles_status_check
    CHECK (status IN ('published', 'draft', 'archived'));

-- ============================================================
-- 3. Slug format CHECK constraint
--    Pattern: ^[a-z0-9]+(?:-[a-z0-9]+)*$
--    (only lowercase letters/digits separated by single hyphens;
--     NULL is allowed since legacy rows won't have slugs yet)
-- ============================================================

ALTER TABLE public.articles
  DROP CONSTRAINT IF EXISTS articles_slug_format;

ALTER TABLE public.articles
  ADD CONSTRAINT articles_slug_format
    CHECK (
      slug IS NULL
      OR slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
    );

-- ============================================================
-- 4. Length CHECK constraints for title and excerpt
--    Req 5.4: title max 200 chars
--    Req 5.5: excerpt max 300 chars when provided
-- ============================================================

ALTER TABLE public.articles
  DROP CONSTRAINT IF EXISTS articles_title_length;

ALTER TABLE public.articles
  ADD CONSTRAINT articles_title_length
    CHECK (char_length(title) <= 200);

ALTER TABLE public.articles
  DROP CONSTRAINT IF EXISTS articles_excerpt_length;

ALTER TABLE public.articles
  ADD CONSTRAINT articles_excerpt_length
    CHECK (
      excerpt IS NULL
      OR char_length(excerpt) <= 300
    );

-- ============================================================
-- 5. Published article completeness CHECK constraint
--    Req 5.7: when status='published', title + slug + category_id
--             + author_id + published_at must all be non-null
-- ============================================================

ALTER TABLE public.articles
  DROP CONSTRAINT IF EXISTS articles_published_requires_fields;

ALTER TABLE public.articles
  ADD CONSTRAINT articles_published_requires_fields
    CHECK (
      status <> 'published'
      OR (
        title       IS NOT NULL
        AND slug        IS NOT NULL
        AND category_id IS NOT NULL
        AND author_id   IS NOT NULL
        AND published_at IS NOT NULL
      )
    );

-- ============================================================
-- 6. UNIQUE constraint on (category_id, slug)
--    Req 5.2: slug unique within the same category_id scope
--    Implemented as a partial unique index to allow NULLs
--    (two rows can both have slug=NULL without violating uniqueness)
-- ============================================================

-- Drop pre-existing unique constraint if any
ALTER TABLE public.articles
  DROP CONSTRAINT IF EXISTS articles_category_id_slug_key;

-- ============================================================
-- 7. Indexes
-- ============================================================

-- Unique composite index for slug lookups (Req 22.1)
-- Named to match task spec: idx_articles_category_slug
-- Uses a partial index excluding NULLs so legacy rows are unaffected
CREATE UNIQUE INDEX IF NOT EXISTS idx_articles_category_slug
  ON public.articles (category_id, slug)
  WHERE category_id IS NOT NULL AND slug IS NOT NULL;

-- Status + published_at for listing queries (Req 22.2)
CREATE INDEX IF NOT EXISTS idx_articles_status_published_at
  ON public.articles (status, published_at DESC);

-- Single-column FK indexes for join performance
CREATE INDEX IF NOT EXISTS idx_articles_author_id
  ON public.articles (author_id);

CREATE INDEX IF NOT EXISTS idx_articles_category_id
  ON public.articles (category_id);

-- ============================================================
-- 8. Mark legacy columns as deprecated via column comments
--    Req 5.8 / Req 32.1: keep columns for backward compat
-- ============================================================

COMMENT ON COLUMN public.articles.author   IS 'DEPRECATED: use author_id (FK to authors table)';
COMMENT ON COLUMN public.articles.role     IS 'DEPRECATED: use authors.is_staff or profiles.role';
COMMENT ON COLUMN public.articles.date     IS 'DEPRECATED: use createdAt or published_at';
COMMENT ON COLUMN public.articles.time     IS 'DEPRECATED: use createdAt or published_at';
COMMENT ON COLUMN public.articles.category IS 'DEPRECATED: use category_id (FK to categories table)';
COMMENT ON COLUMN public.articles."imageUrl" IS 'DEPRECATED: use featured_image_id (FK to media table)';

-- ============================================================
-- 9. Attach update_author_article_count() trigger
--    Defined in 20260610200000_create_authors.sql; attached
--    here because author_id column must exist first (Req 3.6).
-- ============================================================

DROP TRIGGER IF EXISTS trg_articles_author_article_count ON public.articles;

CREATE TRIGGER trg_articles_author_article_count
  AFTER INSERT OR UPDATE OR DELETE ON public.articles
  FOR EACH ROW EXECUTE FUNCTION public.update_author_article_count();
