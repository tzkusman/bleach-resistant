-- ============================================================
-- supabase-setup.sql
-- Bleach Resistant — Full Database Setup
-- Run this entire file in the Supabase SQL Editor:
-- https://supabase.com/dashboard/project/dbppxzkkgdtnmikkviyt/sql/new
-- ============================================================


-- ============================================================
-- SECTION 1: CORE TABLES (initial setup)
-- ============================================================

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  name          TEXT,
  email         TEXT,
  phone         TEXT,
  item_type     TEXT,
  quantity      TEXT,
  deadline      TEXT,
  design_notes  TEXT,
  status        TEXT DEFAULT 'new'
);

-- Contacts table
CREATE TABLE IF NOT EXISTS contacts (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  name       TEXT,
  email      TEXT,
  phone      TEXT,
  message    TEXT,
  status     TEXT DEFAULT 'new'
);

-- Page content overrides (visual editor)
CREATE TABLE IF NOT EXISTS page_content (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  page_name        TEXT NOT NULL,
  element_selector TEXT NOT NULL,
  content_type     TEXT,
  content_value    TEXT,
  updated_at       TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (page_name, element_selector)
);

-- Media library
CREATE TABLE IF NOT EXISTS media (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  name       TEXT,
  url        TEXT,
  path       TEXT,
  size       BIGINT,
  mime_type  TEXT,
  bucket     TEXT
);

-- Site settings
CREATE TABLE IF NOT EXISTS site_settings (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key        TEXT UNIQUE NOT NULL,
  value      TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default settings
INSERT INTO site_settings (key, value) VALUES
  ('site_name',       'Bleach Resistant'),
  ('tagline',         'Custom Sublimation Printing'),
  ('contact_email',   'bleachresistant@gmail.com'),
  ('contact_phone',   ''),
  ('address',         'Guelph, Ontario, Canada'),
  ('instagram_url',   ''),
  ('facebook_url',    ''),
  ('tiktok_url',      ''),
  ('twitter_url',     '')
ON CONFLICT (key) DO NOTHING;


-- ============================================================
-- SECTION 2: ORDER TABLE MIGRATION (April 4, 2026)
-- Adds all new columns for the comprehensive order form.
-- Safe to run multiple times (uses IF NOT EXISTS).
-- ============================================================

ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS first_name     TEXT,
  ADD COLUMN IF NOT EXISTS last_name      TEXT,
  ADD COLUMN IF NOT EXISTS company        TEXT,
  ADD COLUMN IF NOT EXISTS city           TEXT,
  ADD COLUMN IF NOT EXISTS country        TEXT,
  ADD COLUMN IF NOT EXISTS service_type   TEXT,
  ADD COLUMN IF NOT EXISTS sizes          TEXT,
  ADD COLUMN IF NOT EXISTS colors         TEXT,
  ADD COLUMN IF NOT EXISTS urgency        TEXT,
  ADD COLUMN IF NOT EXISTS budget_range   TEXT,
  ADD COLUMN IF NOT EXISTS attachment_url TEXT,
  ADD COLUMN IF NOT EXISTS vehicle_model  TEXT,
  ADD COLUMN IF NOT EXISTS design_format  TEXT,
  ADD COLUMN IF NOT EXISTS source         TEXT,
  ADD COLUMN IF NOT EXISTS source_page    TEXT,
  ADD COLUMN IF NOT EXISTS user_id        UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- Fix quantity column type from INTEGER to TEXT (stores ranges like "6-10")
ALTER TABLE orders
  ALTER COLUMN quantity TYPE TEXT USING quantity::TEXT;


-- ============================================================
-- SECTION 3: STORAGE BUCKETS
-- ============================================================

-- Bucket for order form file attachments
INSERT INTO storage.buckets (id, name, public)
  VALUES ('order-attachments', 'order-attachments', true)
  ON CONFLICT DO NOTHING;

-- Bucket for media library
INSERT INTO storage.buckets (id, name, public)
  VALUES ('media', 'media', true)
  ON CONFLICT DO NOTHING;


-- ============================================================
-- SECTION 4: ROW LEVEL SECURITY POLICIES
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE orders       ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts     ENABLE ROW LEVEL SECURITY;
ALTER TABLE page_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE media        ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;

-- ---- ORDERS ----
-- Drop existing policies (clean slate)
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname FROM pg_policies WHERE tablename = 'orders' AND schemaname = 'public'
  LOOP
    EXECUTE 'DROP POLICY IF EXISTS "' || pol.policyname || '" ON orders';
  END LOOP;
END $$;

-- Anyone (guest or logged-in) can submit an order
CREATE POLICY "public_insert_orders"
  ON orders FOR INSERT
  WITH CHECK (true);

-- Only admin can view orders
CREATE POLICY "admin_select_orders"
  ON orders FOR SELECT
  TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- Only admin can update order status
CREATE POLICY "admin_update_orders"
  ON orders FOR UPDATE
  TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- Only admin can delete orders
CREATE POLICY "admin_delete_orders"
  ON orders FOR DELETE
  TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- ---- CONTACTS ----
DROP POLICY IF EXISTS "public_insert_contacts" ON contacts;
DROP POLICY IF EXISTS "admin_select_contacts"  ON contacts;
DROP POLICY IF EXISTS "admin_update_contacts"  ON contacts;
DROP POLICY IF EXISTS "admin_delete_contacts"  ON contacts;

CREATE POLICY "public_insert_contacts"
  ON contacts FOR INSERT
  WITH CHECK (true);

CREATE POLICY "admin_select_contacts"
  ON contacts FOR SELECT
  TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com');

CREATE POLICY "admin_update_contacts"
  ON contacts FOR UPDATE
  TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com');

CREATE POLICY "admin_delete_contacts"
  ON contacts FOR DELETE
  TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- ---- PAGE CONTENT ----
DROP POLICY IF EXISTS "public_read_page_content"  ON page_content;
DROP POLICY IF EXISTS "admin_write_page_content"  ON page_content;

CREATE POLICY "public_read_page_content"
  ON page_content FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "admin_write_page_content"
  ON page_content FOR ALL
  TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com')
  WITH CHECK (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- ---- MEDIA ----
DROP POLICY IF EXISTS "admin_all_media" ON media;

CREATE POLICY "admin_all_media"
  ON media FOR ALL
  TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com')
  WITH CHECK (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- ---- SITE SETTINGS ----
DROP POLICY IF EXISTS "public_read_settings" ON site_settings;
DROP POLICY IF EXISTS "admin_write_settings"  ON site_settings;

CREATE POLICY "public_read_settings"
  ON site_settings FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "admin_write_settings"
  ON site_settings FOR ALL
  TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com')
  WITH CHECK (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- ---- STORAGE POLICIES ----
DROP POLICY IF EXISTS "Anyone can upload order attachments" ON storage.objects;
DROP POLICY IF EXISTS "Public can view order attachments"   ON storage.objects;
DROP POLICY IF EXISTS "Admin can manage media"              ON storage.objects;

CREATE POLICY "Anyone can upload order attachments"
  ON storage.objects FOR INSERT
  TO anon, authenticated
  WITH CHECK (bucket_id = 'order-attachments');

CREATE POLICY "Public can view order attachments"
  ON storage.objects FOR SELECT
  TO anon, authenticated
  USING (bucket_id = 'order-attachments');

CREATE POLICY "Admin can manage media"
  ON storage.objects FOR ALL
  TO authenticated
  USING (bucket_id = 'media' AND auth.jwt() ->> 'email' = 'usman@gmail.com')
  WITH CHECK (bucket_id = 'media' AND auth.jwt() ->> 'email' = 'usman@gmail.com');


-- ============================================================
-- SECTION 5: ROLE GRANTS
-- ============================================================

GRANT INSERT                        ON TABLE orders       TO anon;
GRANT INSERT                        ON TABLE contacts     TO anon;
GRANT SELECT                        ON TABLE page_content TO anon;
GRANT SELECT                        ON TABLE site_settings TO anon;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE orders        TO authenticated;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE contacts      TO authenticated;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE page_content  TO authenticated;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE media         TO authenticated;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE site_settings TO authenticated;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
