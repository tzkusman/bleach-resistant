-- ============================================================
-- supabase-migration-blog.sql
-- Bleach Resistant — Blog System + Sublimation Services
-- Run this in the Supabase SQL Editor AFTER supabase-setup.sql
-- ============================================================


-- ============================================================
-- SECTION 1: SUBLIMATION SERVICES TABLE
-- Stores detailed service pages for sublimation printing subcategories
-- (Lawn Care, Pressure Washing, Pool Cleaning, HVAC, etc.)
-- ============================================================

CREATE TABLE IF NOT EXISTS sublimation_services (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW(),
  title            TEXT NOT NULL,
  slug             TEXT UNIQUE NOT NULL,
  meta_description TEXT,
  -- Hero section
  hero_title       TEXT NOT NULL,
  hero_highlight   TEXT,            -- colored accent text in title
  hero_subtitle    TEXT,
  -- Main content (image + text layout)
  main_image       TEXT,            -- service image URL
  main_heading     TEXT,
  main_description TEXT,            -- rich text / HTML description
  -- Checklist / features
  checklist        JSONB DEFAULT '[]'::jsonb,  -- ["Fast Delivery","100% Polyester",...]
  -- CTA buttons
  btn1_text        TEXT DEFAULT 'Order Today',
  btn1_link        TEXT DEFAULT 'order.html',
  btn2_text        TEXT DEFAULT 'Call Us',
  btn2_link        TEXT DEFAULT 'tel:',
  -- Additional sections
  why_heading      TEXT,
  why_description  TEXT,
  why_features     JSONB DEFAULT '[]'::jsonb,  -- [{title, description}]
  -- FAQ section
  faqs             JSONB DEFAULT '[]'::jsonb,  -- [{question, answer}]
  -- Gallery
  gallery          JSONB DEFAULT '[]'::jsonb,  -- ["url1","url2",...]
  -- SEO & display
  sort_order       INTEGER DEFAULT 0,
  active           BOOLEAN DEFAULT true,
  featured         BOOLEAN DEFAULT false
);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_sublimation_services_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sublimation_services_updated ON sublimation_services;
CREATE TRIGGER trg_sublimation_services_updated
  BEFORE UPDATE ON sublimation_services
  FOR EACH ROW EXECUTE FUNCTION update_sublimation_services_updated_at();

-- RLS
ALTER TABLE sublimation_services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sub_services_public_read" ON sublimation_services
  FOR SELECT TO anon USING (active = true);

CREATE POLICY "sub_services_auth_read" ON sublimation_services
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "sub_services_admin_insert" ON sublimation_services
  FOR INSERT TO authenticated
  WITH CHECK (auth.email() = 'usman@gmail.com');

CREATE POLICY "sub_services_admin_update" ON sublimation_services
  FOR UPDATE TO authenticated
  USING (auth.email() = 'usman@gmail.com')
  WITH CHECK (auth.email() = 'usman@gmail.com');

CREATE POLICY "sub_services_admin_delete" ON sublimation_services
  FOR DELETE TO authenticated
  USING (auth.email() = 'usman@gmail.com');

GRANT SELECT ON TABLE sublimation_services TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE sublimation_services TO authenticated;


-- ============================================================
-- SECTION 2: SEED SUBLIMATION SERVICES DATA
-- Pre-populate with 7 service categories
-- ============================================================

INSERT INTO sublimation_services (title, slug, meta_description, hero_title, hero_highlight, hero_subtitle, main_heading, main_description, checklist, why_heading, why_description, why_features, faqs, sort_order) VALUES

-- 1) Lawn Care Shirts
('Lawn Care Shirts', 'lawn-care-shirts',
 'Custom sublimated lawn care shirts. Durable, breathable, professional uniforms for landscaping and lawn service companies.',
 'Custom Lawn Care Shirt', 'Design Made Easy',
 'Professional sublimated uniforms built for landscaping crews who work hard in the sun all day.',
 'Turn Your Lawn Care Brand Into a Walking Billboard',
 'Custom sublimated lawn care shirts are designed for professionals who spend long hours working outdoors in challenging conditions. Made from lightweight, breathable 100% polyester fabric 180 to 200 GSM quality, these shirts help your crew stay cool, comfortable, and looking professional throughout the day. Whether your design is simple or bold, sublimation printing delivers clean details and vibrant colors that give your team a polished, professional look.

Full sublimation printing allows your artwork, logos, and branding to become part of the fabric rather than sitting on top of it. This means the shirts will not crack, peel, or fade, even after frequent washing and exposure to sunlight, dirt, and chemicals. Built for durability and daily use, these sublimated lawn care shirts provide a reliable uniform solution that supports both performance and long-term brand visibility.',
 '["Fast Delivery","100% Polyester & UV Resistant Fabric","Dye Sublimation Shirts","Unlimited Revisions","Free Shipping"]',
 'Why Choose Sublimated Lawn Care Shirts?',
 'Your crew represents your brand on every job site. Make sure they look the part.',
 '[{"title":"UV & Fade Resistant","description":"Colors stay vibrant even after weeks of sun exposure. No cracking or peeling."},{"title":"Moisture Wicking","description":"Keeps your team cool and dry during long outdoor shifts in summer heat."},{"title":"Full Brand Coverage","description":"Edge-to-edge printing covers the entire shirt. Your logo, phone number, and branding on every panel."},{"title":"Professional Image","description":"Matching uniforms build trust with homeowners and property managers."}]',
 '[{"question":"What fabric are lawn care shirts made from?","answer":"All shirts are 100% polyester fabric, 180-200 GSM weight. Lightweight, breathable, and built for outdoor work."},{"question":"Will the print fade in the sun?","answer":"No. Sublimation ink bonds with the polyester fibers at a molecular level, making it completely resistant to UV fading, washing, and chemicals."},{"question":"What is the minimum order quantity?","answer":"Our minimum order is just 1 shirt. No minimums, no setup fees."},{"question":"How long does production take?","answer":"Standard production is 5-7 business days. Rush orders available for 2-3 day turnaround."},{"question":"Can I include my phone number and website on the shirt?","answer":"Absolutely! You can put anything on the shirt — logos, phone numbers, website, license numbers, social media handles, and more."}]',
 1),

-- 2) Pressure Washing Shirts
('Pressure Washing Shirts', 'pressure-washing-shirts',
 'Custom sublimated pressure washing shirts. Chemical resistant, durable uniforms for power washing companies.',
 'Custom Pressure Washing Shirt', 'Ideas Into Reality',
 'Durable sublimated uniforms designed for power washing professionals who need shirts that can handle anything.',
 'Turn Pressure Washing Shirt Ideas Into Reality',
 'Custom sublimated pressure washing shirts are designed for professionals who work with high-pressure equipment and chemical solutions daily. Made from lightweight, breathable 100% polyester fabric 180 to 200 GSM quality, these shirts help technicians stay cool, comfortable, and presentable throughout the day. Whether your design idea is simple or bold, sublimation printing delivers clean details and vibrant colors that give your team a polished, professional look.

Full sublimation printing allows your artwork, logos, and branding to become part of the fabric rather than sitting on top of it. This means the shirts will not crack, peel, or fade, even after frequent washing and exposure to cleaning chemicals and water. Built for durability and daily use, these sublimated pressure washing shirts provide a reliable uniform solution that supports both performance and long-term brand visibility.',
 '["Fast Delivery","100% Polyester & Chemical Resistant Fabric","Dye Sublimation Shirts","Unlimited Revisions","Free Shipping"]',
 'Why Choose Sublimated Pressure Washing Shirts?',
 'Your team handles tough jobs — your uniforms should be just as tough.',
 '[{"title":"Chemical Resistant","description":"Sublimation ink is bonded into the fabric. Bleach, detergents, and cleaning chemicals won''t damage the print."},{"title":"Water Resistant Print","description":"Unlike screen printing, sublimated prints don''t absorb water or become heavy when wet."},{"title":"Professional Branding","description":"Full coverage printing puts your company name, logo, and contact info on every panel of the shirt."},{"title":"Comfort in Heat","description":"Moisture-wicking polyester keeps your crew comfortable during hot, physical work."}]',
 '[{"question":"Will bleach or chemicals damage the print?","answer":"No. Sublimation ink becomes part of the polyester fiber, so it cannot be bleached out, dissolved, or damaged by cleaning chemicals."},{"question":"Can I order just a few shirts?","answer":"Yes! We have no minimum order quantity. Order 1 shirt or 100 — same quality, same pricing structure."},{"question":"What information can I put on the shirts?","answer":"Anything you want — company logo, phone number, website, ''Before & After'' messaging, license/insurance info, social handles, etc."},{"question":"Do you offer design services?","answer":"Yes! Our in-house graphic design team can create your shirt design from scratch or refine your existing artwork."}]',
 2),

-- 3) Christmas Shirts
('Christmas Shirts', 'christmas-shirts',
 'Custom sublimated Christmas and holiday shirts. Full-color festive designs for teams, events, and family gatherings.',
 'Custom Christmas Shirt', 'Designs for Every Occasion',
 'Vibrant, full-color sublimated holiday shirts perfect for team events, family gatherings, and seasonal promotions.',
 'Make This Holiday Season Unforgettable With Custom Shirts',
 'Custom sublimated Christmas shirts bring holiday spirit to life with vibrant, full-color designs that cover every inch of the garment. Made from soft, comfortable 100% polyester fabric 180 to 200 GSM quality, these shirts are perfect for company holiday parties, family photo sessions, church events, team celebrations, and seasonal retail promotions. Unlike traditional printed holiday shirts, sublimation delivers photographic quality with unlimited colors.

Full sublimation printing allows your festive artwork, photos, and holiday branding to become part of the fabric rather than sitting on top of it. This means the shirts will not crack, peel, or fade, even after washing. The print feels smooth to the touch — no thick, rubbery ink layers. These shirts are as comfortable as they are eye-catching, making them the perfect way to celebrate the season in style.',
 '["Fast Delivery","100% Polyester & Soft Fabric","Full Color Photo Quality","Unlimited Revisions","Free Shipping"]',
 'Why Choose Sublimated Christmas Shirts?',
 'Go beyond basic screen-printed holiday shirts with full photographic quality sublimation.',
 '[{"title":"Unlimited Colors","description":"Print complex gradients, photographs, and intricate holiday designs with no extra cost per color."},{"title":"Photo Quality","description":"Sublimation reproduces photographic detail — perfect for family photos, intricate patterns, and detailed artwork."},{"title":"Soft & Comfortable","description":"No thick ink layers. The print is part of the fabric, so the shirt stays soft and breathable."},{"title":"Great for Groups","description":"Perfect for matching family shirts, company parties, team events, and holiday fundraisers."}]',
 '[{"question":"Can I use actual photographs on the shirt?","answer":"Yes! Sublimation printing supports full photographic quality. Family photos, pet photos, and detailed artwork all print beautifully."},{"question":"Is there a minimum order for holiday shirts?","answer":"No minimum! Order 1 shirt for yourself or 200 for your company party — same quality either way."},{"question":"How quickly can I get Christmas shirts?","answer":"Standard production is 5-7 business days. Rush holiday orders available — contact us for availability."},{"question":"Can I do different designs for each person?","answer":"Yes! Since sublimation is digital printing, every shirt can have a unique design at no extra cost."}]',
 3),

-- 4) Construction Shirts
('Construction Shirts', 'construction-shirts',
 'Custom sublimated construction company shirts. Durable, hi-vis compatible uniforms for contractors and construction crews.',
 'Custom Construction Shirt', 'Built for the Job Site',
 'Tough, professional sublimated uniforms designed for construction crews, contractors, and tradespeople.',
 'Professional Construction Shirts That Work as Hard as You Do',
 'Custom sublimated construction shirts are built for professionals who need uniforms that can handle demanding job site conditions. Made from durable, breathable 100% polyester fabric 180 to 200 GSM quality, these shirts keep your crew comfortable during long shifts while maintaining a professional, branded appearance. Whether you need hi-vis designs, company branding, or safety-compliant colors, sublimation printing delivers it all.

Full sublimation printing allows your company logo, contact information, license numbers, and safety markings to become part of the fabric rather than sitting on top of it. This means the details will not crack, peel, or fade, even after daily wear, washing, and exposure to dust, cement, and job site conditions. These sublimated construction shirts provide the durability professional contractors demand.',
 '["Fast Delivery","100% Polyester & Durable Fabric","Dye Sublimation Shirts","Unlimited Revisions","Free Shipping"]',
 'Why Choose Sublimated Construction Shirts?',
 'Build trust on every job site with professional, branded uniforms.',
 '[{"title":"Job Site Durable","description":"Sublimation prints withstand dust, dirt, cement, and daily wear without fading or cracking."},{"title":"Hi-Vis Compatible","description":"Design with fluorescent yellows, oranges, and reflective patterns for safety-compliant workwear."},{"title":"License & Insurance Display","description":"Print your contractor license number, insurance info, and certifications right on the shirt."},{"title":"Team Unity","description":"Matching uniforms build crew morale and present a professional image to clients and inspectors."}]',
 '[{"question":"Can you print hi-vis / safety colors?","answer":"Yes! We can print fluorescent yellows, oranges, and bright greens. While sublimated shirts are not ANSI-rated safety vests, they provide excellent visibility on job sites."},{"question":"Can I include my contractor license number?","answer":"Absolutely. Many contractors include their license number, insurance info, website, and phone number on their shirts."},{"question":"How durable are these shirts for construction work?","answer":"Very durable. The sublimation print will never crack, peel, or fade regardless of job site conditions. The polyester fabric is also resistant to shrinking."},{"question":"Do you offer long sleeve options?","answer":"Yes! We offer short sleeve, long sleeve, and 3/4 sleeve options in the same sublimation quality."}]',
 4),

-- 5) Pool Cleaning Shirts
('Pool Cleaning Shirts', 'pool-cleaning-shirts',
 'Custom sublimated pool cleaning shirts. Chlorine resistant, UV proof uniforms for pool service companies.',
 'Turn Pool Cleaning Shirt', 'Ideas Into Reality',
 'Custom sublimated uniforms built for pool technicians who work with chlorine and chemicals every day.',
 'Turn Pool Cleaning Shirt Ideas Into Reality',
 'Custom sublimated pool cleaning shirts are designed for professionals who spend long hours working outdoors in demanding conditions. Made from lightweight, breathable 100% polyester fabric 180 to 200 GSM quality, these shirts help technicians stay cool, comfortable, and presentable throughout the day. Whether your design idea is simple or bold, sublimation printing delivers clean details and vibrant colors that give your team a polished, professional look.

Full sublimation printing allows your artwork, logos, and branding to become part of the fabric rather than sitting on top of it. This means the shirts will not crack, peel, or fade, even after frequent washing and exposure to chlorine or sunlight. Built for durability and daily use, these sublimated pool cleaning shirts provide a reliable uniform solution that supports both performance and long-term brand visibility.',
 '["Fast Delivery","100% Polyester & Chemical Resistant Fabric","Dye Sublimation Shirts","Unlimited Revisions","Free Shipping"]',
 'Why Choose Sublimated Pool Cleaning Shirts?',
 'Pool technicians face chlorine, sun, and water daily. Your shirts should handle it all.',
 '[{"title":"Chlorine Resistant","description":"Sublimation ink is bonded into the fiber — chlorine and pool chemicals cannot damage or bleach the print."},{"title":"UV Protection","description":"Colors stay vibrant even after months of daily sun exposure. No fading, no cracking."},{"title":"Quick Dry","description":"Polyester fabric dries quickly after accidental splashes, keeping technicians comfortable all day."},{"title":"Professional Branding","description":"Full coverage printing showcases your pool company brand on every job visit."}]',
 '[{"question":"Will chlorine damage the print on these shirts?","answer":"No. Unlike screen printing, sublimation ink becomes part of the polyester fiber at a molecular level. Chlorine, bromine, and other pool chemicals cannot bleach or damage the print."},{"question":"Are these shirts comfortable in hot weather?","answer":"Yes. The 100% polyester fabric is moisture-wicking and breathable, designed to keep pool technicians cool during outdoor work."},{"question":"What is the minimum order?","answer":"There is no minimum order. You can order as few as 1 shirt."},{"question":"Can I put my CPO certification on the shirt?","answer":"Yes! You can include any text, certifications, license numbers, or graphics you want on the shirt."}]',
 5),

-- 6) Sublimated Sport Uniforms
('Sublimated Sport Uniforms', 'sport-uniforms',
 'Custom sublimated sports uniforms. Full-color jerseys, shorts, and athletic wear for teams and leagues.',
 'Custom Sport Uniform', 'Designs That Perform',
 'Full-color sublimated athletic uniforms designed for teams, leagues, and sports organizations.',
 'Game-Ready Custom Sport Uniforms',
 'Custom sublimated sport uniforms deliver the professional quality that athletes and teams demand. Made from high-performance 100% polyester moisture-wicking fabric 180 to 200 GSM quality, these uniforms are designed for maximum comfort, breathability, and freedom of movement during competition. From youth leagues to professional teams, sublimation printing provides unlimited design possibilities with no color restrictions.

Full sublimation printing covers the entire uniform from seam to seam with vibrant, permanent graphics. Player names, numbers, team logos, sponsor logos, and complex designs are all printed simultaneously with no layering or peeling. The print is part of the fabric — it won''t crack, peel, or fade regardless of how many games you play or how many times you wash it. These uniforms look brand new season after season.',
 '["Fast Delivery","100% Polyester Moisture-Wicking Fabric","Full Color Edge-to-Edge Printing","Unlimited Revisions","Free Shipping"]',
 'Why Choose Sublimated Sport Uniforms?',
 'Outperform the competition with professional-grade custom uniforms.',
 '[{"title":"Performance Fabric","description":"Moisture-wicking polyester keeps athletes cool and dry. Lightweight and breathable for maximum performance."},{"title":"Unlimited Design","description":"No color limits, no design restrictions. Print photos, gradients, patterns, and complex graphics at no extra cost."},{"title":"Individual Customization","description":"Each uniform can have unique player names, numbers, and sizing — all in one order."},{"title":"Season-Long Durability","description":"Prints never crack, peel, or fade. Uniforms look professional from the first game to the championship."}]',
 '[{"question":"What sports can you make uniforms for?","answer":"We create uniforms for all sports — basketball, soccer, football, baseball, volleyball, hockey, lacrosse, esports, and more."},{"question":"Can each player have a different name and number?","answer":"Yes! Since sublimation is digital printing, every uniform can be unique — different names, numbers, and even sizes — at no extra cost per variation."},{"question":"Do you make matching shorts and accessories?","answer":"Yes! We can create matching shorts, warm-up jackets, headbands, arm sleeves, and other accessories in the same sublimation quality."},{"question":"What''s the turnaround time for team orders?","answer":"Standard production is 7-10 business days for team orders. Rush options available for tournament deadlines."}]',
 6),

-- 7) HVAC Shirts
('HVAC Shirts', 'hvac-shirts',
 'Custom sublimated HVAC company shirts. Professional, durable uniforms for heating and cooling technicians.',
 'Custom HVAC Shirt', 'Designs That Impress',
 'Professional sublimated uniforms designed for HVAC technicians who enter customers'' homes every day.',
 'Professional HVAC Shirts That Build Customer Trust',
 'Custom sublimated HVAC shirts are designed for heating and cooling professionals who need to look sharp and professional when entering customers'' homes and businesses. Made from comfortable, breathable 100% polyester fabric 180 to 200 GSM quality, these shirts keep technicians comfortable during physical work in attics, crawl spaces, and rooftops while maintaining a clean, branded appearance.

Full sublimation printing allows your HVAC company logo, contact information, certifications, and branding to become part of the fabric permanently. This means the shirts will not crack, peel, or fade, even after daily wear, frequent washing, and exposure to extreme temperatures. Sublimated HVAC shirts help your technicians make a professional first impression on every service call, building trust and generating referrals.',
 '["Fast Delivery","100% Polyester & Breathable Fabric","Dye Sublimation Shirts","Unlimited Revisions","Free Shipping"]',
 'Why Choose Sublimated HVAC Shirts?',
 'First impressions matter — especially when entering a customer''s home.',
 '[{"title":"Professional Appearance","description":"Clean, branded uniforms build immediate trust when technicians knock on a customer''s door."},{"title":"Temperature Versatile","description":"Moisture-wicking polyester keeps technicians comfortable whether working in hot attics or cold basements."},{"title":"Certification Display","description":"Print EPA certifications, NATE credentials, license numbers, and insurance info right on the shirt."},{"title":"Marketing on Every Call","description":"Every service visit becomes a marketing opportunity with your logo, phone number, and website prominently displayed."}]',
 '[{"question":"Can I include my EPA and NATE certifications on the shirt?","answer":"Yes! Many HVAC companies include their EPA 608 certification, NATE logo, license numbers, and insurance information directly on their uniforms."},{"question":"Are these comfortable for attic work?","answer":"Yes. The moisture-wicking polyester fabric is designed for physical work. It''s breathable and dries quickly, even in extreme heat."},{"question":"Will the print survive daily washing?","answer":"Absolutely. Sublimation prints are permanent — they will never crack, peel, or fade regardless of how many times you wash them."},{"question":"Can I order different sizes in the same design?","answer":"Yes! You can order any combination of sizes (S through 5XL) all with the same design in a single order."}]',
 7)

ON CONFLICT (slug) DO NOTHING;


-- ============================================================
-- SECTION 3: BLOG POSTS TABLE
-- Full-featured blog system with rich content, categories,
-- tags, featured images, and SEO metadata.
-- ============================================================

CREATE TABLE IF NOT EXISTS blog_posts (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW(),
  published_at     TIMESTAMPTZ,
  title            TEXT NOT NULL,
  slug             TEXT UNIQUE NOT NULL,
  excerpt          TEXT,               -- short preview text
  content          TEXT,               -- full HTML content
  featured_image   TEXT,               -- main image URL
  category         TEXT DEFAULT 'general',
  tags             JSONB DEFAULT '[]'::jsonb, -- ["tag1","tag2"]
  author           TEXT DEFAULT 'Bleach Resistant',
  status           TEXT DEFAULT 'draft', -- 'draft' or 'published'
  meta_description TEXT,
  meta_keywords    TEXT,
  views            INTEGER DEFAULT 0,
  featured         BOOLEAN DEFAULT false,
  sort_order       INTEGER DEFAULT 0
);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_blog_posts_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_blog_posts_updated ON blog_posts;
CREATE TRIGGER trg_blog_posts_updated
  BEFORE UPDATE ON blog_posts
  FOR EACH ROW EXECUTE FUNCTION update_blog_posts_updated_at();

-- RLS
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;

-- Public can read published posts
CREATE POLICY "blog_public_read" ON blog_posts
  FOR SELECT TO anon
  USING (status = 'published');

-- Authenticated can read all (admin sees drafts)
CREATE POLICY "blog_auth_read" ON blog_posts
  FOR SELECT TO authenticated
  USING (true);

-- Admin full CRUD
CREATE POLICY "blog_admin_insert" ON blog_posts
  FOR INSERT TO authenticated
  WITH CHECK (auth.email() = 'usman@gmail.com');

CREATE POLICY "blog_admin_update" ON blog_posts
  FOR UPDATE TO authenticated
  USING (auth.email() = 'usman@gmail.com')
  WITH CHECK (auth.email() = 'usman@gmail.com');

CREATE POLICY "blog_admin_delete" ON blog_posts
  FOR DELETE TO authenticated
  USING (auth.email() = 'usman@gmail.com');

GRANT SELECT ON TABLE blog_posts TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE blog_posts TO authenticated;


-- ============================================================
-- SECTION 4: BLOG CATEGORIES TABLE (optional - for dynamic categories)
-- ============================================================

CREATE TABLE IF NOT EXISTS blog_categories (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT UNIQUE NOT NULL,
  slug       TEXT UNIQUE NOT NULL,
  sort_order INTEGER DEFAULT 0
);

ALTER TABLE blog_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "blog_cats_public_read" ON blog_categories
  FOR SELECT TO anon, authenticated USING (true);

CREATE POLICY "blog_cats_admin_all" ON blog_categories
  FOR ALL TO authenticated
  USING (auth.email() = 'usman@gmail.com')
  WITH CHECK (auth.email() = 'usman@gmail.com');

GRANT SELECT ON TABLE blog_categories TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE blog_categories TO authenticated;

-- Seed default categories
INSERT INTO blog_categories (name, slug, sort_order) VALUES
  ('General', 'general', 1),
  ('Sublimation Tips', 'sublimation-tips', 2),
  ('Design Ideas', 'design-ideas', 3),
  ('Industry News', 'industry-news', 4),
  ('Customer Stories', 'customer-stories', 5),
  ('Product Updates', 'product-updates', 6)
ON CONFLICT (slug) DO NOTHING;


-- ============================================================
-- SECTION 5: ADD TO SUPABASE-SETUP.SQL (append to existing file)
-- Copy these GRANT statements if you need to re-run grants.
-- ============================================================

GRANT SELECT ON TABLE sublimation_services TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE sublimation_services TO authenticated;

GRANT SELECT ON TABLE blog_posts TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE blog_posts TO authenticated;

GRANT SELECT ON TABLE blog_categories TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE blog_categories TO authenticated;
