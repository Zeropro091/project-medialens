import { createClient } from '@supabase/supabase-js';

/**
 * Resolve the Supabase URL:
 * - On the server (SSR), use the env var directly (localhost).
 * - On the client (browser), use same-origin so requests go through
 *   the Express reverse proxy, making Cloudflare Tunnel work.
 */
const rawUrl = (import.meta as any).env.VITE_SUPABASE_URL || '';
const supabaseUrl =
  typeof window !== 'undefined'
    ? window.location.origin   // browser → same-origin → Express proxy
    : rawUrl;                  // SSR → direct to local Supabase

const supabaseAnonKey = (import.meta as any).env.VITE_SUPABASE_ANON_KEY;

if (!rawUrl || !supabaseAnonKey) {
  console.warn("Supabase credentials missing in environment variables. Auth and Database operations will fail.");
}

export const supabase = createClient(supabaseUrl || '', supabaseAnonKey || '');

export enum OperationType {
  CREATE = 'create',
  UPDATE = 'update',
  DELETE = 'delete',
  LIST = 'list',
  GET = 'get',
  WRITE = 'write',
}

export function handleSupabaseError(error: any, operationType: OperationType, path: string | null) {
  const errMsg = error?.message || String(error);
  console.error(`Supabase Error (${operationType} on ${path}): `, errMsg);
  throw new Error(errMsg);
}
