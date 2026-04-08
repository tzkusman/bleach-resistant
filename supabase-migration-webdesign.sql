-- ============================================================
-- supabase-migration-webdesign.sql
-- Bleach Resistant — Website Design Services
-- Run this in the Supabase SQL Editor AFTER supabase-migration-blog.sql
-- ============================================================


-- ============================================================
-- SECTION 1: WEBSITE DESIGN SERVICES TABLE
-- Stores detailed service pages for website design subcategories
-- ============================================================

CREATE TABLE IF NOT EXISTS website_design_services (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW(),
  title            TEXT NOT NULL,
  slug             TEXT UNIQUE NOT NULL,
  meta_description TEXT,
  hero_title       TEXT NOT NULL,
  hero_highlight   TEXT,
  hero_subtitle    TEXT,
  main_image       TEXT,
  main_heading     TEXT,
  main_description TEXT,
  checklist        JSONB DEFAULT '[]'::jsonb,
  btn1_text        TEXT DEFAULT 'Get a Quote',
  btn1_link        TEXT DEFAULT 'order.html',
  btn2_text        TEXT DEFAULT 'Call Us',
  btn2_link        TEXT DEFAULT 'tel:',
  why_heading      TEXT,
  why_description  TEXT,
  why_features     JSONB DEFAULT '[]'::jsonb,
  faqs             JSONB DEFAULT '[]'::jsonb,
  gallery          JSONB DEFAULT '[]'::jsonb,
  sort_order       INTEGER DEFAULT 0,
  active           BOOLEAN DEFAULT true,
  featured         BOOLEAN DEFAULT false
);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_website_design_services_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_website_design_services_updated ON website_design_services;
CREATE TRIGGER trg_website_design_services_updated
  BEFORE UPDATE ON website_design_services
  FOR EACH ROW EXECUTE FUNCTION update_website_design_services_updated_at();

-- RLS
ALTER TABLE website_design_services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "wd_services_public_read" ON website_design_services
  FOR SELECT TO anon USING (active = true);

CREATE POLICY "wd_services_auth_read" ON website_design_services
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "wd_services_admin_insert" ON website_design_services
  FOR INSERT TO authenticated
  WITH CHECK (auth.email() = 'usman@gmail.com');

CREATE POLICY "wd_services_admin_update" ON website_design_services
  FOR UPDATE TO authenticated
  USING (auth.email() = 'usman@gmail.com')
  WITH CHECK (auth.email() = 'usman@gmail.com');

CREATE POLICY "wd_services_admin_delete" ON website_design_services
  FOR DELETE TO authenticated
  USING (auth.email() = 'usman@gmail.com');

GRANT SELECT ON TABLE website_design_services TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE website_design_services TO authenticated;


-- ============================================================
-- SECTION 2: SEED WEBSITE DESIGN SERVICES DATA
-- Pre-populate with 7 service categories
-- ============================================================

INSERT INTO website_design_services (title, slug, meta_description, hero_title, hero_highlight, hero_subtitle, main_heading, main_description, checklist, why_heading, why_description, why_features, faqs, sort_order) VALUES

-- 1) E-commerce Website Design
('E-commerce', 'ecommerce',
 'Custom e-commerce website design. Professional online stores built for small businesses, product sellers, and service-based companies.',
 'Custom E-commerce Website', 'Design That Converts',
 'Professional online stores engineered to showcase your products and drive sales around the clock.',
 'Custom E-commerce Websites Built to Sell',
 'A professional e-commerce website is the foundation of any successful online business. Our custom e-commerce web design service builds fully responsive, fast-loading online stores that make it easy for your customers to browse, select, and purchase your products or services from any device. We build on modern platforms with secure payment processing, inventory management, and order tracking built right in.

Every e-commerce site we deliver is designed with conversion in mind. From intuitive navigation and high-quality product galleries to streamlined checkout flows and trust signals, every element is strategically placed to turn visitors into paying customers. Whether you sell physical products, digital downloads, or service packages, we build an e-commerce experience that reflects your brand and drives revenue growth.',
 '["Custom Responsive Design","Secure Payment Integration","Product Management System","Mobile-First Approach","SEO Optimized Structure","Fast Loading Speed"]',
 'Why Choose Our E-commerce Web Design?',
 'Your online store should work as hard as you do — selling for you 24/7.',
 '[{"title":"Conversion Focused","description":"Every design decision is made to maximize sales. Strategic layouts, clear CTAs, and optimized checkout flows."},{"title":"Secure Payments","description":"SSL encryption, PCI-compliant payment processing with Stripe, PayPal, and major credit card support."},{"title":"Mobile Optimized","description":"Over 60% of online shopping happens on mobile. Your store will look and work perfectly on every screen size."},{"title":"Easy Management","description":"User-friendly admin panel lets you add products, manage inventory, process orders, and track sales without any technical knowledge."}]',
 '[{"question":"What platform do you build e-commerce sites on?","answer":"We build on modern platforms including Shopify, WooCommerce, and custom solutions depending on your needs, budget, and scale requirements."},{"question":"Can I manage my own products and orders?","answer":"Yes! Every site comes with an easy-to-use admin panel where you can add/edit products, manage inventory, process orders, and view sales analytics."},{"question":"Do you set up payment processing?","answer":"Absolutely. We integrate secure payment gateways like Stripe, PayPal, Square, and more. All transactions are encrypted and PCI-compliant."},{"question":"How long does an e-commerce site take to build?","answer":"Typical timeline is 3-6 weeks depending on the number of products and custom features required. We provide a detailed timeline during consultation."},{"question":"Do you provide training on how to use the site?","answer":"Yes! Every project includes a training session where we walk you through managing products, processing orders, and updating content."}]',
 1),

-- 2) Pressure Washing Web Design
('Pressure Washing Web Design', 'pressure-washing-web-design',
 'Custom website design for pressure washing companies. Professional sites that generate leads and showcase your power washing services.',
 'Pressure Washing Website', 'Design That Generates Leads',
 'Professional websites built specifically for power washing and pressure cleaning companies to attract local customers.',
 'Pressure Washing Websites That Bring In New Customers',
 'A professional website is the most powerful marketing tool a pressure washing company can have. When homeowners and property managers search for pressure washing services in your area, your website needs to appear, impress, and convert them into paying customers. Our custom pressure washing web design service builds sites that are optimized for local search, showcase your before-and-after results, and make it easy for visitors to request a quote or call you directly.

Every pressure washing website we build is designed with the unique needs of the cleaning industry in mind. We include before-and-after photo galleries that demonstrate your quality of work, service area maps, an easy-to-use quote request form, click-to-call functionality for mobile users, and customer testimonial sections that build trust. The result is a website that works as your hardest-working sales team member — generating leads 24 hours a day.',
 '["Before & After Photo Galleries","Local SEO Optimization","Click-to-Call Mobile Integration","Quote Request Forms","Service Area Pages","Google Business Integration"]',
 'Why Choose Our Pressure Washing Web Design?',
 'Your website should generate leads while you focus on the job.',
 '[{"title":"Local SEO Built In","description":"Rank higher in local search results. We optimize for ''pressure washing near me'' and your specific service areas."},{"title":"Before & After Galleries","description":"Showcase your best work with professional before-and-after photo galleries that sell your services visually."},{"title":"Lead Generation","description":"Every page is designed to convert visitors into quote requests. Strategic CTAs, forms, and click-to-call buttons."},{"title":"Mobile First","description":"Most customers search for pressure washing on their phones. Your site will be fast, beautiful, and easy to use on any device."}]',
 '[{"question":"Will my website show up on Google?","answer":"Yes! Every site is built with local SEO best practices. We optimize for your target keywords and service areas to help you rank in local search results and Google Maps."},{"question":"Can I show before and after photos?","answer":"Absolutely. We build dedicated before-and-after galleries that let potential customers see the quality of your work. This is one of the most effective conversion tools for pressure washing companies."},{"question":"Do you include a quote request form?","answer":"Yes. Every site includes an optimized quote request form that captures the information you need — service type, property details, contact info, and photos."},{"question":"Can I update the website myself?","answer":"Yes! We provide an easy-to-use content management system and training so you can add photos, update prices, and manage content without any technical skills."},{"question":"Do you create the content for the website?","answer":"Yes. We write professional, SEO-optimized content for all your service pages, about page, and FAQ section based on your business details."}]',
 2),

-- 3) Roof Cleaning Website Design
('Roof Cleaning Website Design', 'roof-cleaning-web-design',
 'Custom website design for roof cleaning companies. Professional sites that build trust, showcase results, and generate roof cleaning leads.',
 'Roof Cleaning Website', 'Design That Builds Trust',
 'Professional websites designed for soft wash roof cleaning companies to generate leads and establish credibility.',
 'Roof Cleaning Websites That Win Customer Trust',
 'Roof cleaning is a service that requires significant trust from homeowners — they are inviting you onto their most valuable asset. Your website needs to communicate professionalism, expertise, and reliability from the moment a potential customer lands on the page. Our custom roof cleaning web design service builds websites specifically tailored to soft wash and roof cleaning companies, emphasizing safety credentials, insurance verification, and dramatic before-and-after results.

We understand the roof cleaning industry inside and out. Every website we build includes dedicated service pages for different roof types (shingle, tile, metal, flat), before-and-after galleries that demonstrate the dramatic difference your service makes, customer testimonials with star ratings, certifications and insurance badges prominently displayed, and a streamlined quote request system that captures roof type, square footage, and photos for accurate estimating.',
 '["Before & After Roof Galleries","Safety & Insurance Badges","Roof Type Service Pages","Online Quote Calculator","Google Reviews Integration","Drone Photo Ready"]',
 'Why Choose Our Roof Cleaning Web Design?',
 'Homeowners need to trust you with their roof — your website builds that trust.',
 '[{"title":"Trust Signals","description":"Prominently display insurance certificates, UAMCC membership, manufacturer certifications, and customer reviews."},{"title":"Visual Proof","description":"High-impact before-and-after galleries show the dramatic transformation your service delivers on every roof type."},{"title":"Roof-Specific Pages","description":"Dedicated pages for shingle cleaning, tile cleaning, metal roof treatment, and flat roof maintenance — each optimized for search."},{"title":"Quote System","description":"Smart quote request forms that capture roof type, approximate square footage, and photos for faster, more accurate estimates."}]',
 '[{"question":"Why do roof cleaning companies need a specialized website?","answer":"Roof cleaning requires a higher level of trust than most home services. Homeowners need to see your credentials, insurance, certifications, and results before allowing anyone on their roof. A specialized website addresses all of these trust factors."},{"question":"Can I show different roof types I service?","answer":"Yes. We create dedicated service pages for each roof type — asphalt shingle, clay tile, concrete tile, metal, cedar shake, flat roofs — each with relevant content, photos, and pricing guidance."},{"question":"Do you integrate with Google Reviews?","answer":"Yes! We display your Google reviews directly on your website with star ratings, which significantly increases trust and conversion rates."},{"question":"Can customers upload photos for a quote?","answer":"Yes. Our quote request forms include photo upload functionality so homeowners can send pictures of their roof for more accurate estimates."}]',
 3),

-- 4) HVAC Website Design
('HVAC Website Design', 'hvac-web-design',
 'Custom website design for HVAC companies. Professional heating and cooling websites that generate service calls and build customer trust.',
 'HVAC Company Website', 'Design That Drives Calls',
 'Professional websites built for heating and cooling companies to generate emergency calls and scheduled service appointments.',
 'HVAC Websites That Keep Your Phone Ringing',
 'In the HVAC industry, your website is often the first point of contact when a homeowner''s AC stops working in July or their furnace dies in January. They need to find you fast, trust you immediately, and contact you within seconds. Our custom HVAC web design service builds websites that load fast, communicate trust instantly, and make it effortless for customers to call or schedule service — especially on mobile devices during emergency situations.

Every HVAC website we design includes emergency service call-to-action bars, seasonal maintenance plan pages, equipment brand pages, financing information sections, and technician profile pages that humanize your company. We integrate online scheduling systems, service area maps, and real customer reviews to create a complete digital presence that generates service calls, builds recurring maintenance contracts, and establishes your company as the trusted HVAC expert in your market.',
 '["Emergency Service CTA Bar","Online Scheduling System","Seasonal Maintenance Plans","Equipment Brand Pages","Financing Information","Service Area Maps"]',
 'Why Choose Our HVAC Web Design?',
 'When the AC dies in summer, homeowners need to find and trust you fast.',
 '[{"title":"Emergency Ready","description":"Sticky emergency call bars and one-tap calling ensure customers can reach you instantly when their system fails."},{"title":"Seasonal Marketing","description":"Automatic seasonal content updates promote AC tune-ups in spring and furnace maintenance in fall."},{"title":"Maintenance Plans","description":"Dedicated maintenance plan pages with pricing tiers convert one-time service calls into recurring revenue."},{"title":"Brand Partnerships","description":"Equipment brand pages (Carrier, Lennox, Trane, etc.) establish credibility and capture brand-specific search traffic."}]',
 '[{"question":"Can customers book appointments online?","answer":"Yes! We integrate online scheduling systems that let customers book maintenance, installations, and non-emergency service appointments directly from your website."},{"question":"Do you include financing information pages?","answer":"Yes. We create dedicated financing pages that explain payment options for major equipment installations. This reduces friction for high-ticket purchases like new furnaces and AC systems."},{"question":"Will the site work well for emergency calls?","answer":"Absolutely. We design with emergency situations in mind — sticky call bars, one-tap mobile calling, prominent emergency service messaging, and fast page load times."},{"question":"Can I showcase the equipment brands I work with?","answer":"Yes. We create dedicated pages for each equipment brand you carry or service, which also helps capture search traffic from homeowners searching for brand-specific HVAC service."},{"question":"Do you handle the content writing?","answer":"Yes. We write professional, SEO-optimized content for every page based on your services, service area, and brand positioning."}]',
 4),

-- 5) Pool Service Website Design
('Pool Service Website Design', 'pool-service-web-design',
 'Custom website design for pool cleaning and pool service companies. Generate pool maintenance leads and service contracts online.',
 'Pool Service Website', 'Design That Makes Waves',
 'Professional websites designed for pool cleaning and maintenance companies to generate recurring service contracts.',
 'Pool Service Websites That Generate Recurring Contracts',
 'A professional website is essential for pool service companies looking to grow their customer base and build recurring maintenance contracts. Homeowners with pools are actively searching online for reliable, professional pool cleaning and maintenance services. Our custom pool service web design builds websites that capture these searches, communicate your expertise, and convert visitors into long-term service contract customers.

Every pool service website we build features seasonal maintenance plan pages with clear pricing tiers, water chemistry education content that demonstrates your expertise, before-and-after pool transformation galleries, equipment service and repair pages, and a streamlined contract signup process. We optimize for local search terms like "pool cleaning near me" and "weekly pool service" to ensure your business appears when pool owners in your area are actively searching for service providers.',
 '["Service Contract Pages","Water Chemistry Content","Pool Equipment Pages","Seasonal Pricing Plans","Before & After Galleries","Chemical Delivery Scheduling"]',
 'Why Choose Our Pool Service Web Design?',
 'Pool owners want reliable, recurring service — your website should sell that reliability.',
 '[{"title":"Contract Focused","description":"Service plan pages with weekly, bi-weekly, and monthly pricing tiers turn one-time visitors into recurring contract customers."},{"title":"Authority Content","description":"Water chemistry guides and pool care tips establish you as the local pool care expert and boost search rankings."},{"title":"Visual Showcase","description":"Crystal-clear pool galleries and green-to-clean transformations demonstrate your quality of work instantly."},{"title":"Local Dominance","description":"Neighborhood-specific service area pages help you rank in every community you serve, not just your city center."}]',
 '[{"question":"Can customers sign up for service plans online?","answer":"Yes! We create dedicated service plan pages with pricing tiers and online signup forms that make it easy for customers to commit to recurring maintenance contracts."},{"question":"Do you include pool equipment service pages?","answer":"Yes. We build pages for pump repair, filter cleaning, heater installation, automation systems, and other equipment services you offer — each optimized for local search."},{"question":"Will my website help me get more Google reviews?","answer":"Yes. We integrate review request workflows and display your existing Google reviews prominently to build trust with potential customers."},{"question":"Can I update seasonal pricing myself?","answer":"Absolutely. The content management system makes it simple to update pricing, add pool photos, and manage your service plan offerings."}]',
 5),

-- 6) Construction Website Design
('Construction Website Design', 'construction-web-design',
 'Custom website design for construction companies and general contractors. Professional sites that win bids and showcase project portfolios.',
 'Construction Website', 'Design That Wins Bids',
 'Professional websites built for general contractors, builders, and construction companies to showcase projects and win new business.',
 'Construction Websites That Win More Projects',
 'For construction companies and general contractors, your website is your digital portfolio and first impression for potential clients, property managers, and commercial decision-makers. Before they ever pick up the phone, they are reviewing your project gallery, reading your credentials, and comparing you to competitors. Our custom construction web design service builds professional, project-focused websites that communicate credibility, showcase your best work, and make it easy for decision-makers to request a bid.

Every construction website we build features detailed project portfolio galleries organized by project type (residential, commercial, renovation, new build), service capability pages, licensing and bonding information, team bios with credentials, and a professional bid request system. We understand that construction sales cycles are longer and involve multiple stakeholders, so every page is designed to provide the detailed information that committees, architects, and property owners need to choose your company with confidence.',
 '["Project Portfolio Galleries","Service Capability Pages","Licensing & Bond Information","Team Credential Profiles","Bid Request System","Safety Record Display"]',
 'Why Choose Our Construction Web Design?',
 'Decision-makers research online before they call — your website wins or loses the bid.',
 '[{"title":"Portfolio Showcase","description":"Organized project galleries by type (commercial, residential, renovation) with high-quality photos, descriptions, and project details."},{"title":"Credential Display","description":"Prominent licensing, bonding, insurance, and safety certification display builds confidence with property owners and general contractors."},{"title":"Professional Bids","description":"Structured bid request forms capture project scope, timeline, location, and budget to help you qualify leads before the first meeting."},{"title":"Team Profiles","description":"Detailed team bios with credentials, certifications, and experience humanize your company and build trust."}]',
 '[{"question":"Can I organize projects by type?","answer":"Yes. We create portfolio sections organized by project type — commercial, residential, renovation, new construction, tenant improvement — with detailed project pages including photos, descriptions, and specs."},{"question":"Do you include bid request functionality?","answer":"Yes. Professional bid request forms capture project details, timeline, budget range, and plans/specs to help you qualify opportunities before investing time in a site visit."},{"question":"Can I showcase my safety record?","answer":"Absolutely. We create dedicated safety pages displaying your EMR rating, OSHA compliance, safety training certifications, and incident-free project milestones."},{"question":"Will the site help me recruit?","answer":"Yes! We can include a careers page with current openings, company culture content, and an online application form to help attract qualified tradespeople."}]',
 6),

-- 7) Lawn Care Website Design
('Lawn Care Website Design', 'lawn-care-web-design',
 'Custom website design for lawn care and landscaping companies. Professional sites that generate seasonal leads and maintenance contracts.',
 'Lawn Care Website', 'Design That Grows Business',
 'Professional websites designed for landscaping and lawn maintenance companies to generate seasonal leads year-round.',
 'Lawn Care Websites That Grow Your Business Year-Round',
 'A professional website is essential for lawn care and landscaping companies looking to stand out in an increasingly competitive market. Property owners — both residential and commercial — search online when their current service stops showing up or when they move to a new area. Our custom lawn care web design builds websites that capture these high-intent searches, showcase your property transformations, and convert visitors into recurring maintenance customers through seasonal service plan signups.

Every lawn care website we design includes seasonal service pages (spring cleanup, weekly mowing, fall aeration, winter snow removal), property transformation galleries, service area neighborhood pages, maintenance plan pricing tiers, and easy online estimate request forms. We optimize for local search terms specific to your service area and services, ensuring your company appears prominently when property owners in your market are actively searching for a new lawn care provider.',
 '["Seasonal Service Pages","Property Transformation Gallery","Maintenance Plan Pricing","Service Area Pages","Online Estimate Requests","Snow Removal Integration"]',
 'Why Choose Our Lawn Care Web Design?',
 'Property owners search online when they need a new lawn service — be the company they find.',
 '[{"title":"Seasonal Selling","description":"Dedicated pages for spring, summer, fall, and winter services keep your site relevant and generating leads year-round."},{"title":"Visual Impact","description":"Before-and-after property transformation galleries demonstrate the dramatic improvement your service delivers."},{"title":"Recurring Revenue","description":"Maintenance plan pages with clear weekly/bi-weekly/monthly pricing convert one-time visitors into recurring contract customers."},{"title":"Neighborhood Pages","description":"Hyper-local service area pages for each neighborhood and community you serve dominate local search results."}]',
 '[{"question":"Can I showcase seasonal services?","answer":"Yes! We create dedicated pages for each seasonal service — spring cleanup, weekly mowing, fertilization, aeration, leaf removal, snow plowing — each optimized for seasonal search traffic."},{"question":"Do you include pricing for maintenance plans?","answer":"Yes. We build service plan pages with clear pricing tiers (weekly, bi-weekly, monthly) and online signup functionality to maximize recurring revenue."},{"question":"Will my website rank in my local area?","answer":"We optimize every site for local SEO including Google Business integration, service area pages, local keywords, and schema markup to help you rank in your specific market."},{"question":"Can I update photos and content myself?","answer":"Absolutely. The content management system makes it easy to add project photos, update seasonal pricing, and manage content without any technical knowledge."},{"question":"Do you handle the writing?","answer":"Yes. We write all content for your website including service descriptions, about page, FAQ section, and blog posts based on your services and market."}]',
 7)

ON CONFLICT (slug) DO NOTHING;
