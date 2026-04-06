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
-- SECTION 5: PRODUCTS TABLE (product catalog)
-- ============================================================

CREATE TABLE IF NOT EXISTS products (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW(),
  name              TEXT NOT NULL,
  slug              TEXT UNIQUE NOT NULL,
  description       TEXT,
  short_description TEXT,
  price_from        DECIMAL(10,2),
  category          TEXT NOT NULL,          -- apparel, headgear, basicpoly, stockdesigns, sublimation, design, logos, wraps
  image_url         TEXT,
  gallery           JSONB DEFAULT '[]'::jsonb,
  sizes             JSONB DEFAULT '[]'::jsonb,
  colors            JSONB DEFAULT '[]'::jsonb,
  features          JSONB DEFAULT '[]'::jsonb,
  featured          BOOLEAN DEFAULT false,
  active            BOOLEAN DEFAULT true,
  sort_order        INTEGER DEFAULT 0
);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_products_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_products_updated ON products;
CREATE TRIGGER trg_products_updated
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_products_updated_at();

-- RLS for products
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Public can read active products
CREATE POLICY "products_public_read" ON products
  FOR SELECT TO anon
  USING (active = true);

-- Authenticated users can read all products
CREATE POLICY "products_auth_read" ON products
  FOR SELECT TO authenticated
  USING (true);

-- Admin (email = usman@gmail.com) can do everything
CREATE POLICY "products_admin_insert" ON products
  FOR INSERT TO authenticated
  WITH CHECK (auth.email() = 'usman@gmail.com');

CREATE POLICY "products_admin_update" ON products
  FOR UPDATE TO authenticated
  USING (auth.email() = 'usman@gmail.com')
  WITH CHECK (auth.email() = 'usman@gmail.com');

CREATE POLICY "products_admin_delete" ON products
  FOR DELETE TO authenticated
  USING (auth.email() = 'usman@gmail.com');


-- ============================================================
-- SECTION 6: ROLE GRANTS
-- ============================================================

GRANT INSERT                        ON TABLE orders       TO anon;
GRANT INSERT                        ON TABLE contacts     TO anon;
GRANT SELECT                        ON TABLE page_content TO anon;
GRANT SELECT                        ON TABLE site_settings TO anon;
GRANT SELECT                        ON TABLE products     TO anon;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE orders        TO authenticated;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE contacts      TO authenticated;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE page_content  TO authenticated;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE media         TO authenticated;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE site_settings TO authenticated;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE products      TO authenticated;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;


-- ============================================================
-- SECTION 7: HERO SLIDES TABLE  (dynamic homepage slider)
-- ============================================================

CREATE TABLE IF NOT EXISTS hero_slides (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW(),
  title        TEXT NOT NULL,          -- main heading text
  highlight    TEXT,                   -- highlighted <span> part of the title
  subtitle     TEXT,                   -- paragraph below heading
  badges       JSONB DEFAULT '[]',    -- array of badge strings e.g. ["⚡ 24h Response","📍 Guelph"]
  bg_type      TEXT DEFAULT 'gradient',-- 'gradient' or 'image'
  bg_value     TEXT,                   -- CSS gradient string or image URL
  btn1_text    TEXT,
  btn1_link    TEXT,
  btn1_style   TEXT DEFAULT 'primary', -- 'primary' or 'white'
  btn2_text    TEXT,
  btn2_link    TEXT,
  btn2_style   TEXT DEFAULT 'white',
  image_url    TEXT,                   -- product/showcase image displayed on right side of slide
  sort_order   INTEGER DEFAULT 0,
  active       BOOLEAN DEFAULT true
);

-- Migration: add image_url if table already exists
ALTER TABLE hero_slides ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_hero_slides_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_hero_slides_updated ON hero_slides;
CREATE TRIGGER trg_hero_slides_updated
  BEFORE UPDATE ON hero_slides
  FOR EACH ROW EXECUTE FUNCTION update_hero_slides_updated_at();

-- RLS for hero_slides
ALTER TABLE hero_slides ENABLE ROW LEVEL SECURITY;

CREATE POLICY "hero_slides_public_read" ON hero_slides
  FOR SELECT TO anon
  USING (active = true);

CREATE POLICY "hero_slides_auth_read" ON hero_slides
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "hero_slides_admin_insert" ON hero_slides
  FOR INSERT TO authenticated
  WITH CHECK (auth.email() = 'usman@gmail.com');

CREATE POLICY "hero_slides_admin_update" ON hero_slides
  FOR UPDATE TO authenticated
  USING (auth.email() = 'usman@gmail.com')
  WITH CHECK (auth.email() = 'usman@gmail.com');

CREATE POLICY "hero_slides_admin_delete" ON hero_slides
  FOR DELETE TO authenticated
  USING (auth.email() = 'usman@gmail.com');

GRANT SELECT ON TABLE hero_slides TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE hero_slides TO authenticated;


-- ============================================================
-- SECTION 8: CONTACTS TABLE MIGRATION  (chat widget + admin reply)
-- ============================================================

ALTER TABLE contacts
  ADD COLUMN IF NOT EXISTS page_source  TEXT,
  ADD COLUMN IF NOT EXISTS admin_reply  TEXT,
  ADD COLUMN IF NOT EXISTS replied_at   TIMESTAMPTZ;


-- ============================================================
-- SECTION 9: FIX RLS POLICIES  (use auth.email() everywhere)
-- The old policies used auth.jwt() ->> 'email' which can break.
-- This drops ALL old policies and recreates with auth.email().
-- ============================================================

-- ---- ORDERS ----
DO $$ DECLARE pol RECORD; BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE tablename='orders' AND schemaname='public'
  LOOP EXECUTE 'DROP POLICY IF EXISTS "' || pol.policyname || '" ON orders'; END LOOP;
END $$;

CREATE POLICY "orders_public_insert"  ON orders FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "orders_user_select"    ON orders FOR SELECT TO authenticated
  USING (auth.email() = 'usman@gmail.com' OR email = auth.email() OR user_id = auth.uid());
CREATE POLICY "orders_admin_update"   ON orders FOR UPDATE TO authenticated USING (auth.email() = 'usman@gmail.com');
CREATE POLICY "orders_admin_delete"   ON orders FOR DELETE TO authenticated USING (auth.email() = 'usman@gmail.com');

-- ---- CONTACTS ----
DO $$ DECLARE pol RECORD; BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE tablename='contacts' AND schemaname='public'
  LOOP EXECUTE 'DROP POLICY IF EXISTS "' || pol.policyname || '" ON contacts'; END LOOP;
END $$;

CREATE POLICY "contacts_public_insert" ON contacts FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "contacts_admin_select"  ON contacts FOR SELECT TO authenticated USING (auth.email() = 'usman@gmail.com');
CREATE POLICY "contacts_admin_update"  ON contacts FOR UPDATE TO authenticated USING (auth.email() = 'usman@gmail.com');
CREATE POLICY "contacts_admin_delete"  ON contacts FOR DELETE TO authenticated USING (auth.email() = 'usman@gmail.com');

-- ---- PAGE CONTENT ----
DO $$ DECLARE pol RECORD; BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE tablename='page_content' AND schemaname='public'
  LOOP EXECUTE 'DROP POLICY IF EXISTS "' || pol.policyname || '" ON page_content'; END LOOP;
END $$;

CREATE POLICY "page_content_public_read" ON page_content FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "page_content_admin_all"   ON page_content FOR ALL TO authenticated
  USING (auth.email() = 'usman@gmail.com') WITH CHECK (auth.email() = 'usman@gmail.com');

-- ---- MEDIA ----
DO $$ DECLARE pol RECORD; BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE tablename='media' AND schemaname='public'
  LOOP EXECUTE 'DROP POLICY IF EXISTS "' || pol.policyname || '" ON media'; END LOOP;
END $$;

CREATE POLICY "media_admin_all" ON media FOR ALL TO authenticated
  USING (auth.email() = 'usman@gmail.com') WITH CHECK (auth.email() = 'usman@gmail.com');

-- ---- SITE SETTINGS ----
DO $$ DECLARE pol RECORD; BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE tablename='site_settings' AND schemaname='public'
  LOOP EXECUTE 'DROP POLICY IF EXISTS "' || pol.policyname || '" ON site_settings'; END LOOP;
END $$;

CREATE POLICY "settings_public_read" ON site_settings FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "settings_admin_all"   ON site_settings FOR ALL TO authenticated
  USING (auth.email() = 'usman@gmail.com') WITH CHECK (auth.email() = 'usman@gmail.com');

-- ---- PRODUCTS (re-create if needed — safe due to IF NOT EXISTS semantics) ----
DO $$ DECLARE pol RECORD; BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE tablename='products' AND schemaname='public'
  LOOP EXECUTE 'DROP POLICY IF EXISTS "' || pol.policyname || '" ON products'; END LOOP;
END $$;

CREATE POLICY "products_public_read"  ON products FOR SELECT TO anon USING (active = true);
CREATE POLICY "products_auth_read"    ON products FOR SELECT TO authenticated USING (true);
CREATE POLICY "products_admin_insert" ON products FOR INSERT TO authenticated WITH CHECK (auth.email() = 'usman@gmail.com');
CREATE POLICY "products_admin_update" ON products FOR UPDATE TO authenticated
  USING (auth.email() = 'usman@gmail.com') WITH CHECK (auth.email() = 'usman@gmail.com');
CREATE POLICY "products_admin_delete" ON products FOR DELETE TO authenticated USING (auth.email() = 'usman@gmail.com');

-- ---- STORAGE POLICIES ----
DO $$ DECLARE pol RECORD; BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE tablename='objects' AND schemaname='storage'
  LOOP EXECUTE 'DROP POLICY IF EXISTS "' || pol.policyname || '" ON storage.objects'; END LOOP;
END $$;

CREATE POLICY "storage_order_upload" ON storage.objects FOR INSERT TO anon, authenticated
  WITH CHECK (bucket_id = 'order-attachments');
CREATE POLICY "storage_order_read" ON storage.objects FOR SELECT TO anon, authenticated
  USING (bucket_id = 'order-attachments');
CREATE POLICY "storage_media_admin" ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'media' AND auth.email() = 'usman@gmail.com')
  WITH CHECK (bucket_id = 'media' AND auth.email() = 'usman@gmail.com');
CREATE POLICY "storage_media_public_read" ON storage.objects FOR SELECT TO anon
  USING (bucket_id = 'media');


-- ============================================================
-- SECTION 10: CATEGORY SECTIONS TABLE
-- Stores editable hero sections for product/service category pages.
-- ============================================================

CREATE TABLE IF NOT EXISTS category_sections (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  page_name    TEXT NOT NULL,
  section_label TEXT,
  heading      TEXT,
  description  TEXT,
  checklist    JSONB DEFAULT '[]',
  image_url    TEXT,
  btn1_text    TEXT,
  btn1_link    TEXT,
  btn2_text    TEXT,
  btn2_link    TEXT,
  active       BOOLEAN DEFAULT true,
  sort_order   INTEGER DEFAULT 0,
  updated_at   TIMESTAMPTZ DEFAULT now()
);

-- Migration: add missing columns if table already exists
ALTER TABLE category_sections ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;
ALTER TABLE category_sections ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- Remove old UNIQUE constraint on page_name (allows multiple sections per page)
ALTER TABLE category_sections DROP CONSTRAINT IF EXISTS category_sections_page_name_key;

ALTER TABLE category_sections ENABLE ROW LEVEL SECURITY;

-- Public can read active sections
CREATE POLICY "cat_sections_public_read" ON category_sections
  FOR SELECT TO anon, authenticated USING (true);

-- Admin full access
CREATE POLICY "cat_sections_admin_all" ON category_sections
  FOR ALL TO authenticated
  USING (auth.email() = 'usman@gmail.com')
  WITH CHECK (auth.email() = 'usman@gmail.com');

GRANT SELECT ON TABLE category_sections TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE category_sections TO authenticated;


-- ============================================================
-- SECTION 11: QUICK-FIX MIGRATION (April 6, 2026)
-- Run ONLY this section if you already ran Sections 1-10 before.
-- Safe to run multiple times.
-- ============================================================

-- Add sort_order + created_at to category_sections
ALTER TABLE category_sections ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;
ALTER TABLE category_sections ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE category_sections DROP CONSTRAINT IF EXISTS category_sections_page_name_key;


-- ============================================================
-- SECTION 12: NAVIGATION + CUSTOM PAGES + PAGE BLOCKS
-- Dynamic navigation, page creator, and block-based page builder.
-- ============================================================

-- Navigation menu items (replaces hard-coded NAV_ITEMS array)
CREATE TABLE IF NOT EXISTS nav_items (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label      TEXT NOT NULL,
  href       TEXT NOT NULL,
  parent_id  UUID REFERENCES nav_items(id) ON DELETE CASCADE,
  sort_order INTEGER DEFAULT 0,
  target     TEXT DEFAULT '_self',
  location   TEXT DEFAULT 'main',     -- 'main', 'footer'
  icon       TEXT,
  active     BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE nav_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "nav_items_public_read" ON nav_items
  FOR SELECT TO anon, authenticated USING (true);

CREATE POLICY "nav_items_admin_all" ON nav_items
  FOR ALL TO authenticated
  USING (auth.email() = 'usman@gmail.com')
  WITH CHECK (auth.email() = 'usman@gmail.com');

GRANT SELECT ON TABLE nav_items TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE nav_items TO authenticated;


-- Custom pages (admin-created dynamic pages)
CREATE TABLE IF NOT EXISTS custom_pages (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title            TEXT NOT NULL,
  slug             TEXT UNIQUE NOT NULL,
  description      TEXT,
  meta_description TEXT,
  template         TEXT DEFAULT 'blank',
  status           TEXT DEFAULT 'draft',   -- 'draft' or 'published'
  featured_image   TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION update_custom_pages_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_custom_pages_updated ON custom_pages;
CREATE TRIGGER trg_custom_pages_updated
  BEFORE UPDATE ON custom_pages
  FOR EACH ROW EXECUTE FUNCTION update_custom_pages_updated_at();

ALTER TABLE custom_pages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "custom_pages_public_read" ON custom_pages
  FOR SELECT TO anon
  USING (status = 'published');

CREATE POLICY "custom_pages_auth_read" ON custom_pages
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "custom_pages_admin_all" ON custom_pages
  FOR ALL TO authenticated
  USING (auth.email() = 'usman@gmail.com')
  WITH CHECK (auth.email() = 'usman@gmail.com');

GRANT SELECT ON TABLE custom_pages TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE custom_pages TO authenticated;


-- Page blocks (content builder blocks for custom pages)
CREATE TABLE IF NOT EXISTS page_blocks (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id     UUID NOT NULL REFERENCES custom_pages(id) ON DELETE CASCADE,
  block_type  TEXT NOT NULL,   -- hero, text, image-text, products, gallery, faq, cta, form, html, spacer
  content     JSONB DEFAULT '{}',
  sort_order  INTEGER DEFAULT 0,
  active      BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE page_blocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "page_blocks_public_read" ON page_blocks
  FOR SELECT TO anon, authenticated USING (true);

CREATE POLICY "page_blocks_admin_all" ON page_blocks
  FOR ALL TO authenticated
  USING (auth.email() = 'usman@gmail.com')
  WITH CHECK (auth.email() = 'usman@gmail.com');

GRANT SELECT ON TABLE page_blocks TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE page_blocks TO authenticated;
