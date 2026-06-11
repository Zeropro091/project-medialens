# Requirements Document

## Introduction

This document specifies the functional and non-functional requirements for Phase 1 of the Lensa Insignia news publishing platform. This phase establishes foundational SEO infrastructure and core article management capabilities including hierarchical categories, tag management, SEO-friendly URLs, comprehensive metadata, and automated sitemap generation.

The system targets content creators, editors, and readers while prioritizing search engine discoverability through server-side rendering, structured data markup, and semantic URL structures.

## Glossary

- **System**: The Lensa Insignia web application (React + TypeScript + Vite + Supabase)
- **Database**: Supabase PostgreSQL database instance
- **SSR_Engine**: Server-side rendering system (Express + entry-server.tsx)
- **Slug_Service**: URL slug generation and validation service
- **SEO_Service**: SEO metadata and structured data generation service
- **Sitemap_Generator**: Dynamic XML sitemap generation service
- **Article**: A published news article with content, metadata, and associations
- **Category**: A hierarchical content classification (max 3 levels deep)
- **Tag**: A non-hierarchical content label for many-to-many article associations
- **Structured_Data**: Schema.org JSON-LD markup embedded in HTML
- **Published_Article**: An article with status = 'published' and complete required fields

## Requirements

### Requirement 1: Database Schema - Hierarchical Categories

**User Story:** As a content editor, I want to organize articles in hierarchical categories, so that I can create logical content structures and improve navigation.

#### Acceptance Criteria

1. THE Database SHALL store categories with fields: id, slug, name, description, parent_id, level, sort_order, is_active, seo_title, seo_description, createdAt, updatedAt
2. WHEN a category is created, THE Database SHALL automatically calculate the level field based on parent chain depth
3. THE Database SHALL enforce that category slugs are globally unique across all categories
4. THE Database SHALL enforce that category names are required and maximum 100 characters
5. THE Database SHALL prevent category parent_id values that would create circular references
6. THE Database SHALL enforce a maximum hierarchy depth of 3 levels
7. WHEN parent_id is NULL, THE Database SHALL set level to 0 (root category)
8. THE Database SHALL allow sort_order values to control display sequence within parent

### Requirement 2: Database Schema - Tag Management

**User Story:** As a content editor, I want to apply multiple tags to articles, so that I can enable cross-category content discovery and improve content relationships.

#### Acceptance Criteria

1. THE Database SHALL store tags with fields: id, slug, name, description, usage_count, is_active, createdAt, updatedAt
2. THE Database SHALL enforce that tag slugs are globally unique across all tags
3. THE Database SHALL enforce that tag names are required and maximum 50 characters
4. THE Database SHALL store article-tag associations in an article_tags junction table with composite primary key (article_id, tag_id)
5. THE Database SHALL prevent duplicate article-tag associations via composite primary key constraint
6. WHEN an article-tag association is created or deleted, THE Database SHALL automatically update the tag usage_count field
7. THE Database SHALL enforce a maximum of 10 tags per article
8. WHEN an article or tag is deleted, THE Database SHALL cascade delete associated article_tags records

### Requirement 3: Database Schema - Authors

**User Story:** As a system administrator, I want to separate author information from user profiles, so that I can manage author metadata independently and support non-user contributors.

#### Acceptance Criteria

1. THE Database SHALL store authors with fields: id, profile_id, name, slug, bio, avatar_url, email, twitter_handle, linkedin_url, website_url, is_staff, is_active, article_count, createdAt, updatedAt
2. THE Database SHALL enforce that author slugs are globally unique
3. THE Database SHALL enforce that author names are required and maximum 100 characters
4. THE Database SHALL enforce that author bios are maximum 500 characters when provided
5. WHEN email is provided, THE Database SHALL validate email format
6. WHEN an article with author_id is published or unpublished, THE Database SHALL automatically update the author article_count field
7. THE Database SHALL allow profile_id to be NULL to support contributors without user accounts

### Requirement 4: Database Schema - Media Management

**User Story:** As a content editor, I want centralized media asset management, so that I can reuse images across articles and maintain proper attribution.

#### Acceptance Criteria

1. THE Database SHALL store media assets with fields: id, filename, storage_path, public_url, mime_type, file_size, width, height, alt_text, caption, credit, uploaded_by, uploadedAt
2. THE Database SHALL enforce that alt_text is required for all media assets
3. THE Database SHALL enforce that mime_type is one of: image/jpeg, image/png, image/webp, image/gif
4. THE Database SHALL enforce maximum file_size of 10485760 bytes (10MB)
5. THE Database SHALL enforce that width and height are between 100 and 4000 pixels when provided
6. THE Database SHALL store uploaded_by as foreign key reference to profiles.id

### Requirement 5: Database Schema - Enhanced Articles

**User Story:** As a content editor, I want articles to support SEO metadata, structured relationships, and slug-based URLs, so that articles are discoverable and properly organized.

#### Acceptance Criteria

1. THE Database SHALL add to articles table: slug, author_id, category_id, featured_image_id, meta_description, meta_keywords, og_image_id, canonical_url, published_at fields
2. THE Database SHALL enforce that article slug is unique within the same category_id scope
3. THE Database SHALL enforce that article slug matches pattern ^[a-z0-9]+(?:-[a-z0-9]+)*$
4. THE Database SHALL enforce that article title is required and maximum 200 characters
5. THE Database SHALL enforce that excerpt is maximum 300 characters when provided
6. THE Database SHALL enforce that meta_description is between 150-160 characters when provided
7. WHEN article status is 'published', THE Database SHALL enforce that title, slug, category_id, author_id, and published_at are all non-null
8. THE Database SHALL maintain legacy columns (author, role, date, time, category, imageUrl) for backward compatibility

### Requirement 6: Slug Generation

**User Story:** As a content editor, I want article titles automatically converted to SEO-friendly URL slugs, so that articles have clean, readable URLs without manual formatting.

#### Acceptance Criteria

1. WHEN an article title is provided, THE Slug_Service SHALL generate a slug by converting to lowercase
2. WHEN generating a slug, THE Slug_Service SHALL replace all non-alphanumeric characters with hyphens
3. WHEN generating a slug, THE Slug_Service SHALL remove leading and trailing hyphens
4. WHEN generating a slug, THE Slug_Service SHALL collapse consecutive hyphens into single hyphens
5. WHEN generating a slug, THE Slug_Service SHALL truncate to maximum 100 characters
6. THE Slug_Service SHALL ensure generated slugs match pattern ^[a-z0-9]+(?:-[a-z0-9]+)*$

### Requirement 7: Unique Slug Enforcement

**User Story:** As a content editor, I want the system to automatically resolve slug conflicts, so that each article has a unique URL within its category without manual intervention.

#### Acceptance Criteria

1. WHEN a slug already exists in the same category, THE Slug_Service SHALL append numeric suffix starting with -2
2. WHEN a slug with suffix N exists, THE Slug_Service SHALL try suffix N+1 until finding available slug
3. WHEN checking slug uniqueness for article updates, THE Slug_Service SHALL exclude the current article ID from conflict check
4. THE Slug_Service SHALL enforce maximum 100 attempts to find unique slug before throwing error
5. WHEN a unique slug is found, THE Slug_Service SHALL return the slug with or without suffix as appropriate

### Requirement 8: Article Routing

**User Story:** As a reader, I want to access articles via semantic URLs like /category/article-title, so that URLs are readable and indicate content hierarchy.

#### Acceptance Criteria

1. THE System SHALL define React Router route pattern /:category/:slug for article pages
2. WHEN route /:category/:slug is requested, THE System SHALL extract category and slug parameters
3. WHEN category parameter is provided, THE System SHALL fetch category record by slug value
4. WHEN category is found, THE System SHALL fetch article by slug within that category scope
5. WHEN article is not found or status is not 'published', THE System SHALL render 404 page with appropriate meta robots tag
6. WHEN article is found, THE System SHALL render ArticlePage component with article data

### Requirement 9: Article Data Fetching

**User Story:** As a reader, I want article pages to load with complete content and related information, so that I can read articles with full context and discover related content.

#### Acceptance Criteria

1. WHEN fetching an article by slug, THE System SHALL join with categories table to include category data
2. WHEN fetching an article by slug, THE System SHALL join with authors table to include author data
3. WHEN fetching an article by slug, THE System SHALL join with media table to include featured image data
4. WHEN fetching an article by slug, THE System SHALL query article_tags and tags tables to include all associated tags
5. WHEN article category.is_active is false, THE System SHALL treat article as not found
6. WHEN article status is not 'published', THE System SHALL treat article as not found

### Requirement 10: Related Articles Algorithm

**User Story:** As a reader, I want to see related articles at the end of each article, so that I can continue reading relevant content.

#### Acceptance Criteria

1. WHEN an article has associated tags, THE System SHALL find articles sharing the most tags with the current article
2. WHEN finding related articles by tags, THE System SHALL order results by tag overlap count descending
3. WHEN insufficient tag matches exist, THE System SHALL fill remaining slots with articles from the same category
4. WHEN finding related articles, THE System SHALL exclude the current article from results
5. WHEN finding related articles, THE System SHALL only include articles with status = 'published'
6. THE System SHALL enforce requested limit on number of related articles returned
7. WHEN ordering related articles, THE System SHALL use published_at descending as secondary sort

### Requirement 11: SEO Metadata - Article Pages

**User Story:** As a content editor, I want article pages to include complete SEO metadata, so that search engines properly index and display our content in search results.

#### Acceptance Criteria

1. WHEN rendering an article page, THE SEO_Service SHALL generate meta title in format: "{article.title} | Lensa Insignia"
2. WHEN rendering an article page, THE SEO_Service SHALL use article.meta_description if available, otherwise article.excerpt
3. WHEN generating meta description, THE SEO_Service SHALL enforce length between 150-160 characters
4. WHEN rendering an article page, THE SEO_Service SHALL generate canonical URL in format: {SITE_URL}/{category.slug}/{article.slug}
5. THE SEO_Service SHALL generate canonical URLs as absolute URLs with protocol and domain
6. WHEN custom canonical_url is provided, THE SEO_Service SHALL validate it matches site domain before using
7. WHEN custom canonical_url is invalid, THE SEO_Service SHALL use auto-generated canonical URL

### Requirement 12: Open Graph Metadata

**User Story:** As a content editor, I want articles to display correctly when shared on social media, so that shared links are attractive and include proper preview information.

#### Acceptance Criteria

1. WHEN rendering an article page, THE SEO_Service SHALL include Open Graph meta tag og:type with value "article"
2. WHEN rendering an article page, THE SEO_Service SHALL include Open Graph meta tag og:title with article title
3. WHEN rendering an article page, THE SEO_Service SHALL include Open Graph meta tag og:description with article description
4. WHEN article has featured_image_url, THE SEO_Service SHALL include Open Graph meta tag og:image with image URL
5. WHEN article has custom og_image_id, THE SEO_Service SHALL use that image for og:image instead of featured image
6. WHEN no article images exist, THE SEO_Service SHALL use default site logo for og:image
7. THE SEO_Service SHALL include og:url with canonical URL value

### Requirement 13: Twitter Card Metadata

**User Story:** As a content editor, I want articles to display correctly when shared on Twitter/X, so that shared links include proper card previews.

#### Acceptance Criteria

1. WHEN rendering an article page, THE SEO_Service SHALL include Twitter Card meta tag twitter:card with value "summary_large_image"
2. WHEN rendering an article page, THE SEO_Service SHALL include Twitter Card meta tag twitter:title with article title
3. WHEN rendering an article page, THE SEO_Service SHALL include Twitter Card meta tag twitter:description with article description
4. WHEN article has featured image, THE SEO_Service SHALL include Twitter Card meta tag twitter:image with image URL
5. THE SEO_Service SHALL include twitter:site with site Twitter handle if configured

### Requirement 14: Structured Data - NewsArticle Schema

**User Story:** As a content editor, I want articles to include Schema.org NewsArticle markup, so that search engines understand article structure and can display rich results.

#### Acceptance Criteria

1. WHEN rendering an article page, THE Structured_Data_Service SHALL generate JSON-LD with @type "NewsArticle"
2. THE Structured_Data_Service SHALL include headline property with article title
3. THE Structured_Data_Service SHALL include datePublished property with article published_at timestamp
4. THE Structured_Data_Service SHALL include dateModified property with article updatedAt timestamp
5. THE Structured_Data_Service SHALL include author property with @type "Person" and author name
6. THE Structured_Data_Service SHALL include publisher property with @type "Organization", name "Lensa Insignia", and logo
7. WHEN article has featured image, THE Structured_Data_Service SHALL include image property with image URL array
8. THE Structured_Data_Service SHALL include articleBody property with article content excerpt

### Requirement 15: Structured Data - Organization Schema

**User Story:** As a system administrator, I want organization information embedded in pages, so that search engines understand our brand identity.

#### Acceptance Criteria

1. THE Structured_Data_Service SHALL generate JSON-LD with @type "Organization"
2. THE Structured_Data_Service SHALL include name property with value "Lensa Insignia"
3. THE Structured_Data_Service SHALL include url property with site base URL
4. THE Structured_Data_Service SHALL include logo property with site logo URL
5. WHEN social media handles are configured, THE Structured_Data_Service SHALL include sameAs array with social profile URLs

### Requirement 16: Structured Data - BreadcrumbList Schema

**User Story:** As a reader, I want breadcrumb navigation reflected in search results, so that I can understand content hierarchy before clicking.

#### Acceptance Criteria

1. WHEN rendering an article page, THE Structured_Data_Service SHALL generate JSON-LD with @type "BreadcrumbList"
2. THE Structured_Data_Service SHALL include position 1 for homepage with name "Home"
3. THE Structured_Data_Service SHALL include position 2 for category with category name
4. THE Structured_Data_Service SHALL include position 3 for article with article title
5. THE Structured_Data_Service SHALL include item property with @id URL for each breadcrumb position

### Requirement 17: Sitemap Generation - Main Sitemap

**User Story:** As a system administrator, I want an automatically updated XML sitemap, so that search engines can efficiently discover and crawl all site content.

#### Acceptance Criteria

1. WHEN GET /sitemap.xml is requested, THE Sitemap_Generator SHALL return valid XML sitemap
2. THE Sitemap_Generator SHALL include homepage with priority 1.0 and changefreq "hourly"
3. THE Sitemap_Generator SHALL include all categories with is_active = true with priority 0.8
4. THE Sitemap_Generator SHALL include all articles with status = 'published' with priority 0.9
5. THE Sitemap_Generator SHALL format article URLs as {SITE_URL}/{category.slug}/{article.slug}
6. THE Sitemap_Generator SHALL include lastmod date in YYYY-MM-DD format using article updatedAt
7. THE Sitemap_Generator SHALL include static pages (about, contact, terms, privacy) with priority 0.5
8. THE Sitemap_Generator SHALL generate XML conforming to sitemap.org protocol specification

### Requirement 18: Sitemap Generation - News Sitemap

**User Story:** As a content editor, I want a separate news sitemap with recent articles, so that news aggregators and search engines can quickly discover breaking content.

#### Acceptance Criteria

1. WHEN GET /news-sitemap.xml is requested, THE Sitemap_Generator SHALL return valid news sitemap XML
2. THE Sitemap_Generator SHALL only include articles with published_at within last 48 hours
3. THE Sitemap_Generator SHALL include news:publication_date with full ISO 8601 timestamp
4. THE Sitemap_Generator SHALL include news:title with article title
5. THE Sitemap_Generator SHALL conform to Google News sitemap format specification

### Requirement 19: Server-Side Rendering

**User Story:** As a reader, I want article pages to load with complete content and SEO metadata before JavaScript executes, so that pages are fast and accessible to all users and bots.

#### Acceptance Criteria

1. WHEN a request is received for /:category/:slug, THE SSR_Engine SHALL fetch article data server-side
2. THE SSR_Engine SHALL render React components to HTML string on server
3. THE SSR_Engine SHALL inject Helmet-generated meta tags into HTML head
4. THE SSR_Engine SHALL serialize article data into window.__INITIAL_ARTICLES__ script tag
5. THE SSR_Engine SHALL return complete HTML with status 200 before JavaScript execution
6. WHEN article not found, THE SSR_Engine SHALL return 404 status with NotFoundPage HTML

### Requirement 20: Client-Side Hydration

**User Story:** As a reader, I want pages to become interactive without content flashing or re-fetching data, so that the experience is seamless.

#### Acceptance Criteria

1. WHEN SSR HTML loads in browser, THE System SHALL hydrate React components with window.__INITIAL_ARTICLES__ data
2. THE System SHALL not re-fetch article data already provided in initial state
3. THE System SHALL attach event handlers to server-rendered HTML without unmounting/remounting
4. WHEN hydration completes, THE System SHALL enable client-side navigation without full page reloads

### Requirement 21: Image Optimization

**User Story:** As a reader, I want images to load efficiently without blocking content, so that pages load quickly even on slow connections.

#### Acceptance Criteria

1. WHEN uploading images, THE System SHALL generate multiple size variants (thumbnail, medium, large)
2. THE System SHALL serve images via Supabase Storage CDN
3. THE System SHALL generate WebP format with JPEG fallback for browser compatibility
4. WHEN rendering images, THE System SHALL include explicit width and height attributes
5. THE System SHALL implement lazy loading for images below the fold
6. THE System SHALL enforce maximum file size of 10MB during upload

### Requirement 22: Performance - Database Queries

**User Story:** As a system administrator, I want efficient database queries, so that pages load quickly under heavy traffic.

#### Acceptance Criteria

1. THE Database SHALL include composite index on articles(category_id, slug) for slug lookups
2. THE Database SHALL include index on articles(status, published_at DESC) for listing queries
3. THE Database SHALL include index on article_tags(article_id) for tag relation queries
4. THE Database SHALL include index on article_tags(tag_id) for reverse tag lookups
5. WHEN fetching articles, THE System SHALL use SELECT with explicit field list instead of SELECT *
6. THE System SHALL use Supabase connection pooling with minimum 15 connections

### Requirement 23: Performance - Caching

**User Story:** As a system administrator, I want strategic caching of expensive operations, so that the system handles traffic efficiently.

#### Acceptance Criteria

1. THE System SHALL cache category list in memory for 5 minutes
2. THE System SHALL cache sitemap XML output for 15 minutes
3. WHEN article is published or updated, THE System SHALL invalidate related sitemap cache
4. THE System SHALL cache rendered HTML for static pages (about, terms, privacy)

### Requirement 24: Performance Benchmarks

**User Story:** As a system administrator, I want performance benchmarks met, so that user experience remains excellent under normal load.

#### Acceptance Criteria

1. THE System SHALL fetch article by slug in less than 50 milliseconds average
2. THE System SHALL execute related articles query in less than 100 milliseconds average
3. THE System SHALL generate sitemap for 1000 articles in less than 500 milliseconds
4. THE System SHALL complete SSR for article page in less than 300 milliseconds average
5. THE System SHALL achieve Largest Contentful Paint (LCP) under 2.5 seconds

### Requirement 25: Security - Input Validation

**User Story:** As a system administrator, I want all user inputs validated, so that the system is protected against injection attacks.

#### Acceptance Criteria

1. WHEN receiving slug parameter, THE System SHALL validate against pattern ^[a-z0-9-]+$ before database query
2. THE System SHALL use parameterized queries for all database operations
3. THE System SHALL reject slug values containing SQL keywords
4. THE System SHALL enforce maximum slug length of 100 characters
5. WHEN rendering article content, THE System SHALL sanitize HTML using DOMPurify
6. THE System SHALL validate image MIME types during upload against allowed list

### Requirement 26: Security - Access Control

**User Story:** As a content editor, I want proper access controls enforced, so that only authorized users can modify content.

#### Acceptance Criteria

1. THE System SHALL maintain existing Row Level Security (RLS) policies from RBAC migration
2. THE System SHALL allow poster role to edit and delete only their own articles
3. THE System SHALL allow admin and dev roles to edit and delete any articles
4. THE System SHALL allow public access to read articles with status = 'published' without authentication
5. THE System SHALL deny public access to articles with status = 'draft' or 'archived'

### Requirement 27: Security - Rate Limiting

**User Story:** As a system administrator, I want API endpoints rate-limited, so that the system is protected against abuse.

#### Acceptance Criteria

1. THE System SHALL limit /sitemap.xml requests to 10 per minute per IP address
2. THE System SHALL limit article fetch requests to 100 per minute per IP address
3. WHEN rate limit is exceeded, THE System SHALL return HTTP 429 status with Retry-After header

### Requirement 28: Security - Canonical URL Validation

**User Story:** As a system administrator, I want custom canonical URLs validated, so that SEO cannot be hijacked to external domains.

#### Acceptance Criteria

1. WHEN custom canonical_url is provided, THE System SHALL validate URL matches site domain
2. THE System SHALL reject canonical URLs pointing to external domains
3. WHEN custom canonical_url is invalid, THE System SHALL use auto-generated canonical URL
4. THE System SHALL log warnings when invalid custom canonical URLs are detected

### Requirement 29: Error Handling - 404 Not Found

**User Story:** As a reader, I want helpful 404 pages when content doesn't exist, so that I can find related content instead of hitting a dead end.

#### Acceptance Criteria

1. WHEN article is not found, THE System SHALL return HTTP 404 status code
2. WHEN article is not found, THE System SHALL render NotFoundPage component
3. WHEN rendering 404 page, THE System SHALL include meta robots tag with value "noindex, follow"
4. THE System SHALL suggest related articles from the requested category on 404 page
5. THE System SHALL provide site navigation links on 404 page

### Requirement 30: Error Handling - Sitemap Failures

**User Story:** As a system administrator, I want sitemap generation to fail gracefully, so that search engines receive partial data rather than errors.

#### Acceptance Criteria

1. WHEN sitemap generation fails, THE System SHALL return HTTP 500 status
2. WHEN database connection fails during sitemap generation, THE System SHALL serve fallback static sitemap with category pages only
3. THE System SHALL log sitemap generation errors for monitoring
4. THE System SHALL retry database connection on next sitemap request

### Requirement 31: Error Handling - Missing Media

**User Story:** As a reader, I want articles to display even when referenced images are missing, so that content remains accessible.

#### Acceptance Criteria

1. WHEN featured_image_id references deleted media, THE System SHALL display article without featured image
2. WHEN featured image is missing, THE System SHALL use default site logo for Open Graph image
3. THE System SHALL log warnings when articles reference missing media
4. THE System SHALL not display broken image links when media is unavailable

### Requirement 32: Migration - Backward Compatibility

**User Story:** As a system administrator, I want smooth migration from old schema, so that existing functionality continues working during transition.

#### Acceptance Criteria

1. THE Database SHALL maintain legacy columns: author, role, date, time, category, imageUrl
2. THE System SHALL support both ID-based routes (/article/:id) and slug-based routes during transition
3. THE System SHALL create 301 redirects from /article/:id to /:category/:slug after migration
4. THE System SHALL populate slug field for all existing articles during migration
5. THE System SHALL backfill author_id by matching existing author text field to authors table
6. THE System SHALL backfill category_id by matching existing category text field to categories table

### Requirement 33: Testing - Unit Test Coverage

**User Story:** As a developer, I want comprehensive unit test coverage, so that core functionality is validated and regressions are prevented.

#### Acceptance Criteria

1. THE System SHALL achieve minimum 85% line coverage for slug generation service
2. THE System SHALL achieve minimum 85% line coverage for SEO metadata service
3. THE System SHALL achieve minimum 85% line coverage for structured data service
4. THE System SHALL include unit tests for all slug generation edge cases
5. THE System SHALL include unit tests for related articles algorithm

### Requirement 34: Testing - Integration Tests

**User Story:** As a developer, I want integration tests validating end-to-end flows, so that component interactions work correctly.

#### Acceptance Criteria

1. THE System SHALL include integration tests for database migration procedures
2. THE System SHALL include integration tests for sitemap.xml endpoint returning valid XML
3. THE System SHALL include integration tests for article fetch by slug with all relations
4. THE System SHALL include integration tests for SSR rendering with complete metadata
5. THE System SHALL achieve minimum 75% coverage for integration test paths

### Requirement 35: Testing - SEO Validation

**User Story:** As a content editor, I want automated SEO validation, so that all pages meet search engine requirements.

#### Acceptance Criteria

1. THE System SHALL validate generated sitemap XML against sitemap.org schema
2. THE System SHALL achieve minimum Lighthouse SEO score of 90 for article pages
3. THE System SHALL verify all SSR-rendered pages include meta description before JavaScript execution
4. THE System SHALL verify all SSR-rendered pages include canonical URL before JavaScript execution
5. THE System SHALL verify all SSR-rendered pages include structured data before JavaScript execution
