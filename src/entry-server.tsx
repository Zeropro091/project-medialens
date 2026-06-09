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

/** Fetch published articles server-side for SSR hydration. */
async function fetchArticlesSSR(): Promise<any[]> {
  const supabaseUrl = process.env.VITE_SUPABASE_URL || '';
  const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY || '';

  if (!supabaseUrl || !supabaseKey) return [];

  try {
    const client = createClient(supabaseUrl, supabaseKey);
    const { data, error } = await client
      .from('articles')
      .select('*')
      .eq('status', 'published')
      .order('createdAt', { ascending: false })
      .limit(50);

    if (error) {
      console.error('[SSR] Supabase fetch error:', error.message);
      return [];
    }
    return data || [];
  } catch (e) {
    console.error('[SSR] Failed to fetch articles:', e);
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
