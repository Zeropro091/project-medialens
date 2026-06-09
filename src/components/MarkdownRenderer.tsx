/**
 * MarkdownRenderer — SSR-safe wrapper around @uiw/react-md-editor Markdown.
 *
 * @uiw/react-md-editor is an ESM-only package with circular deps that crashes
 * Vite's SSR module runner. We isolate it here and render nothing on the server
 * (article content still falls back to the plain-text contentArr on SSR).
 * On the client, React.lazy picks it up after hydration.
 */
import React from 'react';

// Only import on the client — React.lazy skips this on the server side
const LazyMarkdown = React.lazy(() =>
  import('@uiw/react-md-editor').then((mod) => ({
    default: mod.default.Markdown as React.ComponentType<{ source: string }>,
  }))
);

export default function MarkdownRenderer({ source }: { source: string }) {
  const [mounted, setMounted] = React.useState(false);

  React.useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    // Server render + first client paint: plain text paragraphs
    return (
      <div className="prose prose-lg max-w-none font-serif text-ink leading-relaxed">
        {source.split('\n').filter(Boolean).map((p, i) => (
          <p key={i} className="mb-6">{p}</p>
        ))}
      </div>
    );
  }

  return (
    <React.Suspense fallback={<div className="animate-pulse h-48 bg-gray-100 rounded" />}>
      <LazyMarkdown source={source} />
    </React.Suspense>
  );
}
