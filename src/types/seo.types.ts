/**
 * SEO type definitions for the article system.
 * Covers Open Graph, Twitter Cards, structured data, breadcrumbs, and sitemaps.
 */

export interface OpenGraphData {
  type: string;
  title: string;
  description: string;
  image: string | null;
  url: string;
  siteName: string;
}

export interface TwitterCardData {
  card: 'summary' | 'summary_large_image';
  title: string;
  description: string;
  image: string | null;
  site: string;
}

export interface SEOMetadata {
  title: string;
  description: string;
  canonical: string;
  openGraph: OpenGraphData;
  twitter: TwitterCardData;
  structuredData: object | object[];
}

export interface BreadcrumbItem {
  name: string;
  url: string;
  position: number;
}

export interface SitemapEntry {
  loc: string;
  lastmod: string;
  priority: number;
  changefreq: 'always' | 'hourly' | 'daily' | 'weekly' | 'monthly' | 'yearly' | 'never';
}
