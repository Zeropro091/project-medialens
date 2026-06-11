# Implementation Plan: Phase 1 - SEO & Core Article System

## Overview

This implementation plan transforms the Lensa Insignia news platform by establishing comprehensive SEO infrastructure and a hierarchical content management system. The plan follows a four-phase migration strategy to ensure zero downtime and backward compatibility while transitioning from a simple articles table to a complete relational schema with categories, tags, authors, and media management.

The implementation prioritizes search engine discoverability through server-side rendered pages with complete SEO metadata, dynamic XML sitemaps, Schema.org structured data, and semantic URL structures. All tasks build incrementally, with checkpoints to validate functionality before proceeding to the next phase.

## Tasks

### Phase 1: Database Schema Migration

- [x] 1. Create categories table and migration
  - [x] 1.1 Write migration file `20260610000000_create_categories.sql`
    - Create categories table with fields: id (UUID), slug (text unique), name (text), description (text), parent_id (UUID FK), level (int), sort_order (int), is_active (boolean), seo_title (text), seo_description (text), createdAt, updatedAt
    - Add CHECK constraint: level between 0 and 3 (max hierarchy depth)
    - Add UNIQUE constraint on slug
    - Add self-referential FOREIGN KEY on parent_id
    - Create indexes: idx_categories_slug, idx_categories_parent_id, idx_categories_active
    - _Requirements: Req 1_

  - [ ]* 1.2 Write unit tests for category table constraints
    - Test slug uniqueness enforcement
    - Test parent_id circular reference prevention
    - Test level calculation
    - Test max depth enforcement
    - _Requirements: Req 1, Req 33_

- [x] 2. Create tags and article_tags tables
  - [x] 2.1 Write migration file `20260610100000_create_tags.sql`
    - Create tags table with fields: id (UUID), slug (text unique), name (text), description (text), usage_count (int default 0), is_active (boolean), createdAt, updatedAt
    - Create article_tags junction table with composite PK (article_id, tag_id)
    - Add CASCADE DELETE on both foreign keys
    - Create indexes: idx_tags_slug, idx_article_tags_article_id, idx_article_tags_tag_id
    - _Requirements: Req 2_

  - [x] 2.2 Create trigger function for tag usage_count auto-update
    - Write trigger function update_tag_usage_count() that increments/decrements usage_count on article_tags INSERT/DELETE
    - Attach trigger to article_tags table for AFTER INSERT and AFTER DELETE events
    - _Requirements: Req 2_

  - [ ]* 2.3 Write property test for tag usage_count accuracy
    - **Property 1: Tag usage count reflects actual associations**
    - **Validates: Requirements Req 2**
    - Generate random article-tag associations, verify usage_count matches actual count
    - _Requirements: Req 2, Req 33_

- [ ] 3. Create authors table
  - [x] 3.1 Write migration file `20260610200000_create_authors.sql`
    - Create authors table with fields: id (UUID), profile_id (UUID FK nullable), name (text), slug (text unique), bio (text max 500), avatar_url (text), email (text), twitter_handle (text), linkedin_url (text), website_url (text), is_staff (boolean), is_active (boolean), article_count (int default 0), createdAt, updatedAt
    - Add UNIQUE constraint on slug
    - Add email format validation CHECK constraint
    - Create indexes: idx_authors_slug, idx_authors_profile_id
    - _Requirements: Req 3_

  - [x] 3.2 Create trigger function for author article_count auto-update
    - Write trigger function update_author_article_count() that updates count when articles are published/unpublished
    - Attach trigger to articles table for status changes
    - _Requirements: Req 3_

  - [ ]* 3.3 Write unit tests for author constraints
    - Test slug uniqueness
    - Test email format validation
    - Test article_count accuracy
    - _Requirements: Req 3, Req 33_

- [x] 4. Create media table
  - [x] 4.1 Write migration file `20260610300000_create_media.sql`
    - Create media table with fields: id (UUID), filename (text), storage_path (text), public_url (text), mime_type (text), file_size (int), width (int), height (int), alt_text (text), caption (text), credit (text), uploaded_by (UUID FK), uploadedAt
    - Add CHECK constraint: mime_type in ('image/jpeg', 'image/png', 'image/webp', 'image/gif')
    - Add CHECK constraint: file_size <= 10485760 (10MB)
    - Add CHECK constraint: width between 100 and 4000, height between 100 and 4000
    - Add NOT NULL constraint on alt_text for accessibility
    - Create indexes: idx_media_uploaded_by, idx_media_mime_type
    - _Requirements: Req 4_

  - [ ]* 4.2 Write unit tests for media constraints
    - Test mime_type enforcement
    - Test file_size limit
    - Test dimension validation
    - Test alt_text requirement
    - _Requirements: Req 4, Req 33_

- [x] 5. Enhance articles table with new columns
  - [x] 5.1 Write migration file `20260610400000_enhance_articles_table.sql`
    - Add columns: slug (text), author_id (UUID FK), category_id (UUID FK), featured_image_id (UUID FK), meta_description (text), meta_keywords (text), og_image_id (UUID FK), canonical_url (text), published_at (timestamptz)
    - Add UNIQUE constraint on (category_id, slug)
    - Add CHECK constraint: slug matches pattern '^[a-z0-9]+(?:-[a-z0-9]+)*$'
    - Add CHECK constraint: title length <= 200, excerpt length <= 300
    - Add CHECK constraint: when status='published', require title, slug, category_id, author_id, published_at
    - Create indexes: idx_articles_category_slug UNIQUE (category_id, slug), idx_articles_status_published_at (status, published_at DESC), idx_articles_author_id, idx_articles_category_id
    - Mark legacy columns as deprecated in comment: author, role, date, time, category, imageUrl
    - _Requirements: Req 5_

  - [ ]* 5.2 Write property test for slug uniqueness within category
    - **Property 1: Slug Uniqueness Within Category**
    - **Validates: Requirements Req 5, Req 7**
    - Verify no two articles in same category can have same slug
    - _Requirements: Req 5, Req 33_


- [ ] 6. Create database migration data backfill script
  - [ ] 6.1 Write TypeScript script `scripts/backfill-phase1-data.ts`
    - Create default "Uncategorized" category if no categories exist
    - For each existing article: extract category from text field, create/link category record
    - For each existing article: extract author from text field, create/link author record
    - Generate slug from title using slug generation logic for all existing articles
    - Resolve slug conflicts within categories with numeric suffixes
    - Set published_at to createdAt for articles with status='published'
    - Log all migrations for audit trail
    - _Requirements: Req 32_

  - [ ]* 6.2 Write integration test for backfill script
    - Create sample legacy articles
    - Run backfill script
    - Verify all articles have slug, category_id, author_id populated
    - Verify slug uniqueness within categories
    - _Requirements: Req 32, Req 34_

- [~] 7. Checkpoint - Database migration validation
  - Run all migrations on local Supabase instance
  - Run backfill script with test data
  - Verify all constraints, indexes, triggers working
  - Ensure all tests pass, ask the user if questions arise

### Phase 2: Application Code Updates - Services & Utilities

- [x] 8. Create TypeScript interfaces and types
  - [x] 8.1 Create file `src/types/database.types.ts`
    - Define interface Article with all old and new fields
    - Define interface Category with hierarchical fields
    - Define interface Tag with usage tracking
    - Define interface Author with profile link
    - Define interface Media with metadata
    - Define interface ArticleTag junction
    - Define union type ArticleStatus: 'published' | 'draft' | 'archived'
    - Export all types for use across application
    - _Requirements: Req 1-5_

  - [x] 8.2 Create file `src/types/seo.types.ts`
    - Define interface SEOMetadata with title, description, canonical, openGraph, twitter, structuredData
    - Define interface OpenGraphData with type, title, description, image, url
    - Define interface TwitterCardData with card, title, description, image, site
    - Define interface BreadcrumbItem with name, url, position
    - Define interface SitemapEntry with loc, lastmod, priority, changefreq
    - _Requirements: Req 11-18_

- [ ] 9. Implement Slug Generation Service
  - [~] 9.1 Create file `src/services/SlugService.ts`
    - Implement function generateSlug(title: string): string
    - Convert to lowercase, replace non-alphanumeric with hyphens
    - Remove leading/trailing hyphens, collapse consecutive hyphens
    - Truncate to max 100 characters
    - Ensure matches pattern ^[a-z0-9]+(?:-[a-z0-9]+)*$
    - _Requirements: Req 6_

  - [ ]* 9.2 Write unit tests for generateSlug()
    - Test empty titles, special characters, unicode, very long titles
    - Test already-hyphenated titles
    - Verify pattern compliance and length limits
    - _Requirements: Req 6, Req 33_

  - [ ]* 9.3 Write property test for slug format validity
    - **Property 2: Slug Format Validity**
    - **Validates: Requirements Req 6**
    - Generate random titles, verify all resulting slugs match pattern
    - _Requirements: Req 6, Req 33_


  - [~] 9.4 Implement ensureUniqueSlug() function
    - Add async function ensureUniqueSlug(baseSlug: string, categoryId: string, articleId?: string): Promise<string>
    - Query database to check if slug exists in category (excluding current article if updating)
    - If conflict, append numeric suffix (-2, -3, etc.) until unique
    - Enforce maximum 100 attempts, throw error if exhausted
    - _Requirements: Req 7_

  - [ ]* 9.5 Write integration test for ensureUniqueSlug()
    - Create articles with conflicting slugs in database
    - Verify conflict resolution with numeric suffixes
    - Verify current article excluded from conflict check during updates
    - _Requirements: Req 7, Req 34_

  - [~] 9.6 Implement findArticleBySlug() function
    - Add async function findArticleBySlug(categorySlug: string, articleSlug: string): Promise<Article | null>
    - Query categories by slug, then articles by slug within category
    - Join with authors, media, tags tables
    - Filter by status='published' and category.is_active=true
    - Return null if not found
    - _Requirements: Req 8, Req 9_

  - [ ]* 9.7 Write integration test for findArticleBySlug()
    - Create test article with category, author, tags, media
    - Verify complete data retrieval with all joins
    - Verify null returned for draft/archived articles
    - Verify null returned for inactive categories
    - _Requirements: Req 8, Req 9, Req 34_

- [ ] 10. Implement SEO Metadata Service
  - [~] 10.1 Create file `src/services/SEOService.ts`
    - Implement function generateArticleSEO(article: Article): SEOMetadata
    - Generate meta title: "{article.title} | Lensa Insignia"
    - Use article.meta_description if available, else article.excerpt, truncate to 150-160 chars
    - Generate canonical URL: {SITE_URL}/{category.slug}/{article.slug}
    - Use custom canonical_url if valid (same domain)
    - Generate Open Graph metadata with article details
    - Generate Twitter Card metadata
    - _Requirements: Req 11, Req 12, Req 13_

  - [ ]* 10.2 Write unit tests for generateArticleSEO()
    - Test with complete article data
    - Test with missing optional fields (excerpt, images)
    - Verify meta description length enforcement
    - Verify canonical URL validation
    - Test custom canonical_url validation and fallback
    - _Requirements: Req 11, Req 12, Req 13, Req 33_

  - [~] 10.3 Implement generateCategorySEO() function
    - Add function generateCategorySEO(category: Category): SEOMetadata
    - Generate title, description from category fields
    - Use category.seo_title/seo_description if available
    - Generate canonical URL for category page
    - _Requirements: Req 11_

  - [~] 10.4 Implement generateHomepageSEO() function
    - Add function generateHomepageSEO(): SEOMetadata
    - Use default site title and description
    - Generate canonical URL for homepage
    - _Requirements: Req 11_


- [ ] 11. Implement Structured Data Service
  - [~] 11.1 Create file `src/services/StructuredDataService.ts`
    - Implement function generateNewsArticleSchema(article: Article): object
    - Generate JSON-LD with @type "NewsArticle"
    - Include headline, datePublished, dateModified, author, publisher, image, articleBody
    - Ensure author includes @type "Person" with name
    - Ensure publisher includes @type "Organization" with name "Lensa Insignia" and logo
    - _Requirements: Req 14_

  - [ ]* 11.2 Write unit tests for generateNewsArticleSchema()
    - Verify all required Schema.org properties present
    - Test with and without featured image
    - Validate JSON-LD structure
    - _Requirements: Req 14, Req 33_

  - [~] 11.3 Implement generateOrganizationSchema() function
    - Add function generateOrganizationSchema(): object
    - Generate JSON-LD with @type "Organization"
    - Include name "Lensa Insignia", url, logo
    - Include sameAs array with social profile URLs if configured
    - _Requirements: Req 15_

  - [~] 11.4 Implement generateBreadcrumbSchema() function
    - Add function generateBreadcrumbSchema(breadcrumbs: BreadcrumbItem[]): object
    - Generate JSON-LD with @type "BreadcrumbList"
    - Include itemListElement array with position, name, item
    - Position 1: Home, Position 2: Category, Position 3: Article
    - _Requirements: Req 16_

  - [ ]* 11.5 Write property test for structured data completeness
    - **Property 6: SEO Metadata Presence**
    - **Validates: Requirements Req 14, Req 15, Req 16**
    - Generate random articles, verify all required Schema.org properties present
    - _Requirements: Req 14, Req 15, Req 16, Req 33_

- [ ] 12. Implement Related Articles Algorithm
  - [~] 12.1 Create file `src/services/RelatedArticlesService.ts`
    - Implement async function findRelatedArticles(article: Article, limit: number): Promise<Article[]>
    - Step 1: Find articles with same tags, order by tag overlap count DESC
    - Step 2: If insufficient matches, fill with same category articles
    - Exclude current article from results
    - Filter by status='published'
    - Enforce limit on results
    - _Requirements: Req 10_

  - [ ]* 12.2 Write unit tests for findRelatedArticles()
    - Test tag overlap weighting
    - Test category fallback when insufficient tag matches
    - Test current article exclusion
    - Test limit enforcement
    - _Requirements: Req 10, Req 33_

  - [ ]* 12.3 Write property test for related articles invariants
    - **Property 3: Related Articles No Self-Reference**
    - **Validates: Requirements Req 10**
    - Verify current article never appears in related results
    - _Requirements: Req 10, Req 33_

- [~] 13. Checkpoint - Service layer validation
  - Run all unit tests and property tests
  - Verify slug generation, SEO metadata, structured data services work correctly
  - Ensure all tests pass, ask the user if questions arise


### Phase 3: SEO Implementation - Sitemaps & SSR

- [ ] 14. Implement Sitemap Generator
  - [~] 14.1 Create file `src/services/SitemapGenerator.ts`
    - Implement async function generateMainSitemap(): Promise<string>
    - Add homepage with priority 1.0, changefreq "hourly"
    - Query all active categories, add with priority 0.8, changefreq "daily"
    - Query all published articles with category slugs
    - Format article URLs as {SITE_URL}/{category.slug}/{article.slug}
    - Include lastmod date from article.updatedAt in YYYY-MM-DD format
    - Add static pages (about, contact, terms, privacy) with priority 0.5
    - Generate valid XML conforming to sitemap.org specification
    - Escape all URLs properly for XML
    - _Requirements: Req 17_

  - [ ]* 14.2 Write integration test for generateMainSitemap()
    - Create test articles and categories
    - Generate sitemap XML
    - Parse XML and validate against sitemap.org schema
    - Verify all published articles present
    - Count URLs matches database count
    - _Requirements: Req 17, Req 34_

  - [ ]* 14.3 Write property test for sitemap completeness
    - **Property 5: Sitemap Completeness**
    - **Validates: Requirements Req 17**
    - Verify every published article appears in sitemap
    - _Requirements: Req 17, Req 33_

  - [~] 14.4 Implement generateNewsSitemap() function
    - Add async function generateNewsSitemap(): Promise<string>
    - Query articles with published_at within last 48 hours
    - Format with news:publication_date (ISO 8601 timestamp)
    - Include news:title with article title
    - Conform to Google News sitemap specification
    - _Requirements: Req 18_

  - [ ]* 14.5 Write integration test for generateNewsSitemap()
    - Create articles with recent and old timestamps
    - Verify only last 48 hours included
    - Validate XML format
    - _Requirements: Req 18, Req 34_

- [ ] 15. Add sitemap endpoints to Express server
  - [~] 15.1 Update file `server.ts`
    - Import SitemapGenerator
    - Add GET /sitemap.xml route handler
    - Call generateMainSitemap(), set Content-Type: application/xml
    - Return 500 with fallback sitemap on errors
    - Add GET /news-sitemap.xml route handler
    - Call generateNewsSitemap(), return XML
    - Implement 15-minute cache for sitemap responses
    - _Requirements: Req 17, Req 18, Req 23_

  - [ ]* 15.2 Write integration test for sitemap endpoints
    - Request /sitemap.xml, verify 200 response with valid XML
    - Request /news-sitemap.xml, verify 200 response with valid XML
    - Verify cache headers set correctly
    - _Requirements: Req 17, Req 18, Req 34_

- [ ] 16. Enhance SSR data fetching utilities
  - [~] 16.1 Update file `src/lib/ssrUtils.ts`
    - Add function fetchArticlesSSR() to fetch articles on server
    - Add function fetchArticleBySlugSSR(categorySlug: string, articleSlug: string)
    - Add function fetchCategoriesSSR() to fetch all active categories
    - Cache category list in memory for 5 minutes
    - Use Supabase client with connection pooling
    - _Requirements: Req 19, Req 23_


  - [ ]* 16.2 Write integration tests for SSR data fetching
    - Test fetchArticleBySlugSSR with complete data
    - Test cache behavior for category list
    - Verify connection pooling configuration
    - _Requirements: Req 19, Req 23, Req 34_

- [ ] 17. Update SSR renderer for SEO metadata injection
  - [~] 17.1 Update file `src/entry-server.tsx`
    - Import SEOService, StructuredDataService
    - For article routes, generate complete SEO metadata
    - Pass article data and SEO metadata to Helmet context
    - Serialize article data to window.__INITIAL_ARTICLES__
    - Inject Helmet tags (title, meta, link, script) into HTML head
    - Return complete HTML with 200 status
    - For 404, return NotFoundPage HTML with 404 status and noindex meta tag
    - _Requirements: Req 19, Req 29_

  - [ ]* 17.2 Write integration test for SSR SEO injection
    - Render article page on server
    - Parse HTML output, verify meta description present before </head>
    - Verify canonical URL present before </head>
    - Verify JSON-LD script tags present before </head>
    - Verify window.__INITIAL_ARTICLES__ serialized
    - _Requirements: Req 19, Req 35, Req 34_

  - [ ]* 17.3 Write property test for SSR metadata completeness
    - **Property 6: SEO Metadata Presence (SSR)**
    - **Validates: Requirements Req 19**
    - Generate random articles, render SSR, verify all metadata present in HTML
    - _Requirements: Req 19, Req 35, Req 33_

- [~] 18. Checkpoint - SSR and Sitemap validation
  - Start server with `npm run dev:ssr`
  - Verify /sitemap.xml returns valid XML
  - Verify /news-sitemap.xml returns valid XML
  - Verify article SSR includes complete SEO metadata
  - Ensure all tests pass, ask the user if questions arise

### Phase 4: React Components & Client-Side Routing

- [ ] 19. Create Article Page component
  - [~] 19.1 Create file `src/pages/ArticlePage.tsx`
    - Import useParams from react-router-dom to extract category and slug
    - Import Helmet from react-helmet-async for meta tags
    - Import SEOService, StructuredDataService, RelatedArticlesService
    - Implement useState for article, relatedArticles, loading, error
    - Implement useEffect to fetch article by slug on mount
    - If window.__INITIAL_ARTICLES__ exists, use it (SSR hydration)
    - Otherwise fetch client-side using findArticleBySlug()
    - Fetch related articles after article loads
    - If article not found, render NotFoundPage component
    - Generate SEO metadata using SEOService
    - Render Helmet with complete meta tags (title, description, canonical, OG, Twitter, JSON-LD)
    - Render article header with title, subtitle, author, date
    - Render featured image if available
    - Render article content (contentStr with MarkdownRenderer or contentArr as paragraphs)
    - Render related articles section
    - _Requirements: Req 8, Req 9, Req 10, Req 11, Req 12, Req 13, Req 14, Req 15, Req 16_

  - [ ]* 19.2 Write unit tests for ArticlePage component
    - Test rendering with complete article data
    - Test rendering with missing optional fields
    - Test 404 handling when article not found
    - Test SSR hydration from window.__INITIAL_ARTICLES__
    - _Requirements: Req 8, Req 29, Req 33_


- [ ] 20. Update React Router configuration
  - [~] 20.1 Update file `src/App.tsx`
    - Add new route: `<Route path="/:category/:slug" element={<ArticlePage />} />`
    - Ensure route is placed before generic catch-all routes
    - Keep existing route /article/:id for backward compatibility (mark as deprecated)
    - Add 301 redirect logic from /article/:id to /:category/:slug (prepare for Phase 5)
    - _Requirements: Req 8, Req 32_

  - [ ]* 20.2 Write integration test for routing
    - Navigate to /:category/:slug route
    - Verify ArticlePage component renders
    - Verify route params extracted correctly
    - Test backward compat route /article/:id still works
    - _Requirements: Req 8, Req 32, Req 34_

- [ ] 21. Update CategoryPage component for hierarchical categories
  - [~] 21.1 Update file `src/pages/CategoryPage.tsx`
    - Import updated Category type with hierarchy fields
    - Fetch category by slug from new categories table
    - Display category description and SEO metadata
    - Fetch articles filtered by category_id
    - Display breadcrumb navigation (Home > Category)
    - Generate SEO metadata using generateCategorySEO()
    - Render Helmet with category-specific meta tags
    - _Requirements: Req 1, Req 11_

  - [ ]* 21.2 Write unit tests for updated CategoryPage
    - Test rendering with hierarchical category data
    - Test breadcrumb generation
    - Test SEO metadata generation
    - _Requirements: Req 1, Req 11, Req 33_

- [ ] 22. Create NotFoundPage component enhancements
  - [~] 22.1 Update file `src/pages/NotFoundPage.tsx`
    - Add Helmet with noindex, follow meta tag
    - Display helpful 404 message
    - Show related articles from requested category if available
    - Provide site navigation links
    - Add search functionality (if available)
    - _Requirements: Req 29_

  - [ ]* 22.2 Write unit tests for NotFoundPage
    - Verify noindex meta tag present
    - Test related articles suggestions
    - Test navigation links
    - _Requirements: Req 29, Req 33_

- [ ] 23. Implement client-side hydration
  - [~] 23.1 Update file `src/entry-client.tsx`
    - Check for window.__INITIAL_ARTICLES__ on mount
    - If present, use as initial state for article data (avoid re-fetching)
    - Hydrate React components with SSR data
    - Attach event handlers without unmounting/remounting
    - Enable client-side navigation without full page reloads
    - _Requirements: Req 20_

  - [ ]* 23.2 Write integration test for hydration
    - Simulate SSR with window.__INITIAL_ARTICLES__
    - Verify React hydrates without re-fetching
    - Verify no content flash or remounting
    - _Requirements: Req 20, Req 34_

- [~] 24. Checkpoint - Frontend integration validation
  - Build application with `npm run build`
  - Test article pages with different routes
  - Verify SEO metadata visible in browser dev tools
  - Test client-side navigation between articles
  - Ensure all tests pass, ask the user if questions arise


### Phase 5: Media Management & Image Optimization

- [ ] 25. Implement media upload and storage
  - [~] 25.1 Create file `src/services/MediaService.ts`
    - Implement async function uploadMedia(file: File, uploadedBy: string): Promise<Media>
    - Validate file: mime_type in allowed list, file_size <= 10MB
    - Extract image dimensions using browser Image API
    - Upload to Supabase Storage bucket 'media'
    - Generate public URL from storage path
    - Insert record into media table with metadata
    - Return Media object with id and public_url
    - _Requirements: Req 4, Req 21_

  - [ ]* 25.2 Write unit tests for media validation
    - Test mime_type enforcement
    - Test file_size limit rejection
    - Test dimension extraction
    - _Requirements: Req 4, Req 21, Req 33_

  - [~] 25.3 Implement generateImageVariants() function
    - Add async function generateImageVariants(mediaId: string): Promise<void>
    - Generate thumbnail (300px width), medium (800px width), large (1600px width)
    - Generate WebP format with JPEG fallback
    - Store variants in Supabase Storage under media/:id/variants/
    - Update media record with variant paths
    - _Requirements: Req 21_

  - [ ]* 25.4 Write integration test for image variant generation
    - Upload test image
    - Verify variants generated correctly
    - Verify WebP and JPEG formats available
    - _Requirements: Req 21, Req 34_

- [ ] 26. Implement optimized image rendering component
  - [~] 26.1 Create file `src/components/OptimizedImage.tsx`
    - Accept props: media (Media object), alt (string), width, height, loading (lazy/eager)
    - Render <picture> element with WebP and JPEG sources
    - Include srcset with multiple size variants for responsive loading
    - Set explicit width and height attributes to prevent layout shift
    - Implement lazy loading for images below fold
    - Add error handling for missing images with fallback placeholder
    - _Requirements: Req 21, Req 31_

  - [ ]* 26.2 Write unit tests for OptimizedImage component
    - Test WebP source with JPEG fallback
    - Test lazy loading prop
    - Test missing image fallback
    - Test explicit dimensions
    - _Requirements: Req 21, Req 31, Req 33_

- [ ] 27. Update ArticlePage to use OptimizedImage
  - [~] 27.1 Update file `src/pages/ArticlePage.tsx`
    - Replace plain <img> with OptimizedImage component
    - Pass featured_image media object
    - Set loading="eager" for above-fold featured image
    - Set loading="lazy" for images in article content
    - Handle missing image gracefully with placeholder
    - _Requirements: Req 21, Req 31_

- [~] 28. Checkpoint - Media and image optimization validation
  - Upload test images through admin interface
  - Verify variants generated correctly
  - Verify WebP format served to supporting browsers
  - Check image lazy loading in browser dev tools
  - Measure Largest Contentful Paint (LCP), target < 2.5s
  - Ensure all tests pass, ask the user if questions arise


### Phase 6: Performance Optimization & Caching

- [ ] 29. Implement database query optimization
  - [~] 29.1 Verify migration file includes all performance indexes
    - Composite index: idx_articles_category_slug UNIQUE (category_id, slug)
    - Composite index: idx_articles_status_published_at (status, published_at DESC)
    - Single indexes: idx_articles_author_id, idx_articles_category_id
    - Junction indexes: idx_article_tags_article_id, idx_article_tags_tag_id
    - Category indexes: idx_categories_slug, idx_categories_parent_id
    - Author indexes: idx_authors_slug, idx_authors_profile_id
    - _Requirements: Req 22_

  - [~] 29.2 Update all database queries to use explicit field lists
    - Review all Supabase queries, replace SELECT * with explicit columns
    - Only fetch fields needed for specific operation
    - Document query performance in comments
    - _Requirements: Req 22_

  - [ ]* 29.3 Write performance benchmarks
    - **Property 4: Query Performance**
    - **Validates: Requirements Req 24**
    - Benchmark article fetch by slug: target < 50ms
    - Benchmark related articles query: target < 100ms
    - Benchmark sitemap generation (1000 articles): target < 500ms
    - _Requirements: Req 22, Req 24, Req 33_

- [ ] 30. Implement caching strategies
  - [~] 30.1 Create file `src/lib/cache.ts`
    - Implement in-memory LRU cache for category list (5 minute TTL)
    - Implement sitemap XML cache (15 minute TTL)
    - Implement cache invalidation on article publish/update
    - Add cache statistics logging for monitoring
    - _Requirements: Req 23_

  - [ ]* 30.2 Write integration tests for caching
    - Test category cache hit/miss behavior
    - Test cache invalidation on article publish
    - Test cache TTL expiration
    - Verify performance improvement with cache
    - _Requirements: Req 23, Req 34_

- [ ] 31. Implement rate limiting middleware
  - [~] 31.1 Create file `src/middleware/rateLimiter.ts`
    - Install express-rate-limit package if needed
    - Create rate limiter: 10 req/min per IP for /sitemap.xml
    - Create rate limiter: 100 req/min per IP for article endpoints
    - Return 429 status with Retry-After header when exceeded
    - Log rate limit violations for monitoring
    - _Requirements: Req 27_

  - [ ]* 31.2 Write integration tests for rate limiting
    - Send rapid requests to /sitemap.xml
    - Verify 429 response after limit exceeded
    - Verify Retry-After header present
    - _Requirements: Req 27, Req 34_

  - [~] 31.3 Update file `server.ts` to apply rate limiters
    - Import rate limiter middleware
    - Apply sitemap rate limiter to /sitemap.xml and /news-sitemap.xml
    - Apply article rate limiter to /:category/:slug route
    - _Requirements: Req 27_

- [~] 32. Checkpoint - Performance optimization validation
  - Run performance benchmarks, verify targets met
  - Test cache effectiveness with repeated requests
  - Test rate limiting with load testing tool
  - Monitor database query performance with EXPLAIN ANALYZE
  - Ensure all tests pass, ask the user if questions arise


### Phase 7: Security Hardening & Input Validation

- [ ] 33. Implement input validation middleware
  - [~] 33.1 Create file `src/middleware/validation.ts`
    - Create slug validation function: validate pattern ^[a-z0-9-]+$ before database queries
    - Create function to reject slugs containing SQL keywords
    - Enforce max slug length 100 characters
    - Create MIME type validation for uploads
    - Create email format validation
    - _Requirements: Req 25_

  - [ ]* 33.2 Write unit tests for validation functions
    - Test slug pattern validation
    - Test SQL keyword rejection
    - Test length enforcement
    - Test MIME type validation
    - _Requirements: Req 25, Req 33_

  - [~] 33.3 Apply validation to all user input endpoints
    - Validate slug params in article fetch routes
    - Validate category slug params
    - Validate file uploads in media service
    - Return 400 Bad Request with clear error messages for invalid inputs
    - _Requirements: Req 25_

- [ ] 34. Implement content sanitization
  - [~] 34.1 Install and configure DOMPurify
    - Add isomorphic-dompurify package to dependencies
    - Create sanitization utility in `src/lib/sanitize.ts`
    - Configure allowed HTML tags and attributes
    - Sanitize article contentStr before rendering
    - _Requirements: Req 25_

  - [ ]* 34.2 Write unit tests for content sanitization
    - Test malicious script tag removal
    - Test iframe removal
    - Test allowed HTML tags preservation
    - _Requirements: Req 25, Req 33_

- [ ] 35. Implement canonical URL security validation
  - [~] 35.1 Update SEOService to validate custom canonical URLs
    - Add function validateCanonicalUrl(url: string): boolean
    - Verify URL matches site domain from environment variable
    - Reject external domain canonical URLs
    - Log warnings for invalid canonical URLs
    - Fallback to auto-generated canonical if custom is invalid
    - _Requirements: Req 28_

  - [ ]* 35.2 Write unit tests for canonical URL validation
    - Test same-domain URL acceptance
    - Test external domain rejection
    - Test fallback behavior
    - _Requirements: Req 28, Req 33_

- [ ] 36. Verify Row Level Security policies
  - [~] 36.1 Review and update RLS policies in migration files
    - Verify public can read published articles only
    - Verify poster role can only edit own articles
    - Verify admin/dev roles can edit any articles
    - Add RLS policies for new tables: categories, tags, authors, media
    - Public read for categories, tags, authors (active only)
    - Restricted write access for categories, tags, authors, media
    - _Requirements: Req 26_

  - [ ]* 36.2 Write integration tests for RLS policies
    - Test public read access to published articles
    - Test authenticated poster edit own articles only
    - Test admin edit any article
    - Test draft/archived article access denied to public
    - _Requirements: Req 26, Req 34_

- [~] 37. Checkpoint - Security validation
  - Run all security-related tests
  - Test input validation with malicious inputs
  - Verify RLS policies prevent unauthorized access
  - Test content sanitization with XSS payloads
  - Ensure all tests pass, ask the user if questions arise


### Phase 8: End-to-End Testing & SEO Validation

- [ ] 38. Set up Playwright E2E testing framework
  - [~] 38.1 Install Playwright dependencies
    - Run `npm install -D @playwright/test`
    - Run `npx playwright install`
    - Create `playwright.config.ts` with configuration
    - _Requirements: Req 35_

  - [~] 38.2 Create E2E test scenarios
    - Create file `tests/e2e/article-page.spec.ts`
    - Test scenario: User navigates to article via /:category/:slug
    - Test scenario: User shares article link on social media (verify OG tags in DOM)
    - Test scenario: Article slug conflict resolution during bulk import
    - Test scenario: Related articles display correctly
    - Test scenario: 404 page for non-existent articles
    - _Requirements: Req 35_

  - [ ]* 38.3 Run E2E tests
    - Execute `npx playwright test`
    - Verify all scenarios pass
    - Capture screenshots on failures
    - _Requirements: Req 35_

- [ ] 39. Implement SEO validation tests
  - [~] 39.1 Create SEO audit test file `tests/seo/lighthouse.spec.ts`
    - Use Lighthouse CI to audit article pages
    - Assert SEO score >= 90
    - Assert Performance score >= 70
    - Assert Accessibility score >= 90
    - Verify meta description present before JavaScript execution
    - Verify canonical URL present before JavaScript execution
    - Verify structured data present before JavaScript execution
    - _Requirements: Req 35_

  - [ ]* 39.2 Run Lighthouse SEO audits
    - Execute Lighthouse against test article pages
    - Generate HTML report with findings
    - Verify all assertions pass
    - _Requirements: Req 35_

- [ ] 40. Implement sitemap validation
  - [~] 40.1 Create sitemap validation test `tests/seo/sitemap.spec.ts`
    - Fetch /sitemap.xml from test server
    - Parse XML using xml2js library
    - Validate against sitemap.org XML schema
    - Verify all published articles present in sitemap
    - Count URLs, compare with database published article count
    - Verify URL format correctness
    - _Requirements: Req 17, Req 35_

  - [ ]* 40.2 Run sitemap validation tests
    - Execute sitemap test suite
    - Verify sitemap completeness and validity
    - _Requirements: Req 17, Req 35_

- [ ] 41. Test SSR metadata injection
  - [~] 41.1 Create SSR validation test `tests/ssr/metadata.spec.ts`
    - Start SSR server
    - Fetch article page HTML (disable JavaScript)
    - Parse HTML with jsdom
    - Verify <meta name="description"> present in <head>
    - Verify <link rel="canonical"> present in <head>
    - Verify <script type="application/ld+json"> present in <head>
    - Verify all metadata present before </head> tag
    - Verify window.__INITIAL_ARTICLES__ serialized in <body>
    - _Requirements: Req 19, Req 35_

  - [ ]* 41.2 Run SSR metadata tests
    - Execute SSR validation test suite
    - Verify all metadata injection working correctly
    - _Requirements: Req 19, Req 35_

- [~] 42. Checkpoint - Comprehensive E2E and SEO validation
  - Run complete Playwright E2E test suite
  - Run Lighthouse SEO audits on multiple page types
  - Verify all SEO requirements met
  - Generate test coverage report
  - Ensure all tests pass, ask the user if questions arise


### Phase 9: Production Deployment & Monitoring

- [ ] 43. Prepare production deployment scripts
  - [~] 43.1 Create deployment script `scripts/deploy-phase1.sh`
    - Stop existing server gracefully
    - Run database migrations with `supabase db push`
    - Run backfill script to populate new schema fields
    - Build application with `npm run build:ssr`
    - Start SSR server with PM2 or systemd
    - Run smoke tests on production endpoints
    - Rollback script on failures
    - _Requirements: Req 32_

  - [~] 43.2 Create rollback script `scripts/rollback-phase1.sh`
    - Stop server
    - Revert database migrations
    - Restore previous application build
    - Restart server with old version
    - Verify rollback successful
    - _Requirements: Req 32_

  - [~] 43.3 Document deployment procedures in `DEPLOYMENT.md`
    - Pre-deployment checklist
    - Step-by-step deployment instructions
    - Rollback procedures
    - Post-deployment verification
    - _Requirements: Req 32_

- [ ] 44. Set up monitoring and logging
  - [~] 44.1 Configure error logging
    - Install winston or similar logging library
    - Configure log levels: error, warn, info, debug
    - Log to file and console in production
    - Log sitemap generation errors
    - Log slug conflict resolutions
    - Log invalid canonical URL warnings
    - Log media upload failures
    - _Requirements: Req 30, Req 31_

  - [~] 44.2 Set up performance monitoring
    - Integrate with monitoring service (e.g., Datadog, New Relic)
    - Track database query performance metrics
    - Monitor SSR rendering time
    - Track cache hit/miss rates
    - Monitor rate limit violations
    - Alert on performance degradation
    - _Requirements: Req 24_

  - [~] 44.3 Configure uptime monitoring
    - Set up uptime monitoring for /sitemap.xml endpoint
    - Monitor article page response times
    - Alert on 5xx errors
    - Monitor database connection pool exhaustion
    - _Requirements: Req 30_

- [ ] 45. Submit sitemap to search engines
  - [~] 45.1 Register with Google Search Console
    - Add site property to Google Search Console
    - Verify ownership via DNS or HTML file
    - Submit /sitemap.xml URL
    - Submit /news-sitemap.xml URL
    - Monitor indexing status
    - _Requirements: Req 17, Req 18_

  - [~] 45.2 Update robots.txt
    - Create/update `public/robots.txt`
    - Add Sitemap directive: `Sitemap: https://lensainsignia.com/sitemap.xml`
    - Add Sitemap directive: `Sitemap: https://lensainsignia.com/news-sitemap.xml`
    - Allow all bots to crawl public content
    - Disallow bots from admin routes
    - _Requirements: Req 17, Req 18_

  - [~] 45.3 Verify search engine crawling
    - Monitor Google Search Console for crawl errors
    - Check for indexed pages in Google Search
    - Verify structured data in Rich Results Test
    - Monitor sitemap processing status
    - Track search impressions and clicks
    - _Requirements: Req 35_

- [~] 46. Final checkpoint - Production deployment validation
  - Deploy to production environment
  - Run smoke tests on all critical endpoints
  - Verify sitemap accessible and valid
  - Verify article pages render with complete SEO metadata
  - Monitor error logs for 24 hours
  - Check search engine indexing status after 48 hours
  - Ensure all monitoring alerts configured correctly


## Notes

### Task Organization

- Tasks are organized into 9 phases following the migration strategy: Database Schema → Services → SEO Implementation → React Components → Media → Performance → Security → Testing → Deployment
- Each phase builds incrementally on previous phases with clear checkpoints for validation
- Checkpoints ensure all tests pass before proceeding to next phase

### Optional Tasks (Testing)

- Tasks marked with `*` are optional testing tasks (unit tests, property tests, integration tests)
- These tasks validate correctness but can be skipped for faster MVP delivery
- All property-based tests explicitly reference the correctness properties from the design document
- Core implementation tasks are never marked as optional
- Testing coverage targets: Unit tests ≥ 85%, Integration tests ≥ 75%, E2E per scenarios

### Property-Based Testing

- Property tests validate universal invariants defined in design document
- Each property test explicitly annotates which property it validates and which requirements it checks
- Properties tested:
  - Property 1: Slug Uniqueness Within Category (Task 5.2)
  - Property 2: Slug Format Validity (Task 9.3)
  - Property 3: Related Articles No Self-Reference (Task 12.3)
  - Property 4: Query Performance Benchmarks (Task 29.3)
  - Property 5: Sitemap Completeness (Task 14.3)
  - Property 6: SEO Metadata Presence in SSR (Task 17.3)
- Use fast-check library for TypeScript property-based testing

### Requirements Traceability

- Each task explicitly references requirements it implements (e.g., _Requirements: Req 1, Req 2_)
- All 35 requirements from requirements.md are covered by implementation tasks
- Testing tasks reference both functional requirements and testing requirements (Req 33-35)

### Migration Strategy

- Phase 1 (Tasks 1-7): Database schema changes with backward compatibility
- Phase 2 (Tasks 8-13): Service layer implementation
- Phase 3 (Tasks 14-18): SSR and sitemap implementation
- Phase 4 (Tasks 19-24): React components and routing
- Phase 5 (Tasks 25-28): Media management
- Phase 6 (Tasks 29-32): Performance optimization
- Phase 7 (Tasks 33-37): Security hardening
- Phase 8 (Tasks 38-42): E2E testing and SEO validation
- Phase 9 (Tasks 43-46): Production deployment and monitoring

### Backward Compatibility

- Legacy article columns (author, role, date, time, category, imageUrl) maintained throughout migration
- Old ID-based route /article/:id kept functional alongside new slug-based routes
- 301 redirects from old to new URLs deferred to post-launch phase (not in this plan)
- Backfill script (Task 6.1) migrates existing data to new schema without data loss

### Tech Stack Considerations

- TypeScript used throughout (React 18, Express, Node.js)
- Supabase PostgreSQL with connection pooling and RLS
- React Router 7 for client-side routing
- React Helmet Async for SSR meta tag management
- Vite for build tooling
- Playwright for E2E testing
- fast-check for property-based testing
- Lighthouse CI for SEO auditing

### Performance Targets

- Article fetch by slug: < 50ms average (Task 29.3)
- Related articles query: < 100ms average (Task 29.3)
- Sitemap generation (1000 articles): < 500ms (Task 29.3)
- SSR rendering: < 300ms average (Task 17)
- Largest Contentful Paint (LCP): < 2.5 seconds (Task 28)
- Lighthouse SEO score: ≥ 90 (Task 39)

### Security Measures

- Input validation on all slug parameters (Task 33)
- Content sanitization with DOMPurify (Task 34)
- Canonical URL domain validation (Task 35)
- Row Level Security policies enforced (Task 36)
- Rate limiting on public endpoints (Task 31)
- MIME type validation on uploads (Task 25)

### Dependencies to Install

The following packages may need to be added during implementation:
- `express-rate-limit` - Rate limiting middleware (Task 31)
- `isomorphic-dompurify` - Content sanitization (Task 34)
- `@playwright/test` - E2E testing (Task 38)
- `xml2js` - XML parsing for sitemap validation (Task 40)
- `fast-check` - Property-based testing (Tasks 5.2, 9.3, 12.3, etc.)
- `winston` - Production logging (Task 44)

All other dependencies already exist in package.json.


## Task Dependency Graph

```json
{
  "waves": [
    {
      "id": 0,
      "tasks": ["1.1", "2.1", "3.1", "4.1", "5.1"]
    },
    {
      "id": 1,
      "tasks": ["1.2", "2.2", "2.3", "3.2", "3.3", "4.2", "5.2", "8.1", "8.2"]
    },
    {
      "id": 2,
      "tasks": ["6.1"]
    },
    {
      "id": 3,
      "tasks": ["6.2", "9.1"]
    },
    {
      "id": 4,
      "tasks": ["9.2", "9.3"]
    },
    {
      "id": 5,
      "tasks": ["9.4"]
    },
    {
      "id": 6,
      "tasks": ["9.5", "9.6"]
    },
    {
      "id": 7,
      "tasks": ["9.7", "10.1"]
    },
    {
      "id": 8,
      "tasks": ["10.2", "10.3", "10.4", "11.1"]
    },
    {
      "id": 9,
      "tasks": ["11.2", "11.3", "11.4"]
    },
    {
      "id": 10,
      "tasks": ["11.5", "12.1"]
    },
    {
      "id": 11,
      "tasks": ["12.2", "12.3"]
    },
    {
      "id": 12,
      "tasks": ["14.1"]
    },
    {
      "id": 13,
      "tasks": ["14.2", "14.3", "14.4"]
    },
    {
      "id": 14,
      "tasks": ["14.5", "15.1"]
    },
    {
      "id": 15,
      "tasks": ["15.2", "16.1"]
    },
    {
      "id": 16,
      "tasks": ["16.2", "17.1"]
    },
    {
      "id": 17,
      "tasks": ["17.2", "17.3"]
    },
    {
      "id": 18,
      "tasks": ["19.1"]
    },
    {
      "id": 19,
      "tasks": ["19.2", "20.1"]
    },
    {
      "id": 20,
      "tasks": ["20.2", "21.1"]
    },
    {
      "id": 21,
      "tasks": ["21.2", "22.1"]
    },
    {
      "id": 22,
      "tasks": ["22.2", "23.1"]
    },
    {
      "id": 23,
      "tasks": ["23.2"]
    },
    {
      "id": 24,
      "tasks": ["25.1"]
    },
    {
      "id": 25,
      "tasks": ["25.2", "25.3"]
    },
    {
      "id": 26,
      "tasks": ["25.4", "26.1"]
    },
    {
      "id": 27,
      "tasks": ["26.2", "27.1"]
    },
    {
      "id": 28,
      "tasks": ["29.1", "29.2"]
    },
    {
      "id": 29,
      "tasks": ["29.3", "30.1"]
    },
    {
      "id": 30,
      "tasks": ["30.2", "31.1"]
    },
    {
      "id": 31,
      "tasks": ["31.2", "31.3"]
    },
    {
      "id": 32,
      "tasks": ["33.1"]
    },
    {
      "id": 33,
      "tasks": ["33.2", "33.3", "34.1"]
    },
    {
      "id": 34,
      "tasks": ["34.2", "35.1"]
    },
    {
      "id": 35,
      "tasks": ["35.2", "36.1"]
    },
    {
      "id": 36,
      "tasks": ["36.2"]
    },
    {
      "id": 37,
      "tasks": ["38.1", "38.2"]
    },
    {
      "id": 38,
      "tasks": ["38.3", "39.1"]
    },
    {
      "id": 39,
      "tasks": ["39.2", "40.1"]
    },
    {
      "id": 40,
      "tasks": ["40.2", "41.1"]
    },
    {
      "id": 41,
      "tasks": ["41.2"]
    },
    {
      "id": 42,
      "tasks": ["43.1", "43.2", "43.3", "44.1", "44.2", "44.3"]
    },
    {
      "id": 43,
      "tasks": ["45.1", "45.2", "45.3"]
    }
  ]
}
```
