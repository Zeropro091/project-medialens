/**
 * Server entry point — renders the app to an HTML string on each request.
 * Pre-fetches article data from Supabase so article pages render fully on SSR.
 */
import { StrictMode } from 'react';
import { renderToString } from 'react-dom/server';
import { StaticRouter } from 'react-router-dom';
import { HelmetProvider } from 'react-helmet-async';
import { createClient } from '@supabase/supabase-js';
import { AuthProvider } from './components/AuthProvider';
import { AppSSR } from './App';

// In-memory cache for SSR article queries to avoid redundant Supabase calls on every request
let ssrCache: { data: any[]; expiry: number } | null = null;
const SSR_CACHE_TTL = 30_000; // 30 seconds

/** Fetch published articles server-side for SSR hydration. */
async function fetchArticlesSSR(): Promise<any[]> {
  // Return cached data if still fresh
  if (ssrCache && Date.now() < ssrCache.expiry) {
    console.log('[SSR] Returning cached articles (' + ssrCache.data.length + ' items)');
    return ssrCache.data;
  }

  const supabaseUrl = process.env.VITE_SUPABASE_URL || '';
  const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY || '';

  if (!supabaseUrl || !supabaseKey) {
    console.warn('[SSR] Supabase credentials missing, skipping fetch.');
    return [];
  }

  try {
    const client = createClient(supabaseUrl, supabaseKey);
    
    // Create a timeout promise
    const timeout = new Promise<any[]>((_, reject) => 
      setTimeout(() => reject(new Error('Fetch timeout')), 5000)
    );

    const fetchData = async () => {
      const { data, error } = await client
        .from('articles')
        .select('*')
        .eq('status', 'published')
        .order('createdAt', { ascending: false })
        .limit(50);

      if (error) throw error;
      return data || [];
    };

    const articles = await Promise.race([fetchData(), timeout]);

    // Populate cache
    ssrCache = { data: articles, expiry: Date.now() + SSR_CACHE_TTL };
    console.log('[SSR] Fetched & cached ' + articles.length + ' articles for ' + (SSR_CACHE_TTL / 1000) + 's');
    return articles;
  } catch (e: any) {
    console.error('[SSR] Failed to fetch articles:', e.message || e);
    // If cache exists but expired, serve stale data as a fallback
    if (ssrCache && ssrCache.data.length > 0) {
      console.log('[SSR] Serving stale cache as fallback (' + ssrCache.data.length + ' items)');
      return ssrCache.data;
    }
    return [];
  }
}

export async function render(url: string) {
  const helmetContext: Record<string, any> = {};

  // Pre-fetch articles so article detail pages render with content
  const initialArticles = await fetchArticlesSSR();

  const html = renderToString(
    <StrictMode>
      <HelmetProvider context={helmetContext}>
        <AuthProvider>
          <StaticRouter location={url}>
            <AppSSR initialArticles={initialArticles} />
          </StaticRouter>
        </AuthProvider>
      </HelmetProvider>
    </StrictMode>,
  );

  return {
    html,
    helmetContext: helmetContext.helmet,
    // Serialise initial data to inject into the page for client hydration
    initialData: JSON.stringify(initialArticles).replace(/</g, '\\u003c'),
  };
}
