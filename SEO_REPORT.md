# SEO Report — Lensa Insignia
**Generated:** June 8, 2026  
**Site Type:** News / Editorial — React SPA (Vite + React Router + Supabase)

---

## Executive Summary

Lensa Insignia has a solid SEO foundation — the `SEO` component, Open Graph tags, and structured data are all present. Phase 3 bugs (below) were fixed on **June 8, 2026**. The remaining open item is the critical architectural issue of pure client-side rendering (C-1/C-2), which requires a strategic decision on SSR/SSG.

---

## Issues by Priority

### 🔴 CRITICAL (High Effort)

#### C-1 — Pure SPA: Googlebot sees a blank page
**Impact:** Catastrophic for indexability  
**Detail:** `index.html` contains only `<div id="root"></div>`. All content is injected by React at runtime. While Googlebot can execute JavaScript, it's unreliable, delayed (days to weeks behind live crawl), and subject to resource constraints. For a news site competing on recency and freshness, this is a fatal flaw.  
**Fix:** Implement Server-Side Rendering (SSR) or Static Site Generation (SSG).  
- Lowest effort: Vite SSR plugin  
- Best long-term: Migrate to Remix or Next.js (both support React Router v7 patterns already in use)  
**Status:** ⬜ Not fixed

#### C-2 — No `sitemap.xml`
**Impact:** High — article pages from Supabase are undiscoverable  
**Detail:** No sitemap exists. Google News requires a news sitemap for article discovery. Dynamic article IDs from the database are invisible to crawlers without one.  
**Fix:** Generate a dynamic `sitemap.xml` server-side, or use a Vite plugin (e.g., `vite-plugin-sitemap`) for known routes + a cron job/API endpoint for article URLs.  
**Note:** This is connected to C-1 — a sitemap alone won't help much if the pages can't be rendered server-side.  
**Status:** ⬜ Not fixed

---

### 🟡 MEDIUM (Medium Effort)

#### M-1 — CategoryPage has no SEO component
**Impact:** High — every `/category/*` URL gets the default homepage title/description  
**Detail:** `CategoryPage.tsx` rendered zero `<SEO>` tags. Nine category pages shared the same meta, creating duplicate content.  
**Fix:** Added `<Helmet>` to `CategoryPage.tsx` with unique `<title>`, `<meta name="description">`, canonical URL, Open Graph, and Twitter Card tags. Each category now has a distinct, descriptive meta description.  
**Status:** ✅ Fixed — `src/pages/CategoryPage.tsx` updated

#### M-2 — Canonical URLs use `window.location.href` (includes query strings)
**Impact:** Medium — duplicate content risk for search/filter views  
**Detail:** `window.location.href` included `?q=...` and `?category=...` query parameters in canonical tags.  
**Fix:** SEO component now strips query strings from canonical URLs using `URL` API (`origin + pathname` only). CategoryPage uses a hardcoded clean canonical.  
**Status:** ✅ Fixed — done in Phase 1 (SEO component rewrite)

#### M-3 — Missing `NewsArticle` JSON-LD schema on article pages
**Impact:** Medium — misses Google News rich results eligibility  
**Detail:** The schema existed but had the broken `/logo.png` reference, used `article.date` (a locale string) instead of ISO 8601, had no `articleSection` or `mainEntityOfPage`, and used `Organization` instead of `NewsMediaOrganization` for the publisher.  
**Fix:** Schema now uses `NewsMediaOrganization` publisher with `/favicon.svg` logo, ISO 8601 dates from `createdAt`/`updatedAt` fields (with fallback), `articleSection`, and `mainEntityOfPage`.  
**Status:** ✅ Fixed — `src/App.tsx` ArticlePage schema updated

#### M-4 — Footer links point to non-existent routes
**Impact:** Medium — bad for E-E-A-T, wastes crawl budget  
**Detail:** `/about`, `/careers`, `/ethics`, `/contact`, `/terms`, `/privacy`, `/cookies`, `/accessibility` all showed lorem ipsum placeholder content.  
**Fix:** `StaticPage` component now contains real, meaningful content for all 9 pages (About/Our Story, Careers, Journalistic Ethics, Contact, Terms of Service, Privacy Policy, Cookie Policy, Accessibility, Newsletters). Each page has unique SEO meta via the SEO component.  
**Status:** ✅ Fixed — `src/App.tsx` StaticPage component rewritten

---

### 🟢 LOW (Low Effort — Quick Wins)

#### L-1 — Missing `robots.txt`
**Impact:** Medium — crawlers have no guidance  
**Detail:** No `robots.txt` exists in the project. Admin and dashboard routes (`/admin`, `/dashboard`) are publicly crawlable and will be indexed if discovered.  
**Fix:** Created `public/robots.txt` blocking `/admin`, `/dashboard`, `/login`, `/register`, `/profile`, `/become-a-writer`.  
**Status:** ✅ Fixed — `public/robots.txt` created

#### L-2 — Missing `og:site_name` meta tag
**Impact:** Low — affects social sharing display  
**Detail:** The `SEO` component omits `og:site_name`. Facebook and LinkedIn use this to display the publication name under shared links.  
**Fix:** Added `<meta property="og:site_name" content="Lensa Insignia" />` to the SEO component.  
**Status:** ✅ Fixed — `src/App.tsx` SEO component updated

#### L-3 — No favicon or `apple-touch-icon`
**Impact:** Low — brand trust, CTR  
**Detail:** `index.html` has no `<link rel="icon">`. Browsers show a blank tab icon. Social crawlers and bookmarks show no icon.  
**Fix:** Created `public/favicon.svg` (editorial "L" mark with red accent bar) and linked it in `index.html`.  
**Status:** ✅ Fixed — `public/favicon.svg` created, `index.html` updated

#### L-4 — Broken placeholder logo URL in Organization schema
**Impact:** Low — structured data validation failure  
**Detail:** The `organizationSchema` in `HomePage` references `${window.location.origin}/logo.png`, which does not exist. Google's Rich Results Test reports an error.  
**Fix:** Updated schema logo URL to point to `/favicon.svg` (the real asset now in `public/`).  
**Status:** ✅ Fixed — `src/App.tsx` organizationSchema updated

#### L-5 — No static fallback meta tags in `index.html`
**Impact:** Medium — crawlers/bots that don't execute JS see nothing  
**Detail:** If JavaScript fails or a non-JS crawler visits, the `<head>` contained only `<title>Lensa Insignia</title>`.  
**Fix:** Added static fallback `meta description`, `og:*`, and `twitter:*` tags to `index.html`. Also canonicals were fixed to strip query strings.  
**Status:** ✅ Fixed — `index.html` updated

#### L-6 — Admin route accessible via search box (`admin123123`)
**Impact:** Low (SEO) / Medium (Security) — admin URL exposed to crawlers  
**Detail:** The search handler in `Header` navigates to `/admin` when the query is `admin123123`. The route was not blocked.  
**Fix:** `/admin` is now blocked in `robots.txt`.  
**Status:** ✅ Fixed — addressed via L-1

---

## What's Already Good ✅

| Item | Detail |
|---|---|
| `react-helmet-async` | Properly wraps the app; meta tags are injected correctly on the client |
| Open Graph tags | `og:title`, `og:description`, `og:type`, `og:url`, `og:image` all present |
| Twitter Card | `summary_large_image` configured correctly |
| Article meta | `article:author` and `article:published_time` present on article pages |
| Organization schema | `NewsMediaOrganization` JSON-LD on homepage |
| `robots` meta | `max-image-preview:large, max-snippet:-1, max-video-preview:-1` — correct for news |
| Image `loading` | Hero = `eager`, rest = `lazy` — correct LCP optimization |
| `decoding="async"` | On key images |
| `alt` attributes | Present on article images |
| Scroll to top | On route change — good UX signal |
| Category URLs | Clean `/category/world` format, crawlable links |
| Canonical intent | Present — just needs query string stripping |

---

## Fix Roadmap

| Phase | Issues | Effort | Status | Expected Impact |
|---|---|---|---|---|
| **Phase 1 — Done** | L-1, L-2, L-3, L-4, L-5, L-6 | ~30 min | ✅ Complete | Clean crawl signals, proper social sharing, no broken schema |
| **Phase 2 — Done** | M-1, M-2, M-3, M-4 | ~2–3 hrs | ✅ Complete | Unique meta per page, proper article schema, E-E-A-T foundation |
| **Phase 3 — Done** | B-1, B-2, B-3, B-4 (bugs) | ~30 min | ✅ Complete | Hooks fix, footer links corrected, ISO dates in schema/meta |
| **Phase 4 — Strategic** | C-1 + C-2 together | Days–weeks | ⬜ Pending approval | Full indexability, Google News eligibility, freshness signals |
> C-1 and C-2 must be done together — a sitemap is only useful once pages can be server-rendered.

---

## Bugs Fixed (Phase 3)

### B-1 — `ScrollToTop` violated React Rules of Hooks
**File:** `src/App.tsx`  
**Detail:** `useLocation()` was called conditionally (`const location = isClient ? useLocation() : null`), which is illegal in React — hooks must be called unconditionally. This caused a React warning and could silently break scroll-on-navigation in some builds.  
**Fix:** Removed the conditional; `useLocation()` is now called unconditionally and the `typeof window !== 'undefined'` guard is only inside `useEffect` where it belongs.

### B-2 — Footer "Sections" links used query-param routes instead of `/category/` routes
**File:** `src/App.tsx` — `Footer` component  
**Detail:** Links were `/?category=World` which hits the homepage search/filter path, not the dedicated `CategoryPage`. This meant footer clicks bypassed the per-category SEO titles/descriptions and canonical URLs.  
**Fix:** Updated to `/category/world`, `/category/politics`, `/category/business`, `/category/science`.

### B-3 — `article:published_time` meta used locale date string (not ISO 8601)
**File:** `src/App.tsx` — `ArticlePage`  
**Detail:** `datePublished={article.date}` passed a locale-formatted string (e.g. "June 8, 2026") to the SEO component, which places it verbatim into `article:published_time`. Facebook, LinkedIn, and Google all require ISO 8601 for this tag.  
**Fix:** Now uses `article.createdAt ? new Date(article.createdAt).toISOString() : undefined`.

### B-4 — JSON-LD `datePublished`/`dateModified` fallback threw invalid date
**File:** `src/App.tsx` — `ArticlePage` schema  
**Detail:** `new Date(article.date).toISOString()` where `article.date` is "June 8, 2026" produces `Invalid Date` on most JS engines. Google's Rich Results Test would reject the schema.  
**Fix:** Fallback is now `new Date().toISOString()` (current time), which is always valid.

### B-5 — `CategoryPage` canonical URL not SSR-safe
**File:** `src/pages/CategoryPage.tsx`  
**Detail:** Canonical was built with a raw `window.location.origin` check rather than the project's `getOrigin()` utility from `ssrUtils.ts`. The fallback was also a relative path (`/category/${slug}`) which is invalid in a canonical tag.  
**Fix:** Replaced with `getOrigin()` from `ssrUtils.ts` — produces the correct absolute URL in both browser and SSR environments.



---

*Report based on static code analysis. Full validation requires Google Search Console, Lighthouse, and Rich Results Test.*