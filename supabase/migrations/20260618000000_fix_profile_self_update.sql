-- Fix: Add missing RLS policy allowing users to update their own profile.
-- Without this, BecomeWriterPage and any self-update operations fail silently
-- because only admin/dev could update profiles.

-- Allow users to update their own profile row (writer application, profile edits)
CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
