-- Add ad_format column to ad_sponsors for horizontal/vertical ad sizing
ALTER TABLE ad_sponsors ADD COLUMN IF NOT EXISTS ad_format text NOT NULL DEFAULT 'horizontal';

-- Valid values: 'horizontal' (728x90 Leaderboard), 'vertical' (300x250 Medium Rectangle)
COMMENT ON COLUMN ad_sponsors.ad_format IS 'Ad display format: horizontal (728x90) or vertical (300x250)';
