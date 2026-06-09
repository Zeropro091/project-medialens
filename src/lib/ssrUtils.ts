/**
 * SSR-safe utilities for accessing browser globals.
 * These gracefully handle the server environment where window is undefined.
 */

/** The production site origin — update this to your actual domain. */
export const SITE_ORIGIN = 'https://lensainsignia.com';

/**
 * Returns the base origin — uses window.location in the browser,
 * falls back to the configured SITE_ORIGIN on the server.
 */
export function getOrigin(): string {
  if (typeof window !== 'undefined') {
    return window.location.origin;
  }
  return SITE_ORIGIN;
}

/**
 * Returns the full current URL — uses window.location in the browser,
 * falls back to SITE_ORIGIN on the server (path is provided by React Router).
 */
export function getCurrentUrl(pathname = '/'): string {
  if (typeof window !== 'undefined') {
    return window.location.origin + window.location.pathname;
  }
  return SITE_ORIGIN + pathname;
}
