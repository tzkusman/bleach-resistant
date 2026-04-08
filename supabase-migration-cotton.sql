-- =============================================
-- COTTON PAGE SYSTEM — Supabase Migration
-- Run this in Supabase SQL Editor (supabase.com → SQL Editor → New Query)
-- =============================================

-- ─── 1. Cotton Posts Table ───
CREATE TABLE IF NOT EXISTS cotton_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  published_at TIMESTAMPTZ,
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  excerpt TEXT,
  content TEXT,
  featured_image TEXT,
  category TEXT DEFAULT 'general',
  tags JSONB DEFAULT '[]'::jsonb,
  author TEXT DEFAULT 'Bleach Resistant',
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  meta_description TEXT,
  meta_keywords TEXT,
  views INTEGER DEFAULT 0,
  featured BOOLEAN DEFAULT false,
  sort_order INTEGER DEFAULT 0
);

-- ─── 2. Cotton Categories Table ───
CREATE TABLE IF NOT EXISTS cotton_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  sort_order INTEGER DEFAULT 0
);

-- ─── 3. Seed Default Categories ───
INSERT INTO cotton_categories (name, slug, sort_order) VALUES
  ('General', 'general', 1),
  ('Cotton Fabric Types', 'cotton-fabric-types', 2),
  ('Cotton Printing', 'cotton-printing', 3),
  ('Cotton Care', 'cotton-care', 4),
  ('Product Spotlights', 'product-spotlights', 5),
  ('Cotton vs Polyester', 'cotton-vs-polyester', 6)
ON CONFLICT (slug) DO NOTHING;

-- ─── 4. Enable RLS ───
ALTER TABLE cotton_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cotton_categories ENABLE ROW LEVEL SECURITY;

-- ─── 5. RLS Policies — cotton_posts ───

-- Public can read published posts
CREATE POLICY "cotton_posts_public_read" ON cotton_posts
  FOR SELECT USING (status = 'published');

-- Authenticated can read all posts (including drafts)
CREATE POLICY "cotton_posts_auth_read" ON cotton_posts
  FOR SELECT TO authenticated USING (true);

-- Admin can insert
CREATE POLICY "cotton_posts_admin_insert" ON cotton_posts
  FOR INSERT TO authenticated
  WITH CHECK (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- Admin can update
CREATE POLICY "cotton_posts_admin_update" ON cotton_posts
  FOR UPDATE TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- Admin can delete
CREATE POLICY "cotton_posts_admin_delete" ON cotton_posts
  FOR DELETE TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- ─── 6. RLS Policies — cotton_categories ───

-- Public can read
CREATE POLICY "cotton_categories_public_read" ON cotton_categories
  FOR SELECT USING (true);

-- Admin can insert
CREATE POLICY "cotton_categories_admin_insert" ON cotton_categories
  FOR INSERT TO authenticated
  WITH CHECK (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- Admin can update
CREATE POLICY "cotton_categories_admin_update" ON cotton_categories
  FOR UPDATE TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- Admin can delete
CREATE POLICY "cotton_categories_admin_delete" ON cotton_categories
  FOR DELETE TO authenticated
  USING (auth.jwt() ->> 'email' = 'usman@gmail.com');

-- ─── 7. Updated_at Trigger ───
CREATE OR REPLACE FUNCTION update_cotton_posts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cotton_posts_updated_at
  BEFORE UPDATE ON cotton_posts
  FOR EACH ROW
  EXECUTE FUNCTION update_cotton_posts_updated_at();

-- ─── 8. Seed Initial Cotton Posts ───
INSERT INTO cotton_posts (title, slug, excerpt, content, featured_image, category, tags, author, status, meta_description, featured, published_at) VALUES
(
  'Understanding Cotton Fabrics: A Complete Guide',
  'understanding-cotton-fabrics-complete-guide',
  'Everything you need to know about cotton fabric types, weights, and which ones work best for custom printing and apparel.',
  '<h2>What Makes Cotton Special?</h2><p>Cotton has been the world''s most popular fabric for centuries — and for good reason. It''s breathable, soft, durable, and naturally hypoallergenic. But not all cotton is created equal.</p><h2>Types of Cotton Fabric</h2><h3>1. Combed Cotton</h3><p>Combed cotton goes through an extra manufacturing process where short fibers are removed and the remaining fibers are laid parallel. This creates a smoother, softer, and stronger fabric that resists pilling.</p><h3>2. Ring-Spun Cotton</h3><p>Ring-spun cotton is made by continuously twisting and thinning cotton strands. The result is a noticeably softer and more durable fabric compared to regular cotton. It''s the preferred choice for premium t-shirts.</p><h3>3. Organic Cotton</h3><p>Grown without synthetic pesticides or fertilizers, organic cotton is eco-friendly and often softer than conventional cotton. It''s becoming increasingly popular for brands focused on sustainability.</p><h3>4. Pima / Supima Cotton</h3><p>Known for its extra-long staple fibers, Pima cotton (and its American-grown cousin Supima) is exceptionally soft, durable, and resistant to fading, stretching, and pilling.</p><h3>5. Cotton Blends</h3><p>Cotton is often blended with polyester (CVC — Chief Value Cotton, or 50/50 blends) to combine cotton''s comfort with polyester''s durability and moisture-wicking properties. These blends are popular for sportswear and workwear.</p><h2>Choosing the Right Cotton Weight</h2><p>Cotton fabric weight is measured in GSM (grams per square meter) or oz/yd²:</p><ul><li><strong>Lightweight (100-150 GSM):</strong> Summer tees, undershirts</li><li><strong>Midweight (150-200 GSM):</strong> Standard t-shirts, most apparel</li><li><strong>Heavyweight (200-300+ GSM):</strong> Premium tees, hoodies, outerwear</li></ul><p>For custom printing, midweight cotton (5.3-6.1 oz) offers the best balance of comfort, drape, and print quality.</p>',
  'https://images.unsplash.com/photo-1558171813-4c088753af8f?w=800',
  'cotton-fabric-types',
  '["cotton", "fabric guide", "apparel", "ring-spun", "combed cotton"]',
  'Bleach Resistant',
  'published',
  'Complete guide to cotton fabric types including combed, ring-spun, organic, Pima, and cotton blends for custom apparel printing.',
  true,
  now() - interval '2 days'
),
(
  'Cotton vs Polyester: Which Is Better for Custom Printing?',
  'cotton-vs-polyester-custom-printing',
  'A detailed comparison of cotton and polyester for custom printed apparel — pros, cons, and when to choose each.',
  '<h2>The Great Fabric Debate</h2><p>When ordering custom printed apparel, one of the first decisions is the fabric. Cotton and polyester each have distinct advantages depending on your use case.</p><h2>Cotton: The Classic Choice</h2><h3>Pros</h3><ul><li><strong>Comfort:</strong> Naturally soft, breathable, great for all-day wear</li><li><strong>Screen Print Quality:</strong> Cotton absorbs ink beautifully for screen printing and DTG</li><li><strong>Eco-Friendly:</strong> Biodegradable and available in organic options</li><li><strong>Hypoallergenic:</strong> Less likely to cause skin irritation</li></ul><h3>Cons</h3><ul><li>Shrinks in hot water/dryers</li><li>Wrinkles more easily</li><li>Retains moisture (not ideal for athletics)</li><li>Not suitable for dye sublimation printing</li></ul><h2>Polyester: The Performance Pick</h2><h3>Pros</h3><ul><li><strong>Sublimation Ready:</strong> Only fabric that works with dye sublimation for all-over prints</li><li><strong>Moisture-Wicking:</strong> Pulls sweat away, dries fast</li><li><strong>Durable:</strong> Resists stretching, shrinking, wrinkles</li><li><strong>Color Fastness:</strong> Sublimated prints never crack, peel, or fade</li></ul><h3>Cons</h3><ul><li>Less breathable in hot weather</li><li>Can feel less natural against skin</li><li>Not biodegradable</li></ul><h2>The Best of Both Worlds: Blends</h2><p>Cotton-polyester blends (like 60/40 or 50/50) combine the comfort of cotton with the performance of polyester. However, sublimation only works well on fabrics with <strong>65% or more polyester content</strong>.</p><blockquote>At Bleach Resistant, we specialize in sublimation printing on high-quality polyester for vibrant, permanent designs. For cotton garments, we offer screen printing and DTG options.</blockquote>',
  'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=800',
  'cotton-vs-polyester',
  '["cotton", "polyester", "comparison", "sublimation", "screen printing"]',
  'Bleach Resistant',
  'published',
  'Cotton vs polyester comparison for custom printed apparel. Learn which fabric is best for your printing needs.',
  false,
  now() - interval '5 days'
),
(
  'How to Care for Your Cotton Garments',
  'how-to-care-for-cotton-garments',
  'Keep your cotton apparel looking fresh and lasting longer with these essential care tips and washing instructions.',
  '<h2>Make Your Cotton Last</h2><p>Cotton is durable, but proper care extends its life significantly. Whether you have screen-printed tees, DTG prints, or plain cotton garments, these tips will keep them looking brand new.</p><h2>Washing Tips</h2><ul><li><strong>Cold Water:</strong> Always wash cotton in cold or lukewarm water to prevent shrinking</li><li><strong>Inside Out:</strong> Turn printed garments inside out to protect the design</li><li><strong>Gentle Cycle:</strong> Use a gentle or normal cycle — avoid heavy-duty settings</li><li><strong>Similar Colors:</strong> Sort by color to prevent dye transfer</li><li><strong>Mild Detergent:</strong> Use a gentle, color-safe detergent without bleach</li></ul><h2>Drying Tips</h2><ul><li><strong>Air Dry When Possible:</strong> Hang dry or lay flat to avoid shrinkage</li><li><strong>Low Heat:</strong> If using a dryer, use low or medium heat</li><li><strong>Remove Promptly:</strong> Take clothes out as soon as the cycle ends to reduce wrinkles</li></ul><h2>Ironing & Storage</h2><ul><li>Iron on medium heat or use steam</li><li>Never iron directly on printed areas — iron inside out or use a pressing cloth</li><li>Store folded in a cool, dry place away from direct sunlight</li><li>Avoid hanging heavy cotton garments long-term (causes stretching)</li></ul><h2>Special Care for Printed Cotton</h2><p>Screen-printed and DTG-printed cotton garments have ink sitting on top of the fabric fibers. To maximize print longevity:</p><ol><li>Wait 24 hours after printing before the first wash</li><li>Always wash inside out</li><li>Avoid fabric softener (it can break down the ink bond)</li><li>Never dry clean printed garments</li></ol>',
  'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?w=800',
  'cotton-care',
  '["cotton care", "washing", "garment care", "printed apparel"]',
  'Bleach Resistant',
  'published',
  'Essential care tips for cotton garments and printed apparel. Learn proper washing, drying, and storage techniques.',
  false,
  now() - interval '8 days'
),
(
  '5 Best Cotton T-Shirt Brands for Custom Printing',
  '5-best-cotton-tshirt-brands-custom-printing',
  'Our picks for the top cotton t-shirt blanks that deliver the best results for screen printing and DTG decoration.',
  '<h2>Choosing the Right Blank</h2><p>The quality of your custom printed shirt starts with the blank. Here are our top picks for cotton t-shirt brands that deliver exceptional print results.</p><h3>1. Bella+Canvas 3001</h3><p>The gold standard for retail-quality cotton tees. Made from 100% Airlume combed and ring-spun cotton at 4.2 oz, it offers a soft hand feel and modern fit. Available in 100+ colors.</p><h3>2. Next Level 3600</h3><p>A close competitor to Bella+Canvas, the Next Level 3600 features 100% combed ring-spun cotton with a tear-away label. Slightly heavier at 4.3 oz with a great drape.</p><h3>3. Gildan 64000 (Softstyle)</h3><p>Budget-friendly without sacrificing quality. The Softstyle is made from ring-spun cotton and comes in a wide color range. At 4.5 oz, it''s a great mid-range option for bulk orders.</p><h3>4. Comfort Colors 1717</h3><p>Known for their vintage, garment-dyed look. These heavyweight (6.1 oz) cotton tees have a lived-in feel right out of the box. Perfect for screen printing with a rustic aesthetic.</p><h3>5. American Apparel 2001</h3><p>Premium 100% fine jersey cotton at 4.3 oz. Known for superior softness and a fashion-forward fit. Made in the USA, which appeals to domestic manufacturing advocates.</p><h2>What to Look For</h2><ul><li><strong>Ring-spun cotton:</strong> Smoother surface = better print quality</li><li><strong>Pre-shrunk:</strong> Minimizes size changes after washing</li><li><strong>Side-seamed:</strong> Better shape retention vs tubular construction</li><li><strong>Tear-away label:</strong> Easy to relabel for private-label brands</li></ul>',
  'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800',
  'product-spotlights',
  '["t-shirts", "cotton blanks", "Bella Canvas", "Gildan", "Comfort Colors"]',
  'Bleach Resistant',
  'published',
  'Top 5 cotton t-shirt brands for custom printing. Reviews of Bella+Canvas, Next Level, Gildan Softstyle and more.',
  false,
  now() - interval '12 days'
),
(
  'Cotton Printing Methods Explained: Screen Print, DTG, and More',
  'cotton-printing-methods-explained',
  'A breakdown of every printing method that works on cotton fabric — from screen printing to DTG to heat transfer vinyl.',
  '<h2>Printing on Cotton</h2><p>Unlike polyester (which is perfect for sublimation), cotton requires different printing techniques. Here''s a breakdown of every method available for cotton garments.</p><h2>1. Screen Printing</h2><p>The most popular method for cotton. Ink is pushed through a mesh screen stencil directly onto the fabric. Best for large orders (50+ pieces) with simple designs (1-4 colors).</p><ul><li><strong>Pros:</strong> Vibrant colors, extremely durable, low cost per unit at scale</li><li><strong>Cons:</strong> High setup costs (screens), not economical for small runs, limited colors per design</li></ul><h2>2. DTG (Direct-to-Garment)</h2><p>A specialized inkjet printer sprays water-based ink directly onto cotton fabric. Think of it as a printer for clothes. Best for small orders or designs with many colors/photos.</p><ul><li><strong>Pros:</strong> No minimum order, unlimited colors, great for photos/gradients</li><li><strong>Cons:</strong> Slower production, higher per-unit cost, works best on 100% cotton</li></ul><h2>3. Heat Transfer Vinyl (HTV)</h2><p>Designs are cut from colored vinyl sheets and heat-pressed onto the garment. Best for names, numbers, and simple graphics.</p><ul><li><strong>Pros:</strong> Great for personalization, works on any fabric, no minimums</li><li><strong>Cons:</strong> Not ideal for complex designs, vinyl can crack/peel over time</li></ul><h2>4. Embroidery</h2><p>Thread is stitched into the fabric using computerized machines. Not technically "printing" but a popular decoration method for cotton polos, caps, and jackets.</p><ul><li><strong>Pros:</strong> Premium look, extremely durable, great for logos/branding</li><li><strong>Cons:</strong> Not suitable for complex artwork, higher cost per unit</li></ul><h2>Which Method Should You Choose?</h2><table><tr><th>Method</th><th>Best For</th><th>Min Order</th><th>Durability</th></tr><tr><td>Screen Print</td><td>Large runs, simple designs</td><td>24-50+</td><td>★★★★★</td></tr><tr><td>DTG</td><td>Small runs, full-color art</td><td>1</td><td>★★★★</td></tr><tr><td>HTV</td><td>Names/numbers, personalization</td><td>1</td><td>★★★</td></tr><tr><td>Embroidery</td><td>Logos, professional branding</td><td>12+</td><td>★★★★★</td></tr></table><blockquote>Need help choosing a printing method? <a href="order.html">Contact Bleach Resistant</a> and we''ll recommend the best option for your project.</blockquote>',
  'https://images.unsplash.com/photo-1503342394128-c104d54dba01?w=800',
  'cotton-printing',
  '["screen printing", "DTG", "heat transfer", "embroidery", "printing methods"]',
  'Bleach Resistant',
  'published',
  'Complete guide to cotton printing methods including screen printing, DTG, HTV, and embroidery. Compare pros, cons, and costs.',
  false,
  now() - interval '15 days'
)
ON CONFLICT (slug) DO NOTHING;

-- =============================================
-- DONE! Cotton system is ready.
-- Tables created: cotton_posts, cotton_categories
-- 5 initial posts and 6 categories seeded.
-- =============================================
