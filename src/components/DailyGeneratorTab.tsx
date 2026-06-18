/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 * 
 * Daily Generator Tab — DEV ONLY
 * Scrapes Google News RSS, creates articles with fake Indonesian authors.
 * NOT for production. Do NOT push to GitHub without approval.
 */
import React, { useState } from 'react';
import { Newspaper, Loader2, CheckCircle, AlertCircle, RefreshCw, Zap, Globe, Trash2, Image as ImageIcon } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useAuth } from './AuthProvider';

const CATEGORIES = ['World', 'Politics', 'Business', 'Tech', 'Science', 'Health', 'Sports', 'Arts'];

const CATEGORY_UUID_MAP: Record<string, string> = {
  'Business':  'aaaaaaaa-0000-0000-0000-000000000001',
  'World':     'aaaaaaaa-0000-0000-0000-000000000002',
  'Tech':      'aaaaaaaa-0000-0000-0000-000000000003',
  'Science':   'aaaaaaaa-0000-0000-0000-000000000004',
  'Politics':  'aaaaaaaa-0000-0000-0000-000000000005',
  'Health':    'aaaaaaaa-0000-0000-0000-000000000006',
  'Sports':    'aaaaaaaa-0000-0000-0000-000000000007',
  'Arts':      'aaaaaaaa-0000-0000-0000-000000000008',
};

const FAKE_AUTHORS = [
  { name: 'Gavin Dewanta', role: 'Editor' },
  { name: 'Raka Mahardika', role: 'Senior Reporter' },
  { name: 'Anisa Putri Lestari', role: 'Staff Writer' },
  { name: 'Bayu Aditya Pratama', role: 'Correspondent' },
  { name: 'Sari Dewi Anggraini', role: 'Feature Writer' },
  { name: 'Made Arga Wijaya', role: 'Investigative Journalist' },
  { name: 'Dinda Paramitha', role: 'News Analyst' },
  { name: 'Rizky Ananda Putra', role: 'Foreign Correspondent' },
  { name: 'Nadia Kusuma', role: 'Digital Reporter' },
  { name: 'Arief Wicaksono', role: 'Political Analyst' },
  { name: 'Putri Maharani', role: 'Culture Editor' },
  { name: 'Fajar Nugroho', role: 'Sports Correspondent' },
  { name: 'Laras Setiawati', role: 'Health Reporter' },
  { name: 'Dimas Prasetyo', role: 'Tech Columnist' },
  { name: 'Ayu Kartika Sari', role: 'Environment Correspondent' },
];

function slugify(text: string): string {
  return text.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-').replace(/-+/g, '-').trim().slice(0, 80)
    + '-' + Math.random().toString(36).slice(2, 8);
}

function getRandomAuthor(usedNames: Set<string>) {
  const available = FAKE_AUTHORS.filter(a => !usedNames.has(a.name));
  const pool = available.length > 0 ? available : FAKE_AUTHORS;
  return pool[Math.floor(Math.random() * pool.length)];
}

interface ScrapedItem {
  title: string;
  source: string;
  link: string;
  pubDate: string;
  description: string;
}

interface CategoryResult {
  category: string;
  items: ScrapedItem[];
  selectedIndex: number;
  status: 'idle' | 'loading' | 'loaded' | 'publishing' | 'published' | 'error';
  error?: string;
  ogImage?: string | null;
}

function generateArticleContent(item: ScrapedItem, category: string): string {
  const source = item.source ? ` Originally reported by ${item.source}.` : '';
  const cleanDesc = (item.description || '')
    .replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&').replace(/&nbsp;/g, ' ')
    .replace(/<[^>]+>/g, '').trim();

  return `${item.title} represents a significant development in the ${category.toLowerCase()} sector.${source}

${cleanDesc || 'This story is developing and more details are expected to emerge in the coming hours.'}

## Key Developments

The latest reports indicate that this development has drawn attention from experts and analysts worldwide. Stakeholders from various sectors have begun weighing in on the implications of these events.

> "This is a pivotal moment that could reshape how we think about ${category.toLowerCase()} in the coming years," said an industry analyst familiar with the matter.

## What This Means

As the situation continues to unfold, observers note several important factors:

- **Immediate impact**: The effects are already being felt across related industries and communities
- **Long-term implications**: Experts suggest this could set new precedents for future developments
- **Global perspective**: International observers are closely monitoring the situation for broader implications

## Looking Ahead

While it remains to be seen how this will develop, one thing is clear: the landscape of ${category.toLowerCase()} news is evolving rapidly. Industry leaders and policymakers alike will need to adapt to these changing dynamics.

*This is a developing story. Updates will follow as more information becomes available.*`;
}

const REGIONS = [
  { id: 'us', label: '🌍 International (EN)', hl: 'en', gl: 'US', ceid: 'US:en' },
  { id: 'id', label: '🇮🇩 Indonesia (ID)', hl: 'id', gl: 'ID', ceid: 'ID:id' },
  { id: 'uk', label: '🇬🇧 United Kingdom (EN)', hl: 'en', gl: 'GB', ceid: 'GB:en' },
  { id: 'jp', label: '🇯🇵 Japan (JA)', hl: 'ja', gl: 'JP', ceid: 'JP:ja' },
  { id: 'kr', label: '🇰🇷 Korea (KO)', hl: 'ko', gl: 'KR', ceid: 'KR:ko' },
  { id: 'de', label: '🇩🇪 Germany (DE)', hl: 'de', gl: 'DE', ceid: 'DE:de' },
  { id: 'fr', label: '🇫🇷 France (FR)', hl: 'fr', gl: 'FR', ceid: 'FR:fr' },
  { id: 'es', label: '🇪🇸 Spain (ES)', hl: 'es', gl: 'ES', ceid: 'ES:es' },
];

export default function DailyGeneratorTab() {
  const { user } = useAuth();
  const [region, setRegion] = useState(REGIONS[0]);
  const [results, setResults] = useState<CategoryResult[]>(
    CATEGORIES.map(c => ({ category: c, items: [], selectedIndex: 0, status: 'idle' }))
  );
  const [globalStatus, setGlobalStatus] = useState<'idle' | 'scraping' | 'done' | 'publishing'>('idle');

  // Scrape all categories
  const scrapeAll = async () => {
    setGlobalStatus('scraping');
    const updated = [...results].map(r => ({ ...r, status: 'loading' as const, items: [], error: undefined }));
    setResults(updated);

    const promises = CATEGORIES.map(async (cat, i) => {
      try {
        const resp = await fetch(`/api/scrape-news?category=${encodeURIComponent(cat)}&hl=${region.hl}&gl=${region.gl}&ceid=${region.ceid}`);
        const data = await resp.json();
        return { index: i, items: data.items || [], status: 'loaded' as const };
      } catch (err: any) {
        return { index: i, items: [], status: 'error' as const, error: err.message };
      }
    });

    const settled = await Promise.all(promises);
    setResults(prev => {
      const next = [...prev];
      for (const s of settled) {
        next[s.index] = { ...next[s.index], items: s.items, status: s.status, error: (s as any).error, selectedIndex: 0 };
      }
      return next;
    });
    setGlobalStatus('done');
  };

  // Publish all loaded articles
  const publishAll = async () => {
    setGlobalStatus('publishing');
    const usedNames = new Set<string>();

    for (let i = 0; i < results.length; i++) {
      const r = results[i];
      if (r.status !== 'loaded' || r.items.length === 0) continue;

      setResults(prev => {
        const next = [...prev];
        next[i] = { ...next[i], status: 'publishing' };
        return next;
      });

      const item = r.items[r.selectedIndex];
      const author = getRandomAuthor(usedNames);
      usedNames.add(author.name);

      const slug = slugify(item.title);
      const content = generateArticleContent(item, r.category);
      const excerpt = (item.description || item.title).slice(0, 155);

      try {
        const now = new Date().toISOString();
        const contentArr = content.split(/\n{2,}/).filter(p => p.trim() !== '');
        const { error } = await supabase.from('articles').insert({
          title: item.title,
          subtitle: `${item.source ? 'Originally reported by ' + item.source : 'Breaking developments in ' + r.category.toLowerCase()}`,
          slug,
          author: author.name,
          role: author.role,
          category: r.category,
          category_id: CATEGORY_UUID_MAP[r.category] || null,
          author_id: user?.id || null,
          excerpt,
          contentArr,
          contentStr: content,
          imageUrl: null,
          status: 'published',
          published_at: now,
          createdAt: now,
          updatedAt: now,
          date: new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }).toUpperCase(),
          time: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
        });

        setResults(prev => {
          const next = [...prev];
          next[i] = { ...next[i], status: error ? 'error' : 'published', error: error?.message };
          return next;
        });
      } catch (err: any) {
        setResults(prev => {
          const next = [...prev];
          next[i] = { ...next[i], status: 'error', error: err.message };
          return next;
        });
      }
    }
    setGlobalStatus('done');
  };

  const loadedCount = results.filter(r => r.status === 'loaded' || r.status === 'published').length;
  const publishedCount = results.filter(r => r.status === 'published').length;

  const statusIcon = (s: string) => {
    switch (s) {
      case 'loading': case 'publishing': return <Loader2 size={14} className="animate-spin text-blue-500" />;
      case 'loaded': return <CheckCircle size={14} className="text-emerald-500" />;
      case 'published': return <CheckCircle size={14} className="text-green-600" />;
      case 'error': return <AlertCircle size={14} className="text-red-500" />;
      default: return <Globe size={14} className="text-gray-300" />;
    }
  };

  return (
    <div style={{ maxWidth: 900, margin: '0 auto', padding: '24px 16px' }}>
      {/* Header */}
      <div className="flex items-center justify-between mb-6 pb-4" style={{ borderBottom: '2px solid #111' }}>
        <div className="flex items-center gap-3">
          <Newspaper size={22} />
          <div>
            <h2 style={{ fontSize: 20, fontWeight: 700 }}>Daily Generator</h2>
            <p style={{ fontSize: 12, color: '#6b7280' }}>Scrape Google News → create 8 articles with fake authors</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <span style={{ fontSize: 11, color: '#9ca3af', background: '#fef3c7', padding: '2px 8px', borderRadius: 4, fontWeight: 600 }}>
            🔒 DEV ONLY
          </span>
        </div>
      </div>

      {/* Region selector */}
      <div className="flex items-center gap-3 mb-4 flex-wrap">
        <span style={{ fontSize: 12, fontWeight: 600, color: '#374151' }}>📡 Source Region:</span>
        <div className="flex flex-wrap gap-1.5">
          {REGIONS.map(r => (
            <button
              key={r.id}
              onClick={() => setRegion(r)}
              className="px-3 py-1.5 rounded-full text-xs font-medium transition-all"
              style={{
                border: region.id === r.id ? '2px solid #1D9E75' : '1px solid #d1d5db',
                background: region.id === r.id ? '#E1F5EE' : '#fff',
                color: region.id === r.id ? '#0F6E56' : '#6b7280',
                cursor: 'pointer',
                fontWeight: region.id === r.id ? 700 : 500,
              }}
            >
              {r.label}
            </button>
          ))}
        </div>
      </div>

      {/* Action buttons */}
      <div className="flex items-center gap-3 mb-6">
        <button
          onClick={scrapeAll}
          disabled={globalStatus === 'scraping' || globalStatus === 'publishing'}
          className="inline-flex items-center gap-2 px-5 py-2.5 rounded-lg text-sm font-bold transition-all disabled:opacity-50"
          style={{ background: '#111', color: '#fff', border: 'none', cursor: globalStatus === 'scraping' ? 'not-allowed' : 'pointer' }}
        >
          {globalStatus === 'scraping' ? <Loader2 size={16} className="animate-spin" /> : <RefreshCw size={16} />}
          {globalStatus === 'scraping' ? 'Scraping...' : '🔄 Load Daily News'}
        </button>

        {loadedCount > 0 && publishedCount < loadedCount && (
          <button
            onClick={publishAll}
            disabled={globalStatus === 'publishing'}
            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-lg text-sm font-bold transition-all disabled:opacity-50"
            style={{ background: '#1D9E75', color: '#fff', border: 'none', cursor: globalStatus === 'publishing' ? 'not-allowed' : 'pointer' }}
          >
            {globalStatus === 'publishing' ? <Loader2 size={16} className="animate-spin" /> : <Zap size={16} />}
            {globalStatus === 'publishing' ? 'Publishing...' : `⚡ Publish All (${loadedCount})`}
          </button>
        )}

        {publishedCount > 0 && (
          <span className="text-sm font-semibold" style={{ color: '#1D9E75' }}>
            ✅ {publishedCount}/{CATEGORIES.length} published
          </span>
        )}
      </div>

      {/* Category cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {results.map((r, i) => (
          <div
            key={r.category}
            className="rounded-lg overflow-hidden transition-all"
            style={{
              border: r.status === 'published' ? '2px solid #1D9E75' : r.status === 'error' ? '2px solid #ef4444' : '1px solid #e5e7eb',
              background: r.status === 'published' ? '#f0fdf4' : '#fff',
            }}
          >
            {/* Card header */}
            <div className="flex items-center justify-between px-4 py-3" style={{ borderBottom: '1px solid #e5e7eb', background: '#f9fafb' }}>
              <div className="flex items-center gap-2">
                {statusIcon(r.status)}
                <span style={{ fontSize: 13, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em' }}>{r.category}</span>
              </div>
              <span style={{ fontSize: 10, color: '#9ca3af' }}>
                {r.status === 'published' ? '✅ Published' : r.status === 'loaded' ? `${r.items.length} headlines` : r.status === 'error' ? '❌ Error' : '—'}
              </span>
            </div>

            {/* Card body */}
            <div style={{ padding: 12, minHeight: 80 }}>
              {r.status === 'idle' && (
                <div style={{ fontSize: 12, color: '#9ca3af', textAlign: 'center', paddingTop: 16 }}>
                  Click "Load Daily News" to fetch headlines
                </div>
              )}

              {r.status === 'loading' && (
                <div className="flex items-center justify-center gap-2" style={{ paddingTop: 16, fontSize: 12, color: '#6b7280' }}>
                  <Loader2 size={14} className="animate-spin" /> Fetching {r.category} news...
                </div>
              )}

              {r.status === 'error' && (
                <div style={{ fontSize: 12, color: '#ef4444', textAlign: 'center', paddingTop: 12 }}>
                  {r.error || 'Failed to fetch'}
                </div>
              )}

              {(r.status === 'loaded' || r.status === 'publishing') && r.items.length > 0 && (
                <div>
                  {/* Selected headline */}
                  <div style={{ fontSize: 14, fontWeight: 600, lineHeight: 1.4, marginBottom: 6, color: '#111' }}>
                    {r.items[r.selectedIndex]?.title}
                  </div>
                  <div style={{ fontSize: 11, color: '#6b7280', marginBottom: 8 }}>
                    via <span style={{ fontWeight: 600 }}>{r.items[r.selectedIndex]?.source || 'Unknown'}</span>
                  </div>

                  {/* Headline selector */}
                  {r.items.length > 1 && (
                    <div className="flex flex-wrap gap-1 mt-2">
                      {r.items.map((item, j) => (
                        <button
                          key={j}
                          onClick={() => {
                            setResults(prev => {
                              const next = [...prev];
                              next[i] = { ...next[i], selectedIndex: j };
                              return next;
                            });
                          }}
                          className="rounded-full transition-colors"
                          style={{
                            width: 22, height: 22, fontSize: 10, fontWeight: 600,
                            border: j === r.selectedIndex ? '2px solid #1D9E75' : '1px solid #d1d5db',
                            background: j === r.selectedIndex ? '#E1F5EE' : '#fff',
                            color: j === r.selectedIndex ? '#0F6E56' : '#6b7280',
                            cursor: 'pointer',
                          }}
                          title={item.title}
                        >
                          {j + 1}
                        </button>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {r.status === 'published' && (
                <div className="flex items-center gap-2" style={{ fontSize: 13, color: '#1D9E75', fontWeight: 600, paddingTop: 8 }}>
                  <CheckCircle size={16} /> Article published successfully
                </div>
              )}
            </div>
          </div>
        ))}
      </div>

      {/* Author pool preview */}
      <div className="mt-8 pt-6" style={{ borderTop: '1px solid #e5e7eb' }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: '0.06em', marginBottom: 10 }}>
          Fake Author Pool ({FAKE_AUTHORS.length} authors)
        </div>
        <div className="flex flex-wrap gap-1.5">
          {FAKE_AUTHORS.map(a => (
            <span key={a.name} className="inline-flex items-center gap-1.5 rounded-full" style={{ fontSize: 11, background: '#f3f4f6', color: '#374151', padding: '3px 10px', border: '1px solid #e5e7eb' }}>
              <img src={`https://api.dicebear.com/7.x/notionists/svg?seed=${a.name}`} className="w-4 h-4 rounded-full" />
              {a.name} <span style={{ color: '#9ca3af' }}>· {a.role}</span>
            </span>
          ))}
        </div>
      </div>
    </div>
  );
}
