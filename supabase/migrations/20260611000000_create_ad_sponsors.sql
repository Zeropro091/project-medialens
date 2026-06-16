-- Migration: Create ad_sponsors table for dev-controlled advertisements
-- Devs can manage approved sponsors, ad display duration, and frequency

-- ============================================================
-- 1. Create ad_sponsors table
-- ============================================================

CREATE TABLE IF NOT EXISTS public.ad_sponsors (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now(),
  name TEXT NOT NULL,
  image_url TEXT DEFAULT '' NOT NULL,
  target_url TEXT DEFAULT '' NOT NULL,
  is_active BOOLEAN DEFAULT false NOT NULL,
  duration_seconds INTEGER DEFAULT 10 NOT NULL,   -- how many seconds this ad displays before cycling
  frequency INTEGER DEFAULT 3 NOT NULL,             -- show on every Nth page load (1 = every time)
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- ============================================================
-- 2. Row Level Security
-- ============================================================

ALTER TABLE public.ad_sponsors ENABLE ROW LEVEL SECURITY;

-- Everyone can read active sponsors (for display on the public site)
CREATE POLICY "Sponsors public read active"
  ON public.ad_sponsors
  FOR SELECT
  USING (is_active = true);

-- Admins and devs can read all sponsors (including inactive)
CREATE POLICY "Sponsors admin/dev select all"
  ON public.ad_sponsors
  FOR SELECT
  USING (is_admin_or_dev());

-- Admins and devs can insert new sponsors
CREATE POLICY "Sponsors admin/dev insert"
  ON public.ad_sponsors
  FOR INSERT
  WITH CHECK (is_admin_or_dev());

-- Admins and devs can update sponsors
CREATE POLICY "Sponsors admin/dev update"
  ON public.ad_sponsors
  FOR UPDATE
  USING (is_admin_or_dev());

-- Admins and devs can delete sponsors
CREATE POLICY "Sponsors admin/dev delete"
  ON public.ad_sponsors
  FOR DELETE
  USING (is_admin_or_dev());

-- ============================================================
-- 3. Indexes
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_ad_sponsors_active
  ON public.ad_sponsors (is_active);
