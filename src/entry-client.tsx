/**
 * Client entry point.
 *
 * - When running under the SSR server (dev:ssr / production), the server
 *   injects `<!--app-html-->` and `window.__INITIAL_ARTICLES__`, so we
 *   use hydrateRoot to attach to that pre-rendered markup.
 *
 * - When running under plain Vite dev mode (npm run dev), there is no
 *   server-rendered HTML — the root div is empty. Using hydrateRoot in
 *   that case causes the "Hydration failed" warning. We detect this and
 *   fall back to createRoot instead.
 */
import { StrictMode } from 'react';
import { createRoot, hydrateRoot } from 'react-dom/client';
import App from './App.tsx';
import './index.css';

const container = document.getElementById('root')!;

// If the server injected HTML into the root, hydrate. Otherwise mount fresh.
const hasSSRContent = container.innerHTML.trim() !== '';

// Pick up initial article data pre-fetched by the server (SSR mode only).
// When SSR content exists, default to an empty array so AppContent.loading
// stays false on both server and client (avoiding hydration mismatch).
const initialArticles: any[] | undefined = hasSSRContent
  ? ((window as any).__INITIAL_ARTICLES__ ?? [])
  : undefined;

if (hasSSRContent) {
  hydrateRoot(
    container,
    <StrictMode>
      <App initialArticles={initialArticles} />
    </StrictMode>,
  );
} else {
  createRoot(container).render(
    <StrictMode>
      <App initialArticles={initialArticles} />
    </StrictMode>,
  );
}
