/**
 * Database type definitions for the Lensa Insignia platform.
 *
 * These interfaces mirror the Supabase PostgreSQL schema exactly.
 * Field names use the same casing as the database columns.
 *
 * Legacy article columns (author, role, date, time, category, imageUrl) are
 * retained for backward compatibility per Req 5.8 / Req 32.1.
 */

// ---------------------------------------------------------------------------
// Shared primitives
// ---------------------------------------------------------------------------

/** ISO 8601 timestamp string, as returned by Supabase. */
type Timestamp = string;

// ---------------------------------------------------------------------------
// ArticleStatus
// ---------------------------------------------------------------------------

/**
 * Allowed values for the articles.status column.
 *
 * - 'published' — visible to the public; requires slug, category_id,
 *                 author_id, and published_at to be non-null.
 * - 'draft'     — work-in-progress, not publicly visible.
 * - 'archived'  — no longer active; kept for reference.
 */
export type ArticleStatus = 'published' | 'draft' | 'archived';

// ---------------------------------------------------------------------------
// Article
// ---------------------------------------------------------------------------

/**
 * Represents a row in the public.articles table.
 *
 * Legacy fields (marked DEPRECATED) are preserved for backward compatibility
 * with existing code that reads the old schema. New code should use the
 * corresponding relational FK columns instead.
 */
export interface Article {
  /** Primary key — stored as text (UUID cast to text). */
  id: string;

  /** Article display title. Required; max 200 characters. */
  title: string;

  /** Optional subtitle shown below the title. */
  subtitle: string | null;

  /**
   * Short summary of the article. Max 300 characters.
   * Used as meta description fallback when meta_description is absent.
   */
  excerpt: string | null;

  // -- Content storage -- //

  /** Article body as a plain text / Markdown string. */
  contentStr: string | null;

  /** Article body as an array of paragraph strings. */
  contentArr: string[] | null;

  // -- Publication state -- //

  /** Current publication state of the article. */
  status: ArticleStatus;

  // -- SEO fields (NEW) -- //

  /**
   * URL-friendly slug, unique within the same category_id scope.
   * Must match pattern: ^[a-z0-9]+(?:-[a-z0-9]+)*$
   * Required when status = 'published'.
   */
  slug: string | null;

  /** Custom SEO meta description. Recommended 150–160 characters. */
  meta_description: string | null;

  /** Comma-separated SEO keywords. */
  meta_keywords: string | null;

  /**
   * Custom canonical URL override.
   * When provided, must point to the same site domain.
   * Falls back to auto-generated canonical when invalid.
   */
  canonical_url: string | null;

  /** Timestamp when the article was first published. Required when status = 'published'. */
  published_at: Timestamp | null;

  // -- Relational FK columns (NEW) -- //

  /** FK → authors.id. Required when status = 'published'. */
  author_id: string | null;

  /** FK → categories.id. Required when status = 'published'. */
  category_id: string | null;

  /** FK → media.id — hero / featured image for the article. */
  featured_image_id: string | null;

  /**
   * FK → media.id — custom Open Graph image.
   * When set, takes precedence over featured_image_id for og:image.
   */
  og_image_id: string | null;

  // -- Row timestamps -- //

  /** Row creation timestamp. */
  createdAt: Timestamp;

  /** Row last-update timestamp. */
  updatedAt: Timestamp;

  // -- Legacy / deprecated columns (kept for backward compatibility) -- //

  /**
   * @deprecated Use author_id (FK to authors table).
   * Free-text author name from the original schema.
   */
  author: string | null;

  /**
   * @deprecated Use authors.is_staff or profiles.role.
   * Author role string from the original schema.
   */
  role: string | null;

  /**
   * @deprecated Use createdAt or published_at.
   * Publication date string from the original schema.
   */
  date: string | null;

  /**
   * @deprecated Use createdAt or published_at.
   * Publication time string from the original schema.
   */
  time: string | null;

  /**
   * @deprecated Use category_id (FK to categories table).
   * Free-text category name from the original schema.
   */
  category: string | null;

  /**
   * @deprecated Use featured_image_id (FK to media table).
   * Direct image URL from the original schema.
   */
  imageUrl: string | null;
}

// ---------------------------------------------------------------------------
// Category
// ---------------------------------------------------------------------------

/**
 * Represents a row in the public.categories table.
 * Supports self-referential hierarchical structure (max 3 levels deep).
 */
export interface Category {
  /** UUID primary key. */
  id: string;

  /** Globally unique, URL-friendly slug for routing. */
  slug: string;

  /** Display name. Required; max 100 characters. */
  name: string;

  /** Optional description used for SEO and navigation hints. */
  description: string | null;

  /**
   * FK → categories.id — parent category in the hierarchy.
   * NULL for root categories (level = 0).
   */
  parent_id: string | null;

  /**
   * Hierarchy depth level (0 = root).
   * Auto-calculated based on parent chain depth.
   * Constrained to values 0–3.
   */
  level: number;

  /** Display order within the parent category. */
  sort_order: number;

  /** Whether the category is publicly visible. */
  is_active: boolean;

  /** Custom SEO page title for the category listing page. */
  seo_title: string | null;

  /** Custom SEO meta description for the category listing page. */
  seo_description: string | null;

  /** Row creation timestamp. */
  createdAt: Timestamp;

  /** Row last-update timestamp. */
  updatedAt: Timestamp;
}

// ---------------------------------------------------------------------------
// Tag
// ---------------------------------------------------------------------------

/**
 * Represents a row in the public.tags table.
 * Tags are non-hierarchical and may be applied to multiple articles.
 */
export interface Tag {
  /** UUID primary key. */
  id: string;

  /** Globally unique, URL-friendly slug. */
  slug: string;

  /** Display name. Required; max 50 characters. */
  name: string;

  /** Optional description of what the tag represents. */
  description: string | null;

  /**
   * Denormalized count of articles currently associated with this tag.
   * Automatically maintained by a database trigger; never negative.
   */
  usage_count: number;

  /** Whether the tag is available for use and publicly visible. */
  is_active: boolean;

  /** Row creation timestamp. */
  createdAt: Timestamp;

  /** Row last-update timestamp. */
  updatedAt: Timestamp;
}

// ---------------------------------------------------------------------------
// Author
// ---------------------------------------------------------------------------

/**
 * Represents a row in the public.authors table.
 * Author records are decoupled from auth user accounts to support
 * contributors who do not have a platform login.
 */
export interface Author {
  /** UUID primary key. */
  id: string;

  /**
   * FK → profiles.id — links the author record to an authenticated user.
   * NULL for external contributors without user accounts.
   */
  profile_id: string | null;

  /** Display name. Required; max 100 characters. */
  name: string;

  /** Globally unique, URL-friendly slug for the author page. */
  slug: string;

  /** Short biography. Max 500 characters when provided. */
  bio: string | null;

  /** URL to the author's profile photo. */
  avatar_url: string | null;

  /**
   * Public contact email address.
   * Must be a valid email format when provided.
   */
  email: string | null;

  /** Twitter/X handle (without the @ prefix). */
  twitter_handle: string | null;

  /** URL to the author's LinkedIn profile. */
  linkedin_url: string | null;

  /** URL to the author's personal or professional website. */
  website_url: string | null;

  /** True for employed/staff writers; false for external contributors. */
  is_staff: boolean;

  /** Whether the author profile is publicly active. */
  is_active: boolean;

  /**
   * Denormalized count of published articles by this author.
   * Automatically maintained by a database trigger; never negative.
   */
  article_count: number;

  /** Row creation timestamp. */
  createdAt: Timestamp;

  /** Row last-update timestamp. */
  updatedAt: Timestamp;
}

// ---------------------------------------------------------------------------
// Media
// ---------------------------------------------------------------------------

/**
 * Represents a row in the public.media table.
 * Centralizes all uploaded media assets with metadata.
 */
export interface Media {
  /** UUID primary key. */
  id: string;

  /** Original filename as supplied during upload. */
  filename: string;

  /** Path within Supabase Storage (used to generate signed/public URLs). */
  storage_path: string;

  /** Publicly accessible CDN URL for the media asset. */
  public_url: string;

  /**
   * MIME type of the asset.
   * Must be one of: 'image/jpeg' | 'image/png' | 'image/webp' | 'image/gif'.
   */
  mime_type: string;

  /**
   * File size in bytes.
   * Must not exceed 10 485 760 bytes (10 MB).
   */
  file_size: number;

  /**
   * Image width in pixels.
   * Must be between 100 and 4000 when provided.
   */
  width: number | null;

  /**
   * Image height in pixels.
   * Must be between 100 and 4000 when provided.
   */
  height: number | null;

  /**
   * Accessibility alt text for the image.
   * Required for all media assets (NOT NULL in the database).
   */
  alt_text: string;

  /** Optional caption displayed beneath the image. */
  caption: string | null;

  /** Optional photo credit / attribution line. */
  credit: string | null;

  /** FK → profiles.id — the authenticated user who uploaded the asset. */
  uploaded_by: string;

  /** Timestamp when the asset was uploaded. */
  uploadedAt: Timestamp;
}

// ---------------------------------------------------------------------------
// ArticleTag (junction table)
// ---------------------------------------------------------------------------

/**
 * Represents a row in the public.article_tags junction table.
 * Encodes the many-to-many relationship between articles and tags.
 * The composite primary key (article_id, tag_id) prevents duplicates.
 */
export interface ArticleTag {
  /** FK → articles.id. Cascades delete when the article is deleted. */
  article_id: string;

  /** FK → tags.id. Cascades delete when the tag is deleted. */
  tag_id: string;

  /** Timestamp when the association was created. */
  created_at: Timestamp;
}
