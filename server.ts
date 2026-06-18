/**
 * SSR Express server for Lensa Insignia.
 *
 * Development:   npm run dev:ssr
 * Production:    npm run build:ssr && npm run serve
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import express from 'express';
import http from 'node:http';
import 'dotenv/config';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const isProduction = process.env.NODE_ENV === 'production';
const port = process.env.PORT || 3000;

async function createServer() {
  const app = express();

  // ── Supabase Reverse Proxy ──
  // Proxies /rest/v1, /auth/v1, /storage/v1 to the local Supabase instance
  // so external users (via Cloudflare Tunnel) can reach it.
  const SUPABASE_LOCAL = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54821';
  const supabaseProxy: express.RequestHandler = (req, res) => {
    const targetUrl = new URL(req.originalUrl, SUPABASE_LOCAL);
    const options: http.RequestOptions = {
      hostname: targetUrl.hostname,
      port: targetUrl.port,
      path: targetUrl.pathname + targetUrl.search,
      method: req.method,
      headers: { ...req.headers, host: targetUrl.host },
    };
    const proxyReq = http.request(options, (proxyRes) => {
      // Forward CORS headers for browser requests
      res.writeHead(proxyRes.statusCode || 500, {
        ...proxyRes.headers,
        'access-control-allow-origin': '*',
        'access-control-allow-headers': '*',
        'access-control-allow-methods': '*',
      });
      proxyRes.pipe(res, { end: true });
    });
    proxyReq.on('error', (err) => {
      console.error('[Supabase Proxy] Error:', err.message);
      if (!res.headersSent) res.status(502).json({ error: 'Supabase proxy error' });
    });
    req.pipe(proxyReq, { end: true });
  };
  // Handle CORS preflight
  app.options(['/rest/v1/*', '/auth/v1/*', '/storage/v1/*', '/realtime/v1/*'], (req, res) => {
    res.set({
      'access-control-allow-origin': '*',
      'access-control-allow-headers': '*',
      'access-control-allow-methods': '*',
    }).sendStatus(204);
  });
  app.use(['/rest/v1', '/auth/v1', '/storage/v1', '/realtime/v1'], supabaseProxy);

  let vite: any;

  if (!isProduction) {
    // Development: use Vite's dev server as middleware
    const { createServer: createViteServer } = await import('vite');
    vite = await createViteServer({
      server: { middlewareMode: true },
      appType: 'custom',
    });
    app.use(vite.middlewares);
  } else {
    // Production: serve pre-built static files
    const compression = (await import('compression')).default;
    const sirv = (await import('sirv')).default;
    app.use(compression());
    app.use('/assets', sirv(path.resolve(__dirname, 'dist/client/assets'), { extensions: [] }));
    app.use(sirv(path.resolve(__dirname, 'dist/client'), { extensions: [] }));
  }

  /** Robust XML escaping for sitemaps */
  function xmlEscape(str: string): string {
    return str.replace(/[&<>"']/g, (m) => ({
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&apos;'
    }[m] || m));
  }

  /** Build a minimal sitemap with static pages only (fallback when DB is unavailable). */
  function buildStaticSitemap(): string {
    const siteUrl = process.env.SITE_URL || 'http://localhost:3000';
    const CATEGORIES = ['World','Politics','Business','Tech','Science','Health','Sports','Arts','Opinion'];
    const staticPages = ['about','careers','ethics','contact','terms','privacy','cookies','accessibility','newsletters'];
    let xml = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n`;
    xml += `  <url><loc>${siteUrl}/</loc><priority>1.0</priority><changefreq>hourly</changefreq></url>\n`;
    for (const cat of CATEGORIES) xml += `  <url><loc>${siteUrl}/category/${cat.toLowerCase()}</loc><priority>0.8</priority><changefreq>daily</changefreq></url>\n`;
    for (const page of staticPages) xml += `  <url><loc>${siteUrl}/${page}</loc><priority>0.5</priority><changefreq>monthly</changefreq></url>\n`;
    xml += `</urlset>`;
    return xml;
  }

  // --- News Sitemap endpoint (Google News) — articles from last 48 hours only ---
  app.get('/news-sitemap.xml', async (_req, res) => {
    try {
      const supabaseUrl = process.env.VITE_SUPABASE_URL;
      const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY;

      if (!supabaseUrl || !supabaseKey) {
        res.header('Content-Type', 'application/xml').status(200).send(
          `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:news="http://www.google.com/schemas/sitemap-news/0.9">\n</urlset>`
        );
        return;
      }

      const { createClient } = await import('@supabase/supabase-js');
      const supabase = createClient(supabaseUrl, supabaseKey);

      // Only articles from the last 48 hours, max 1000
      const fortyEightHoursAgo = new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString();

      const { data: articles } = await supabase
        .from('articles')
        .select('id, title, "createdAt"')
        .eq('status', 'published')
        .gte('createdAt', fortyEightHoursAgo)
        .order('createdAt', { ascending: false })
        .limit(1000);

      const siteUrl = process.env.SITE_URL || 'http://localhost:3000';

      let xml = `<?xml version="1.0" encoding="UTF-8"?>\n`;
      xml += `<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:news="http://www.google.com/schemas/sitemap-news/0.9">\n`;

      if (articles && articles.length > 0) {
        for (const article of articles) {
          const pubDate = article.createdAt ? new Date(article.createdAt).toISOString() : new Date().toISOString();
          const escapedTitle = xmlEscape(article.title || '');

          xml += `  <url>\n`;
          xml += `    <loc>${siteUrl}/article/${article.id}</loc>\n`;
          xml += `    <news:news>\n`;
          xml += `      <news:publication>\n`;
          xml += `        <news:name>Lensa Insignia</news:name>\n`;
          xml += `        <news:language>en</news:language>\n`;
          xml += `      </news:publication>\n`;
          xml += `      <news:publication_date>${pubDate}</news:publication_date>\n`;
          xml += `      <news:title>${escapedTitle}</news:title>\n`;
          xml += `    </news:news>\n`;
          xml += `  </url>\n`;
        }
      }

      xml += `</urlset>`;
      res.header('Content-Type', 'application/xml').send(xml);
    } catch (e) {
      console.error('[News Sitemap] Failed to generate:', e);
      res.status(500).header('Content-Type', 'application/xml').send(
        `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:news="http://www.google.com/schemas/sitemap-news/0.9">\n</urlset>`
      );
    }
  });

  // --- Sitemap endpoint (SEO) ---
  app.get('/sitemap.xml', async (_req, res) => {
    try {
      const supabaseUrl = process.env.VITE_SUPABASE_URL;
      const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY;

      if (!supabaseUrl || !supabaseKey) {
        res.header('Content-Type', 'application/xml').send(buildStaticSitemap());
        return;
      }

      const { createClient } = await import('@supabase/supabase-js');
      const supabase = createClient(supabaseUrl, supabaseKey);

      const { data: articles } = await supabase
        .from('articles')
        .select('id, title, "createdAt"')
        .eq('status', 'published')
        .order('createdAt', { ascending: false });

      const siteUrl = process.env.SITE_URL || 'http://localhost:3000';

      let xml = `<?xml version="1.0" encoding="UTF-8"?>\n`;
      xml += `<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n`;

      xml += `  <url><loc>${siteUrl}/</loc><priority>1.0</priority><changefreq>hourly</changefreq></url>\n`;

      const CATEGORIES = ['World','Politics','Business','Tech','Science','Health','Sports','Arts','Opinion'];
      for (const cat of CATEGORIES) {
        xml += `  <url><loc>${siteUrl}/category/${cat.toLowerCase()}</loc><priority>0.8</priority><changefreq>daily</changefreq></url>\n`;
      }

      const staticPages = ['about','careers','ethics','contact','terms','privacy','cookies','accessibility','newsletters'];
      for (const page of staticPages) {
        xml += `  <url><loc>${siteUrl}/${page}</loc><priority>0.5</priority><changefreq>monthly</changefreq></url>\n`;
      }

      if (articles && articles.length > 0) {
        for (const article of articles) {
          const lastmod = article.createdAt ? new Date(article.createdAt).toISOString().split('T')[0] : '';
          xml += `  <url>\n    <loc>${siteUrl}/article/${article.id}</loc>\n    <priority>0.9</priority>\n    <changefreq>weekly</changefreq>\n`;
          if (lastmod) xml += `    <lastmod>${lastmod}</lastmod>\n`;
          xml += `  </url>\n`;
        }
      }

      xml += `</urlset>`;
      res.header('Content-Type', 'application/xml').send(xml);
    } catch (e) {
      console.error('[Sitemap] Failed to generate:', e);
      res.status(500).header('Content-Type', 'application/xml').send(buildStaticSitemap());
    }
  });

  // Catch-all: SSR render for every HTML request
  app.use('*', async (req, res) => {
    const url = req.originalUrl;
    const start = Date.now();
    console.log(`[SSR] Starting render for: ${url}`);

    // --- Simple 404 Detection Logic ---
    const CATEGORIES = ['world','politics','business','tech','science','health','sports','arts','opinion'];
    const staticPages = ['about','careers','ethics','contact','terms','privacy','cookies','accessibility','newsletters'];
    const authPages = ['login','register','profile','become-writer','dashboard','admin'];
    
    const isRoot = url === '/';
    const isCategory = url.startsWith('/category/') && CATEGORIES.includes(url.split('/')[2]);
    const isArticle = url.startsWith('/article/'); // Dynamic, assume valid pattern for now
    const isStatic = staticPages.includes(url.slice(1));
    const isAuth = authPages.includes(url.slice(1));

    const isValidRoute = isRoot || isCategory || isArticle || isStatic || isAuth;

    try {
      let template: string;
      let render: (url: string) => Promise<{ html: string; helmetContext: any; initialData: string }>;

      if (!isProduction) {
        template = fs.readFileSync(path.resolve(__dirname, 'index.html'), 'utf-8');
        template = await vite.transformIndexHtml(url, template);
        render = (await vite.ssrLoadModule('/src/entry-server.tsx')).render;
      } else {
        template = fs.readFileSync(path.resolve(__dirname, 'dist/client/index.html'), 'utf-8');
        render = (await import(pathToFileURL(path.resolve(__dirname, 'dist/server/entry-server.js')).href)).render;
      }

      console.log(`[SSR] Template & Render module ready: ${Date.now() - start}ms`);
      const { html: appHtml, helmetContext, initialData } = await render(url);
      console.log(`[SSR] RenderToString complete: ${Date.now() - start}ms`);

      // Build the inline script that seeds client-side state with SSR data
      const initialDataScript = `<script>window.__INITIAL_ARTICLES__ = ${initialData};</script>`;

      // Inject Helmet tags into <head>, replacing the static title placeholder
      let finalHtml = template;
      if (helmetContext) {
        const { title, meta, link, script } = helmetContext;
        const helmetTags = [
          title?.toString() ?? '',
          meta?.toString() ?? '',
          link?.toString() ?? '',
          script?.toString() ?? '',
        ].join('\n    ');

        finalHtml = finalHtml
          .replace('<title>Lensa Insignia</title>', helmetTags)
          .replace('<!--app-html-->', appHtml)
          .replace('</head>', `  ${initialDataScript}\n  </head>`);
      } else {
        finalHtml = finalHtml
          .replace('<!--app-html-->', appHtml)
          .replace('</head>', `  ${initialDataScript}\n  </head>`);
      }

      const duration = Date.now() - start;
      console.log(`[SSR] Total render time: ${duration}ms`);
      // Return 404 status if the route is invalid
      res.status(isValidRoute ? 200 : 404).set({ 'Content-Type': 'text/html' }).end(finalHtml);
    } catch (e: any) {
      if (!isProduction) vite?.ssrFixStacktrace(e);
      console.error(e.stack);
      res.status(500).end(e.stack);
    }
  });

  app.listen(port, () => {
    console.log(`\n🚀 Lensa Insignia SSR running at http://localhost:${port}`);
    console.log(`   Mode: ${isProduction ? 'production' : 'development'}\n`);
  });
}

createServer();
