# Bleach Resistant — Full Project Creation Guide

> **How this entire website was built from scratch using only HTML, CSS, JavaScript, and Supabase.**
> Use this guide to recreate the same architecture for any business website — web, desktop, or mobile.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Technology Stack](#2-technology-stack)
3. [Project Structure](#3-project-structure)
4. [Step 1: Supabase Setup](#4-step-1-supabase-setup)
5. [Step 2: Authentication System](#5-step-2-authentication-system)
6. [Step 3: CSS Design System](#6-step-3-css-design-system)
7. [Step 4: Public Pages](#7-step-4-public-pages)
8. [Step 5: Dynamic Content Loader](#8-step-5-dynamic-content-loader)
9. [Step 6: Admin Panel](#9-step-6-admin-panel)
10. [Step 7: Order System](#10-step-7-order-system)
11. [Step 8: Client Account System](#11-step-8-client-account-system)
12. [Step 9: Chat Widget](#12-step-9-chat-widget)
13. [Step 10: Deployment](#13-step-10-deployment)
14. [Prompt to Recreate This Project](#14-prompt-to-recreate-this-project)
15. [Navigation System & Custom Pages](#15-navigation-system--custom-pages)
16. [Cache Version Tracking](#16-cache-version-tracking)
17. [Hosting on Hostinger (Complete Guide)](#17-hosting-on-hostinger-complete-guide)

---

## 1. Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                  BROWSER                         │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐  │
│  │  Public   │  │  Admin   │  │  Account      │  │
│  │  Pages    │  │  Panel   │  │  Dashboard    │  │
│  │  (HTML)   │  │  (HTML)  │  │  (HTML)       │  │
│  └────┬─────┘  └────┬─────┘  └───────┬───────┘  │
│       │              │                │          │
│  ┌────┴──────────────┴────────────────┴───────┐  │
│  │         supabase-config.js                  │  │
│  │  (Auth helpers, upload, Supabase client)    │  │
│  └────────────────────┬───────────────────────┘  │
│                       │                          │
│  ┌────────────────────┴───────────────────────┐  │
│  │         content-loader.js                   │  │
│  │  (Nav, slider, products, sections, chat,  │  │
│  │   dynamic nav, page block renderer)         │  │
│  └────────────────────┬───────────────────────┘  │
└───────────────────────┼──────────────────────────┘
                        │ HTTPS (Supabase JS Client)
                        ▼
┌───────────────────────────────────────────────────┐
│                 SUPABASE                          │
│                                                   │
│  ┌─────────┐  ┌──────────┐  ┌─────────────────┐  │
│  │  Auth   │  │ Postgres │  │    Storage       │  │
│  │(email/  │  │(15+table)│  │  (media,         │  │
│  │password)│  │  + RLS)  │  │   attachments)   │  │
│  └─────────┘  └──────────┘  └─────────────────┘  │
└───────────────────────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────┐
│                  VERCEL                           │
│           (Static file hosting)                   │
│     Git push → auto-deploy in ~30 seconds         │
└───────────────────────────────────────────────────┘
```

**Key Principle:** Zero backend code. Every operation (auth, database, file storage) runs client-side through Supabase's JavaScript SDK. Security is enforced by Row Level Security (RLS) policies in Postgres.

---

## 2. Technology Stack

| Layer | Tool | Why |
|-------|------|-----|
| **Frontend** | Raw HTML + CSS + JS | No build step, instant deploy, works everywhere |
| **Database** | Supabase (Postgres) | Free tier, real-time, RLS security, auth built-in |
| **Auth** | Supabase Auth | Email/password, JWT tokens, no custom auth code |
| **Storage** | Supabase Storage | File uploads with bucket policies |
| **Hosting** | Vercel | Free, auto-deploy on git push, global CDN |
| **Fonts** | Google Fonts | Montserrat (headings) + Poppins (body) |
| **Analytics** | Google Analytics 4 | Traffic tracking |

**What you DON'T need:** Node.js, npm, React, Next.js, Express, MongoDB, Docker, AWS. None of it.

---

## 3. Project Structure

```
project/
├── overhaul.css              ← Public design system (1300+ lines)
├── admin.css                 ← Admin panel design system (1000+ lines)
├── supabase-config.js        ← Supabase client + auth helpers (1 file)
├── content-loader.js         ← All dynamic functionality (1 file)
├── supabase-setup.sql        ← Complete database schema (run once)
├── vercel.json               ← Routing config
│
├── home.html                 ← Homepage with dynamic hero slider
├── product.html              ← All products with dynamic tabs
├── product-detail.html       ← Single product view
├── order.html                ← Multi-step order wizard
├── account.html              ← Client dashboard (orders, profile)
├── login.html                ← Login page
├── signup.html               ← Registration page
│
├── headgear.html             ← Category page (dynamic sections + products)
├── basicpoly.html            ← Category page
├── customlogos.html          ← Category page
├── grapicdesign.html         ← Category page
├── wrapdesign.html           ← Category page
├── ... (more category pages)
│
├── services.html             ← Services overview
├── sublimation-service.html  ← Sublimation service page (DB-driven)
├── web-design-service.html   ← Web design service page (DB-driven)
├── About.html                ← About page
├── FAQs.html                 ← FAQ with accordion
├── Pricelist.html            ← Pricing page
│
├── blog.html                 ← Blog listing page (from blog_posts table)
├── blog-post.html            ← Blog detail page (slug-based)
├── cotton.html               ← Cotton articles listing (from cotton_posts table)
├── cotton-detail.html        ← Cotton article detail (slug-based)
│
├── admin.html                ← Admin dashboard
├── admin-products.html       ← Product CRUD
├── admin-orders.html         ← Order management
├── admin-contacts.html       ← Contact/chat messages + reply
├── admin-slider.html         ← Hero slider CRUD
├── admin-sections.html       ← Page section editor
├── admin-pages.html          ← Visual page editor
├── admin-blog.html           ← Blog CMS (full CRUD + categories)
├── admin-cotton.html         ← Cotton CMS (full CRUD + categories)
├── admin-services.html       ← Service pages editor
├── admin-media.html          ← Media library
├── admin-navigation.html     ← Nav menu editor + Page Creator + Page Builder
├── admin-settings.html       ← Site settings (branding, SEO, etc.)
├── admin-analytics.html      ← Analytics dashboard
│
├── supabase-setup.sql        ← Core database schema
├── supabase-migration-blog.sql    ← Blog tables migration
├── supabase-migration-cotton.sql  ← Cotton tables migration
├── supabase-migration-webdesign.sql ← Web design service migration
├── page.html                 ← Dynamic page renderer (for custom pages)
├── sitemap.xml               ← SEO sitemap
└── favicon.svg               ← Site icon
```

**Rule: 1 HTML file = 1 page.** Admin pages are self-contained — each has its own `<script>` block with all CRUD logic inline. No bundler, no imports, no build step.

---

## 4. Step 1: Supabase Setup

### 4.1 Create Project

1. Go to [supabase.com](https://supabase.com) → New Project
2. Note your **Project URL** and **Anon Key** (found in Settings → API)
3. Enable **Email Auth** in Authentication → Providers

### 4.2 Database Schema

Create 8 tables. The pattern for every table:

```sql
-- 1. Create the table
CREATE TABLE IF NOT EXISTS products (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW(),
  name        TEXT NOT NULL,
  slug        TEXT UNIQUE NOT NULL,
  category    TEXT NOT NULL,
  price_from  DECIMAL(10,2),
  image_url   TEXT,
  active      BOOLEAN DEFAULT true,
  sort_order  INTEGER DEFAULT 0
);

-- 2. Enable Row Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- 3. Public can READ active items
CREATE POLICY "products_public_read" ON products
  FOR SELECT TO anon
  USING (active = true);

-- 4. Logged-in users can read all
CREATE POLICY "products_auth_read" ON products
  FOR SELECT TO authenticated
  USING (true);

-- 5. Only admin can write (INSERT/UPDATE/DELETE)
CREATE POLICY "products_admin_write" ON products
  FOR ALL TO authenticated
  USING (auth.email() = 'your-admin@email.com')
  WITH CHECK (auth.email() = 'your-admin@email.com');

-- 6. Grant permissions
GRANT SELECT ON TABLE products TO anon;
GRANT ALL ON TABLE products TO authenticated;
```

**This exact pattern repeats for every table.** The only things that change are:
- Table name and columns
- Which roles get READ access (anon vs authenticated)
- The admin email in the USING clause

### 4.3 The 8 Tables

| Table | Public Read | Purpose |
|-------|------------|---------|
| `orders` | No (admin only) | Customer orders |
| `contacts` | No (admin only) | Chat/contact messages |
| `products` | Yes (active only) | Product catalog |
| `hero_slides` | Yes (active only) | Homepage slider |
| `category_sections` | Yes (active only) | Dynamic page sections |
| `page_content` | Yes | CMS content overrides |
| `site_settings` | Yes | Branding, SEO, config |
| `media` | No (admin only) | Uploaded file metadata |

### 4.4 Storage Buckets

```sql
-- Public upload bucket (anyone can upload order attachments)
INSERT INTO storage.buckets (id, name, public) VALUES ('order-attachments', 'order-attachments', true);

-- Admin-only bucket (media library)
INSERT INTO storage.buckets (id, name, public) VALUES ('media', 'media', true);
```

### 4.5 The Settings Table Pattern (Key-Value Store)

Instead of a single row with 50 columns, use a key-value pattern:

```sql
CREATE TABLE site_settings (
  id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key   TEXT UNIQUE NOT NULL,
  value TEXT
);
```

Save: `db.from('site_settings').upsert({ key: 'biz_name', value: 'My Business' }, { onConflict: 'key' })`
Load: `db.from('site_settings').select('*')` → loop into object

---

## 5. Step 2: Authentication System

### 5.1 The Config File (supabase-config.js)

This is the **only shared JavaScript file** between public and admin pages:

```javascript
// ── Config ──
const SUPABASE_URL = 'https://YOUR-PROJECT.supabase.co';
const SUPABASE_ANON = 'your-anon-key-here';
const BR_ADMIN_EMAIL = 'admin@yourdomain.com';

// ── Supabase Client (singleton) ──
const db = supabase.createClient(SUPABASE_URL, SUPABASE_ANON);

// ── Auth Helpers ──
async function brGetUser() {
  const { data } = await db.auth.getUser();
  return data?.user || null;
}

function brIsAdmin(user) {
  return user && user.email === BR_ADMIN_EMAIL;
}

async function brRequireAuth() {
  const user = await brGetUser();
  if (!user) { window.location.href = 'login.html'; return null; }
  return user;
}

async function brRequireAdmin() {
  const user = await brGetUser();
  if (!user || !brIsAdmin(user)) { window.location.href = 'home.html'; return null; }
  document.body.style.display = 'flex'; // Reveal admin page
  return user;
}

async function brSignOut() {
  await db.auth.signOut();
  window.location.href = 'home.html';
}

// ── File Upload Helper ──
async function brUploadFile(bucket, file, folder) {
  const ext = file.name.split('.').pop();
  const path = (folder ? folder + '/' : '') + Date.now() + '-' + Math.random().toString(36).substr(2,6) + '.' + ext;
  const { error } = await db.storage.from(bucket).upload(path, file);
  if (error) throw error;
  const { data } = db.storage.from(bucket).getPublicUrl(path);
  return { path, url: data.publicUrl };
}
```

### 5.2 The Admin Page Guard Pattern

Every admin page uses this pattern:

```html
<!-- Body starts hidden -->
<body class="admin-hidden" style="display:none">
  <!-- ... page content ... -->

  <script>
  (async () => {
    const user = await brRequireAdmin(); // Redirects if not admin
    // brRequireAdmin() calls document.body.style.display = 'flex'
    // Page is now visible — safe to load data
    await loadData();
  })();
  </script>
</body>
```

**Why `display:none`?** Prevents flash of admin content before auth check completes.

### 5.3 Login Page Pattern

```javascript
form.addEventListener('submit', async (e) => {
  e.preventDefault();
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;

  const { data, error } = await db.auth.signInWithPassword({ email, password });
  if (error) { showError(error.message); return; }

  // Redirect based on role
  if (data.user.email === BR_ADMIN_EMAIL) {
    window.location.href = 'admin.html';
  } else {
    window.location.href = 'home.html';
  }
});
```

### 5.4 Auth-Aware Public Navbar

In content-loader.js, after the page loads:

```javascript
if (typeof db !== 'undefined') {
  brGetUser().then(function(user) {
    if (user) {
      // Replace "Order Now" with "My Account" button
      var actionsDiv = document.querySelector('.br-nav-actions');
      if (actionsDiv) {
        actionsDiv.innerHTML =
          '<a href="account.html" class="br-btn br-btn-outline br-btn-sm">My Account</a>' +
          '<a href="order.html" class="br-btn br-btn-primary br-btn-sm">Order Now</a>';
      }
    }
  });
}
```

---

## 6. Step 3: CSS Design System

### 6.1 Design Tokens (CSS Custom Properties)

```css
:root {
  /* Brand Colors */
  --br-primary: #C7065C;
  --br-primary-dark: #9a0447;
  --br-dark: #1a1a2e;
  --br-text: #2c2c2c;
  --br-bg: #ffffff;
  --br-bg-alt: #f8f9fa;

  /* Semantic Colors */
  --br-success: #22c55e;
  --br-warning: #f59e0b;
  --br-danger: #ef4444;
  --br-info: #3b82f6;

  /* Typography */
  --font-heading: 'Montserrat', sans-serif;
  --font-body: 'Poppins', sans-serif;

  /* Spacing & Layout */
  --nav-height: 80px;
  --container-max: 1200px;

  /* Elevation (Shadow Scale) */
  --shadow-xs: 0 1px 2px rgba(0,0,0,0.05);
  --shadow-sm: 0 2px 8px rgba(0,0,0,0.08);
  --shadow-md: 0 4px 16px rgba(0,0,0,0.1);
  --shadow-lg: 0 8px 32px rgba(0,0,0,0.12);
  --shadow-xl: 0 16px 48px rgba(0,0,0,0.16);

  /* Border Radius Scale */
  --radius-sm: 6px;
  --radius-md: 10px;
  --radius-lg: 16px;
  --radius-xl: 20px;
  --radius-full: 9999px;

  /* Transitions */
  --ease: cubic-bezier(0.4, 0, 0.2, 1);
  --transition: 0.3s var(--ease);
}
```

### 6.2 Core Layout Classes

```css
/* Container */
.br-container { max-width: var(--container-max); margin: 0 auto; padding: 0 24px; }

/* Sections */
.br-section { padding: 80px 0; }
.br-section-alt { padding: 80px 0; background: var(--br-bg-alt); }

/* Labels */
.br-section-label {
  display: inline-block; font-size: 0.7rem; font-weight: 700;
  letter-spacing: 2px; text-transform: uppercase; color: var(--br-primary);
}

/* Grids */
.br-grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 48px; }
.br-grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 32px; }

/* Buttons */
.br-btn {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 14px 32px; border-radius: var(--radius-full); font-weight: 700;
  text-decoration: none; transition: var(--transition);
}
.br-btn-primary { background: var(--br-primary); color: #fff; }
.br-btn-outline { border: 2px solid var(--br-primary); color: var(--br-primary); }
```

### 6.3 Animation System

```css
/* Elements start invisible, animate in when scrolled into view */
[data-animate] { opacity: 0; transform: translateY(30px); transition: 0.6s var(--ease); }
[data-animate].animated { opacity: 1; transform: translateY(0); }
[data-animate="fade-in"] { transform: none; }
[data-animate="fade-left"] { transform: translateX(-30px); }
[data-animate="scale-up"] { transform: scale(0.92); }
```

In JS (IntersectionObserver):
```javascript
var animObserver = new IntersectionObserver(function(entries) {
  entries.forEach(function(entry) {
    if (entry.isIntersecting) {
      entry.target.classList.add('animated');
      animObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('[data-animate]').forEach(el => animObserver.observe(el));
```

Usage in HTML:
```html
<div data-animate="fade-up">This fades in from below when scrolled into view</div>
```

---

## 7. Step 4: Public Pages

### 7.1 Page Template

Every public page follows this structure:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Page Title — Brand Name</title>
  <meta name="description" content="SEO description here">
  <link rel="icon" href="favicon.svg" type="image/svg+xml">
  <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800;900&family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="overhaul.css?v=10">
</head>
<body>
  <!-- Navbar (same on every page) -->
  <nav class="br-nav" id="navbar">...</nav>

  <!-- Page Header -->
  <section class="br-page-header">
    <div class="br-container">
      <nav class="br-breadcrumb">
        <a href="home.html">Home</a><span>/</span><span>Current Page</span>
      </nav>
      <h1>Page Title</h1>
      <p>Page subtitle description.</p>
    </div>
  </section>

  <!-- Content Sections -->
  <section class="br-section">
    <div class="br-container">
      <div data-animate="fade-up">
        <!-- Content here -->
      </div>
    </div>
  </section>

  <!-- CTA Banner -->
  <section class="br-cta-banner">
    <div class="br-container">
      <h2>Call to Action</h2>
      <a href="order.html" class="br-btn br-btn-primary br-btn-lg">Order Now</a>
    </div>
  </section>

  <!-- Footer (same on every page) -->
  <footer class="br-footer">...</footer>

  <!-- Scripts (same on every page) -->
  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
  <script src="supabase-config.js?v=7"></script>
  <script src="content-loader.js?v=15"></script>
  <script>
    // Page-specific calls
    brLoadCategorySection();
    brLoadProducts('productsContainer', { category: 'logos' });
  </script>
</body>
</html>
```

### 7.2 Category Page Pattern

Each product/service category page:
1. Has a `.br-page-header` with breadcrumb
2. Has static fallback content (visible if DB is empty)
3. Calls `brLoadCategorySection()` which replaces static content with DB sections
4. Has a `<div id="xxxProducts" class="br-products-grid"></div>` for dynamic products
5. Has a CTA banner at the bottom

### 7.3 Cache Busting

Always version your CSS and JS files:
```html
<link rel="stylesheet" href="overhaul.css?v=10">
<script src="content-loader.js?v=15"></script>
```
Bump the version number every time you change the file. This forces browsers to download the new version.

---

## 8. Step 5: Dynamic Content Loader

### 8.1 Single IIFE Pattern

All public-facing JS goes in ONE file wrapped in an IIFE:

```javascript
(function() {
  'use strict';

  // 1. Navbar scroll effect
  // 2. Mobile nav toggle
  // 3. Active nav link highlight
  // 4. Auth-aware navbar
  // 5. Scroll animations (IntersectionObserver)
  // 6. Reusable slider (brInitSlider)
  // 7. FAQ accordion
  // 8. Gallery lightbox
  // 9. Product tab filter
  // 10. brLoadProducts() — fetches from Supabase
  // 11. Content overrides — fetches page_content from Supabase
  // 12. brLoadCategorySection() — fetches category_sections
  // 13. brLoadHeroSlider() — fetches hero_slides
  // 14. Chat widget — builds UI, handles send

})();
```

### 8.2 brLoadProducts() Pattern

```javascript
window.brLoadProducts = async function(containerId, options) {
  var container = document.getElementById(containerId);
  if (!container || typeof db === 'undefined') return;

  // Show loading spinner
  container.innerHTML = '<div class="br-loading"><div class="br-spinner"></div></div>';

  try {
    // Build query dynamically
    var query = db.from('products').select('*').eq('active', true);
    if (options.category) query = query.eq('category', options.category);
    if (options.featured) query = query.eq('featured', true);
    if (options.limit) query = query.limit(options.limit);
    query = query.order('sort_order', { ascending: true });

    var result = await query;
    if (result.error) throw result.error;

    if (result.data.length === 0) {
      container.innerHTML = '<div class="br-empty"><p>No products yet.</p></div>';
      return;
    }

    // Render product cards
    container.innerHTML = result.data.map(function(p) {
      return '<div class="br-product-card" data-category="' + p.category + '">' +
        '<a href="product-detail.html?slug=' + p.slug + '">' +
          '<div class="br-product-image"><img src="' + p.image_url + '" alt="' + p.name + '"></div>' +
          '<div class="br-product-info">' +
            '<h3>' + p.name + '</h3>' +
            '<span class="br-product-price">From $' + p.price_from + '</span>' +
          '</div>' +
        '</a></div>';
    }).join('');
  } catch (err) {
    container.innerHTML = '<div class="br-empty"><p>Unable to load products.</p></div>';
  }
};
```

### 8.3 brLoadCategorySection() Pattern

```javascript
window.brLoadCategorySection = async function() {
  var page = window.location.pathname.split('/').pop();

  var result = await db.from('category_sections').select('*')
    .eq('page_name', page).eq('active', true);

  if (result.data.length === 0) return; // Keep static fallback

  // Hide all static sections between page header and CTA
  var header = document.querySelector('.br-page-header');
  var sibling = header.nextElementSibling;
  while (sibling) {
    if (sibling.className.indexOf('br-cta-banner') >= 0) break;
    if (!sibling.querySelector('.br-products-grid')) { // Don't hide products!
      sibling.style.display = 'none';
    }
    sibling = sibling.nextElementSibling;
  }

  // Build fresh HTML from DB data and insert before CTA
  sections.forEach(function(s) {
    var wrapper = document.createElement('section');
    wrapper.className = 'br-section';
    wrapper.innerHTML = /* ... build from s.heading, s.description, s.image_url, etc. */
    ctaBanner.parentNode.insertBefore(wrapper, ctaBanner);
  });
};
```

### 8.4 brLoadHeroSlider() Pattern

```javascript
window.brLoadHeroSlider = async function() {
  var hero = document.querySelector('.br-hero');
  if (!hero) return;

  var result = await db.from('hero_slides').select('*')
    .eq('active', true).order('sort_order', { ascending: true });

  var slides = result.data || [];
  if (slides.length === 0) {
    // Build a default fallback slide in JS
    hero.innerHTML = '<div class="br-slides"><div class="br-slide active">/* default */</div></div>';
    return;
  }

  // Build slides from DB
  hero.innerHTML = '<div class="br-slides">' +
    slides.map(function(s, i) {
      return '<div class="br-slide' + (i === 0 ? ' active' : '') + '" style="background:...">' +
        '<div class="br-hero-content">' +
          '<h1>' + s.title + ' <span>' + s.highlight + '</span></h1>' +
          '<p>' + s.subtitle + '</p>' +
          // badges, buttons, optional image
        '</div></div>';
    }).join('') +
    '</div><div class="br-dots"></div><button class="br-arrow br-prev">‹</button><button class="br-arrow br-next">›</button>';

  brInitSlider(hero); // Initialize slider behavior
};
```

---

## 9. Step 6: Admin Panel

**See [GUIDE-ADMIN-PANEL.md](GUIDE-ADMIN-PANEL.md) for the complete admin panel guide.**

Quick overview: Every admin page follows the same CRUD pattern:
1. Sidebar navigation (same on all admin pages)
2. `brRequireAdmin()` guard on page load
3. Load data from Supabase → render in table/cards
4. Modal form for create/edit
5. Save = `db.from('table').insert()` or `.update()`
6. Delete with confirmation
7. Toast notifications for feedback
8. Search/filter/pagination as needed
9. CSV/JSON export

---

## 10. Step 7: Order System

### 10.1 Multi-Step Wizard Form

The order form uses a step wizard pattern:

```javascript
var currentStep = 1;
var totalSteps = 4;

function showStep(n) {
  // Hide all steps
  document.querySelectorAll('.step-content').forEach(s => s.style.display = 'none');
  // Show target step
  document.getElementById('step-' + n).style.display = 'block';
  // Update progress indicators
  document.querySelectorAll('.step-indicator').forEach((s, i) => {
    s.classList.toggle('active', i + 1 === n);
    s.classList.toggle('completed', i + 1 < n);
  });
  currentStep = n;
}

function nextStep() {
  if (validateStep(currentStep)) showStep(currentStep + 1);
}

function prevStep() {
  if (currentStep > 1) showStep(currentStep - 1);
}
```

### 10.2 Conditional Form Sections

Show different fields based on service type:

```javascript
serviceSelect.addEventListener('change', function() {
  // Hide all dynamic sections
  document.querySelectorAll('[id^="ds-"]').forEach(s => s.style.display = 'none');
  // Show the one matching selected category
  var category = getCategoryFromService(this.value);
  var section = document.getElementById('ds-' + category);
  if (section) section.style.display = 'block';
});
```

### 10.3 File Upload (Drag & Drop)

```javascript
var dropzone = document.getElementById('dropzone');
dropzone.addEventListener('dragover', e => { e.preventDefault(); dropzone.classList.add('dragover'); });
dropzone.addEventListener('dragleave', () => dropzone.classList.remove('dragover'));
dropzone.addEventListener('drop', async e => {
  e.preventDefault();
  var file = e.dataTransfer.files[0];
  if (file.size > 20 * 1024 * 1024) { alert('Max 20MB'); return; }
  var result = await brUploadFile('order-attachments', file, 'orders');
  attachmentUrl = result.url;
});
```

### 10.4 Submit Pattern

```javascript
// Collect all 25+ fields
var orderData = {
  first_name: el('firstName').value,
  last_name: el('lastName').value,
  email: el('email').value,
  // ... all other fields
  source_page: window.location.href,
  user_id: currentUser ? currentUser.id : null
};

var { data, error } = await db.from('orders').insert(orderData).select();
if (error) throw error;

// Show success with reference number
var ref = 'BR-' + data[0].id.substring(0, 6).toUpperCase();
showSuccessScreen(ref);
```

---

## 11. Step 8: Client Account System

### 11.1 Auth Check Pattern (Non-Admin)

```javascript
(async function() {
  var user = await brGetUser();
  if (!user) {
    document.getElementById('auth-required').style.display = 'block';
    return;
  }
  document.getElementById('account-content').style.display = 'block';

  // Load user data
  loadOrders(user);
  loadProfile(user);
})();
```

### 11.2 Fetch User Orders

```javascript
async function loadOrders(user) {
  var { data } = await db.from('orders').select('*')
    .or('user_id.eq.' + user.id + ',email.eq.' + user.email)
    .order('created_at', { ascending: false });

  // Deduplicate by order ID
  var seen = {};
  var orders = (data || []).filter(o => !seen[o.id] && (seen[o.id] = true));

  // Render order cards
}
```

### 11.3 Profile Update

```javascript
async function saveProfile() {
  await db.auth.updateUser({
    data: {
      full_name: el('firstName').value + ' ' + el('lastName').value,
      phone: el('phone').value,
      company: el('company').value
    }
  });
}
```

---

## 12. Step 9: Chat Widget

### 12.1 Auto-Injected on Every Page

The chat widget is built entirely in JS and appended to `document.body`:

```javascript
// Skip admin and auth pages
if (currentPage.indexOf('admin') === 0 || currentPage === 'login.html') return;

var chatWidget = document.createElement('div');
chatWidget.id = 'br-chat-widget';
chatWidget.innerHTML = /* floating bubble + expandable panel + form */;
document.body.appendChild(chatWidget);
```

### 12.2 Submit to Contacts Table

```javascript
form.addEventListener('submit', async function(e) {
  e.preventDefault();
  var name = nameInput.value.trim();
  var email = emailInput.value.trim();
  var msg = messageInput.value.trim();

  await db.from('contacts').insert({
    name: name,
    email: email,
    message: msg,
    page_source: window.location.pathname.split('/').pop()
  });

  // Show confirmation in chat bubble
  // Reset form fields
});
```

Admin sees all messages in `admin-contacts.html` and can reply (saved as `admin_reply` + `replied_at`).

---

## 13. Step 10: Deployment

### 13.1 Vercel Setup

1. Push code to GitHub
2. Connect GitHub repo to [vercel.com](https://vercel.com)
3. Set Framework Preset to "Other" (static files)
4. Deploy

### 13.2 vercel.json (Routing)

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/$1" }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" }
      ]
    }
  ]
}
```

### 13.3 Deploy Workflow

```bash
# Make changes
git add -A
git commit -m "Description of changes"
git push origin master
# Vercel auto-deploys in ~30 seconds
```

---

## 14. Prompt to Recreate This Project

> **Give this ENTIRE section to any AI assistant to recreate the project from scratch.**
> It contains every detail — architecture, file structure, database schema, CSS patterns, JS functions, admin panel, deployment, and wiring.

### Quick Summary Prompt (for a short conversation)

```
Create a custom sublimation printing business website (Bleach Resistant brand) with:
- Static HTML files only (no framework, no build step, no npm)
- Vanilla CSS with design tokens + admin.css
- Vanilla JS + Supabase JS SDK (CDN)
- Supabase for database (11 tables with RLS), auth (email/password), storage (2 buckets)
- Vercel for hosting (auto-deploy from GitHub)
- 20+ public pages, 10 admin pages, client account dashboard
- Dynamic content loaded from DB (hero slider, products, sections, navigation, custom pages)
- Chat widget on all public pages
- Full-width responsive navbar with hamburger at 1100px
See GUIDE-PROJECT.md and GUIDE-ADMIN-PANEL.md for complete architecture and wiring.
```

---

### FULL Detailed Recreation Prompt (copy everything below)

```
=== BLEACH RESISTANT — COMPLETE PROJECT RECREATION PROMPT ===

You are building a complete business website with admin panel for a custom
sublimation printing company called "Bleach Resistant" based in Guelph, Ontario, Canada.

============================
TECHNOLOGY RULES (STRICT)
============================

Use ONLY these technologies:
- Static HTML files (1 file = 1 page, no framework, no build step)
- Vanilla CSS with CSS custom properties (design tokens)
- Vanilla JavaScript (ES5-compatible, no imports, no modules)
- Supabase JS SDK v2 loaded from CDN (not npm)
- Supabase for: Postgres database, Auth (email/password), Storage (file uploads)
- Vercel for static hosting (auto-deploy from GitHub push)
- Google Fonts: Montserrat (headings) + Poppins (body)

DO NOT USE: Node.js, npm, React, Next.js, Express, MongoDB, Docker, webpack,
TypeScript, ES modules, import statements, or any build tools.

============================
ARCHITECTURE OVERVIEW
============================

Browser → supabase-config.js (client init + auth helpers)
       → content-loader.js (all dynamic content: nav, slider, products, sections, chat, page blocks)
       → overhaul.css (public design system, 1300+ lines)
       → admin.css (admin panel design system, 1000+ lines)
       → Supabase (Postgres 11 tables + RLS + Auth + Storage)
       → Vercel (static CDN, auto-deploy)

Security: Zero backend code. RLS policies on every table enforce access control.
Admin pages: body starts display:none, revealed only after brRequireAdmin() confirms admin email.

============================
FILE STRUCTURE
============================

project/
├── overhaul.css              ← Public design system (design tokens, navbar, hero, products, services, FAQ, footer, responsive)
├── admin.css                 ← Admin panel styles (sidebar, tables, modals, stats, forms, toasts)
├── supabase-config.js        ← Supabase client init, brGetUser(), brRequireAdmin(), brUploadFile(), brSignOut()
├── content-loader.js         ← brLoadProducts(), brLoadHeroSlider(), brLoadCategorySection(), brLoadDynamicNav(), brRenderPageBlocks(), chat widget, scroll animations, auth-aware navbar
├── supabase-setup.sql        ← Complete DB schema (11 tables + RLS + grants)
├── vercel.json               ← URL rewrites (/p/:slug → page.html?slug=:slug) + security headers
│
├── home.html                 ← Homepage: hero slider, featured products, services preview, stats, CTA
├── product.html              ← All products with category tabs (filter by category)
├── product-detail.html       ← Single product view (?id=UUID)
├── order.html                ← Multi-step order wizard (4 steps, file upload, conditional fields per service type)
├── account.html              ← Client dashboard (order history, profile edit, password change)
├── login.html                ← Login page (Supabase Auth email/password)
├── signup.html               ← Registration page
│
├── headgear.html             ← Category page (dynamic sections from DB)
├── basicpoly.html            ← Category page
├── stockdesigns.html         ← Category page
├── fabricdescriptions.html   ← Category page
├── sublimationprinting.html  ← Category page
├── services.html             ← Services overview page
├── grapicdesign.html         ← Service page
├── customlogos.html          ← Service page
├── wrapdesign.html           ← Service page
├── copyofwashingsamples.html ← Gallery page
├── About.html                ← About page
├── FAQs.html                 ← FAQ with accordion
├── Pricelist.html            ← Pricing page
├── sizechart.html            ← Size chart page
├── finprint.html             ← Info page
├── privacypolicy.html        ← Privacy policy
├── termsconditions.html      ← Terms & conditions
│
├── page.html                 ← Dynamic page renderer (reads ?slug= or /p/:slug, fetches custom_pages + page_blocks from DB)
│
├── admin.html                ← Admin dashboard (stat cards, recent orders, recent contacts)
├── admin-products.html       ← Products CRUD (image upload, gallery, optgroup categories: Site Pages + Custom Pages from DB)
├── admin-orders.html         ← Orders management (status update, search, filter, CSV export, pagination)
├── admin-contacts.html       ← Contacts + admin reply feature (replied_at timestamp)
├── admin-slider.html         ← Hero slider CRUD (bg image upload, badges JSON, 2 CTAs)
├── admin-sections.html       ← Page sections editor (per-page, checklist JSON, image upload)
├── admin-pages.html          ← Visual page editor (iframe preview, click-to-select)
├── admin-media.html          ← Media library (drag & drop, grid, search, copy URL)
├── admin-navigation.html     ← 5 tabs: Nav Items CRUD, Pages list, Page Builder (8 templates, 11 block types), Custom Links, Redirects
├── admin-settings.html       ← Tabbed: Business info, Branding (color pickers), Social, SEO, Code injection, Maintenance mode, Backup/export
├── admin-analytics.html      ← Analytics dashboard with time range filter
│
├── sitemap.xml               ← SEO sitemap
└── favicon.svg               ← Site icon

============================
DATABASE SCHEMA (11 TABLES)
============================

All tables follow this pattern:
- UUID primary key with gen_random_uuid()
- created_at TIMESTAMPTZ DEFAULT NOW()
- Enable RLS on every table
- Public SELECT for content tables (anon role)
- ALL operations for admin (auth.email() = 'admin-email')
- Anon INSERT for orders + contacts (public forms)

TABLE 1: products
  id, created_at, updated_at, name, slug (unique), description, category, price_from, price_to,
  image_url, gallery (JSONB array of URLs), features (JSONB array), active, sort_order, badge_text
  -- category values: 'apparel', 'headgear', 'basicpoly', 'stockdesigns', 'sublimation', 'design', 'logos', 'wraps', 'page-{slug}'

TABLE 2: orders
  id, created_at, first_name, last_name, email, phone, company, service_type, source_page,
  product_name, quantity, sizes (JSONB), colors, design_notes, attachment_url,
  preferred_date, rush_order, delivery_method, address fields,
  status (new/in-progress/completed/cancelled), admin_notes, total_amount, user_id (nullable)

TABLE 3: contacts
  id, created_at, name, email, phone, company, message, page_source,
  status (new/read/replied), admin_reply, replied_at, read_at

TABLE 4: hero_slides
  id, created_at, title, subtitle, bg_type (image/gradient/video), bg_value,
  badges (JSONB array), cta1_text, cta1_link, cta2_text, cta2_link,
  overlay_opacity, text_align, active, sort_order

TABLE 5: category_sections
  id, created_at, updated_at, page (e.g. 'headgear.html'), section_title, section_subtitle,
  description, image_url, checklist (JSONB array), badge_text, layout (image-left/image-right/full),
  active, sort_order

TABLE 6: page_content
  id, created_at, page, section_key, content (JSONB), active

TABLE 7: site_settings
  id, key (unique), value (TEXT), updated_at
  -- Key-value pairs: business_name, business_email, phone, address, primary_color, logo_url,
  --   meta_title, meta_description, facebook_url, instagram_url, custom_head_code, maintenance_mode, etc.

TABLE 8: media
  id, created_at, filename, url, file_type, file_size, alt_text, folder, uploaded_by

TABLE 9: nav_items
  id, label, href, parent_id (self-reference for dropdowns), sort_order, location ('main'/'footer'),
  target ('_self'/'_blank'), icon, active, created_at

TABLE 10: custom_pages
  id, title, slug (unique), description, meta_description, template
  (blank/content/blog/product-showcase/gallery/landing/contact/faq),
  status (draft/published), created_at, updated_at

TABLE 11: page_blocks
  id, page_id (FK → custom_pages ON DELETE CASCADE), block_type
  (hero/text/image-text/products/gallery/faq/cta/form/html/spacer/section),
  content (JSONB), sort_order, active, created_at

STORAGE BUCKETS:
  - 'order-attachments': public read, authenticated upload
  - 'media': authenticated read/write (admin media library)

============================
CSS DESIGN SYSTEM (overhaul.css)
============================

DESIGN TOKENS (CSS custom properties):
  --br-primary: #C7065C (brand pink)
  --br-primary-dark: #9a0447
  --br-primary-light: #e8337d
  --br-dark: #1a1a2e
  --font-heading: 'Montserrat', sans-serif
  --font-body: 'Poppins', sans-serif
  --nav-height: 80px (68px on mobile)
  --container-max: 1200px (BUT navbar overrides to max-width: none)
  --section-pad: 100px 0
  Shadows: --shadow-xs through --shadow-xl
  Radii: --radius-sm(6px), --radius(10px), --radius-lg(16px), --radius-xl(24px), --radius-full(9999px)
  Transitions: --transition(0.3s), --transition-slow(0.6s)

NAVBAR (CRITICAL — full-width edge-to-edge):
  .br-nav { position: fixed; top:0; z-index:1000; backdrop-filter:blur(20px); }
  .br-nav > .br-container {
    display: flex; justify-content: space-between;
    max-width: none;  /* Override .br-container's 1200px */
    width: 100%; margin: 0; padding: 0 40px;
  }
  .br-logo { flex-shrink: 0; }
  .br-nav-menu { display: flex; gap: 6px; }
  .br-nav-links > li > a { font-size: 0.82rem; padding: 8px 12px; white-space: nowrap; }
  .br-nav-actions { flex-shrink: 0; margin-left: 12px; }
  .br-nav-toggle { display: none; } /* Shown at 1100px */

RESPONSIVE BREAKPOINTS:
  @media (max-width: 1200px) { nav padding: 8px 8px, font: 0.78rem }
  @media (max-width: 1100px) { hamburger menu, nav-height: 68px, off-canvas drawer }
  @media (max-width: 1024px) { section padding reduced, grid-4 → 2 columns }
  @media (max-width: 768px)  { grid-2/3 → 1 column, footer stacks }
  @media (max-width: 480px)  { container padding: 0 16px, products grid → 1 column }

COMPONENTS:
  .br-btn (primary, outline, white, dark, sm, lg, block)
  .br-product-card (image, overlay, badge, info, footer)
  .br-service-card (icon, hover effects)
  .br-faq-item (accordion, .active toggles max-height)
  .br-hero (full-height slider, badges, arrows, dots)
  .br-gallery-grid + .br-lightbox
  .br-table-wrap + .br-table
  .br-stats, .br-steps, .br-tabs
  .br-form (inputs, textareas, grid layout)
  [data-animate] (fade-up, fade-left, fade-right, scale-up) via IntersectionObserver
  .br-cta-banner (gradient dark background with radial glow)
  .br-footer (4-column grid, social icons, bottom bar)

============================
JS: supabase-config.js
============================

Loaded on every page. Provides:
  - var db = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
  - async brGetUser() → returns user object or null
  - async brRequireAdmin() → checks email, redirects if not admin, reveals body
  - async brUploadFile(bucket, file, folder) → returns {url, path}
  - brSignOut() → sign out + redirect to home
  - var ADMIN_EMAIL = 'usman@gmail.com'

============================
JS: content-loader.js
============================

Single IIFE that runs on DOMContentLoaded. Provides:

1. SCROLL ANIMATIONS:
   IntersectionObserver watches [data-animate] elements, adds .animated class + stagger index

2. NAVBAR:
   - Scroll detection → .scrolled class on .br-nav
   - Auth-aware: if user logged in, shows "My Account" link; if admin, shows "Admin" link
   - Mobile toggle: click navToggle → toggle .open on navMenu + .active on toggle + overlay
   - Event delegation on .br-nav-links for mobile dropdown toggles (click on dropdown arrow)

3. brLoadHeroSlider():
   - Fetches active hero_slides ordered by sort_order
   - Builds slide HTML with background image/gradient, title, subtitle, badges, CTA buttons
   - Auto-rotates every 5 seconds, arrow/dot navigation

4. brLoadProducts(containerId, options):
   - options: { limit, category, showTabs, page }
   - Fetches products from DB, renders .br-product-card grid
   - If showTabs: builds category tab buttons for filtering

5. brLoadCategorySection():
   - Reads data-section-page attribute from elements
   - Fetches category_sections for that page
   - Renders sections with image, checklist, badge, layout (image-left/image-right)

6. brLoadDynamicNav():
   - Queries nav_items WHERE active=true AND location='main'
   - Builds HTML: top-level items + dropdown menus for items with children
   - Replaces .br-nav-links innerHTML
   - Highlights active link based on current URL
   - Auto-invoked on all public pages (not admin, login, signup)

7. brRenderPageBlocks(container, page, blocks):
   - Renders 11 block types into HTML using existing CSS classes
   - Product blocks auto-default category to page-{slug} when no explicit category set
   - Each block renders as a .br-section with appropriate inner content

8. CHAT WIDGET:
   - Skips admin/login/signup pages
   - Creates floating button + expandable panel with name/email/message form
   - Submits to contacts table
   - Shows confirmation message in chat bubble

9. PAGE-SPECIFIC AUTO-LOADERS:
   - Home page: loads slider, featured products, category sections
   - Product page: loads all products with tabs
   - Category pages (headgear, basicpoly, etc.): loads sections + category products
   - page.html: loads custom_pages + page_blocks, auto-appends products if page-{slug} products exist

============================
ADMIN PANEL PATTERN
============================

Every admin page is self-contained HTML with inline <script>. Pattern:

HTML structure:
  <body style="display:none">
    <div class="sidebar"> (same copy-paste on every admin page)
      Brand header, nav links with icons, sign out button
    </div>
    <div class="main-content">
      <div class="topbar"> Page title + action button </div>
      <div class="content"> Tables/cards + modal form </div>
    </div>
    <div class="toast" id="toast"></div>
  </body>

JS pattern:
  1. brRequireAdmin() → guard
  2. let allItems = [] → global state
  3. loadItems() → db.from('table').select('*') → allItems = data → renderItems()
  4. renderItems() → build HTML table rows from allItems, wire action buttons
  5. openEditor(item?) → populate modal form (empty = create, filled = edit)
  6. saveItem() → validate → db.from('table').insert() or .update() → reload
  7. deleteItem(id) → confirm → db.from('table').delete() → reload
  8. filterItems() → client-side search on allItems
  9. showToast(msg, type) → success/error notification
  10. esc(str) → HTML escape for XSS prevention

ADMIN PAGES:
  admin.html              → 4 stat cards (products, orders, contacts, media) + recent orders table + recent contacts
  admin-products.html     → CRUD table, modal with: name, slug (auto-gen), category (2 optgroups: Site Pages + Custom Pages from DB), price range, image upload + gallery, features textarea→JSON, badge, active toggle
  admin-orders.html       → Read table, status badges (color-coded), view modal, status dropdown update, CSV export, pagination (25/page), search
  admin-contacts.html     → Table + reply textarea, marks as read on view, CSV export
  admin-slider.html       → CRUD: title, subtitle, bg type (image/gradient/video), badge JSON array editor, CTA buttons, overlay opacity, image upload
  admin-sections.html     → Per-page CRUD: select page → CRUD sections for that page. Image upload, checklist textarea, layout toggle, preview
  admin-pages.html        → Visual editor: iframe loads page, click elements to select, edit content inline
  admin-media.html        → Drag & drop upload grid, search filter, detail modal (alt text, URL copy), delete
  admin-navigation.html   → 5 TABS:
    Tab 1: Nav Items — CRUD for nav_items (label, href, parent dropdown, sort_order, target)
    Tab 2: Pages — List custom_pages with status badge, edit/delete
    Tab 3: Page Builder — Select page → add/reorder/edit blocks (11 types), template selector (8 templates)
    Tab 4: Custom Links — External link management
    Tab 5: Redirects — URL redirect management
  admin-settings.html     → 6 TABS: Business Info, Branding (live color pickers), Social Links, SEO, Code Injection (head/body), Maintenance Mode + Backup (export all tables as JSON)
  admin-analytics.html    → Stat cards with time range filter (7d/30d/90d/all)
  admin-reviews.html      → Approve/deny/edit/delete/add customer reviews. Stats row (total, approved, pending, avg rating). Filter by All/Pending/Approved. Search by name/text. Edit modal.

============================
PRODUCT CATEGORIES SYSTEM
============================

Products have a 'category' field. The admin product form shows categories in 2 optgroups:

"Site Pages" optgroup (hardcoded, maps to static page files):
  apparel     → product.html
  headgear    → headgear.html
  basicpoly   → basicpoly.html
  stockdesigns → stockdesigns.html
  sublimation → sublimationprinting.html
  design      → grapicdesign.html
  logos       → customlogos.html
  wraps       → wrapdesign.html

"Custom Pages" optgroup (dynamic, loaded from custom_pages DB table):
  page-{slug} → /p/{slug} (rendered by page.html)

When page.html renders a custom page:
  1. Product blocks auto-default category filter to page-{slug}
  2. If no product block exists but products with page-{slug} category exist, auto-append a product grid

The admin product form loads custom pages via: db.from('custom_pages').select('title,slug').order('title')
Each option: <option value="page-{slug}">{title}</option>

============================
NAVIGATION SYSTEM
============================

Static HTML nav is in every page file as fallback.
On load, brLoadDynamicNav() replaces it with DB-managed nav items.
If DB returns 0 items, static nav is kept.

Mobile dropdown toggles use EVENT DELEGATION on .br-nav-links (not per-element click handlers).
This is critical because brLoadDynamicNav() replaces innerHTML, which would destroy per-element listeners.

============================
CUSTOM PAGES (PAGE BUILDER)
============================

Created from admin-navigation.html Tab 3.
Rendered by page.html via brRenderPageBlocks().

URL routing (vercel.json): /p/:slug → page.html?slug=:slug

Templates (8): blank, content, blog, product-showcase, gallery, landing, contact, faq
Block types (11): hero, text, image-text, products, gallery, faq, cta, form, html, spacer, section

Each block's content is stored as JSONB in page_blocks.content column.
Blocks render using existing CSS classes from overhaul.css (br-section, br-hero, br-container, etc.)

============================
DEPLOYMENT & CACHE BUSTING
============================

GitHub repo → Vercel auto-deploy on push to master (~30 seconds)

Cache busting: Every CSS/JS file is referenced with ?v=N query param.
When editing shared files, bump the version across ALL HTML files:
  overhaul.css?v=10
  content-loader.js?v=15
  supabase-config.js?v=7

vercel.json:
{
  "rewrites": [
    { "source": "/p/:slug", "destination": "/page.html?slug=:slug" },
    { "source": "/(.*)", "destination": "/$1" }
  ],
  "headers": [
    { "source": "/(.*)", "headers": [
      { "key": "X-Frame-Options", "value": "DENY" },
      { "key": "X-Content-Type-Options", "value": "nosniff" }
    ]}
  ]
}

============================
KEY PATTERNS & RULES
============================

1. RLS IS YOUR BACKEND. No Express/Node needed. Supabase RLS policies enforce all access control.
2. ONE FILE PER FEATURE. Each admin page is self-contained. Copy-paste to reuse.
3. CACHE BUST RELIGIOUSLY. Every CSS/JS change needs ?v=N bump on ALL HTML files.
4. START HIDDEN, REVEAL AFTER AUTH. Admin pages: body { display: none } → revealed by brRequireAdmin().
5. FALLBACK TO STATIC. Dynamic loaders keep static HTML as fallback if DB fails.
6. KEY-VALUE SETTINGS. site_settings uses {key, value} pairs, not a wide table.
7. UPLOAD PATTERN. timestamp-random.ext → Supabase Storage → public URL → save in table.
8. TOAST FOR FEEDBACK. Every admin action shows success/error toast notification.
9. EVENT DELEGATION. Mobile nav dropdown toggles use delegation so they survive innerHTML replacement.
10. NO OVER-ENGINEERING. ~25 HTML files, 2 CSS files, 2 JS files, 1 SQL file. That's the entire project.
11. HTML ESCAPE EVERYTHING. Use esc() function for all user-generated content to prevent XSS.
12. NAVBAR FULL WIDTH. .br-nav > .br-container uses max-width:none to override the 1200px container.

============================
SUPABASE CONFIG VALUES
============================

Project URL: https://dbppxzkkgdtnmikkviyt.supabase.co
Anon Key: (in supabase-config.js — safe to expose with RLS)
Admin Email: usman@gmail.com
Live URL: https://bleach-resistant.vercel.app
GitHub: tzkusman/bleach-resistant (master branch)
```

---

## Key Lessons Learned

1. **RLS is your backend.** You don't need Express/Node. Supabase RLS policies ARE your API security layer.

2. **One file per feature.** Admin-products.html contains EVERYTHING for product management. No imports, no dependencies. Copy-paste to reuse.

3. **Cache bust religiously.** Every CSS/JS change needs a version bump: `?v=6` → `?v=7`. Browsers will serve stale files otherwise.

4. **Start hidden, reveal after auth.** `body { display: none }` → revealed by JS after auth check. Never flash admin content to unauthorized users.

5. **Fallback to static.** Dynamic loaders (sections, slider, products) keep static HTML as fallback. If DB is empty or fails, the page still works.

6. **Key-value settings.** Don't make a 50-column settings table. Use `{ key, value }` pairs with `upsert({ onConflict: 'key' })`.

7. **Upload pattern.** `timestamp-random.ext` filename → upload to Supabase Storage → get public URL → save URL in your table.

8. **Toast for feedback.** Every admin action shows a toast notification. Users need confirmation that something happened.

9. **Git push = deploy.** Vercel watches your repo. No CI/CD config needed. Push to master = live in 30 seconds.

10. **Don't over-engineer.** This entire website is ~20 HTML files, 2 CSS files, 2 JS files, and 1 SQL file. That's it. No node_modules, no webpack, no Docker.

---

## 15. Navigation System & Custom Pages

### 15.1 Dynamic Navigation

The navbar is managed from the admin panel and stored in the `nav_items` table. On every public page, `brLoadDynamicNav()` replaces the static `<ul class="br-nav-links">` with items from the DB.

**Database table: `nav_items`**
```sql
CREATE TABLE nav_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL,
  href TEXT NOT NULL DEFAULT '#',
  parent_id UUID REFERENCES nav_items(id) ON DELETE CASCADE,
  sort_order INT DEFAULT 0,
  location TEXT DEFAULT 'main',   -- 'main' or 'footer'
  target TEXT DEFAULT '_self',
  icon TEXT,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**How it works (content-loader.js):**
1. `brLoadDynamicNav()` queries `nav_items WHERE active=true AND location='main'`
2. Splits into top-level (no parent_id) and children (parent_id set)
3. Builds `<li>` HTML — dropdowns for items with children, plain links otherwise
4. Replaces `.br-nav-links` innerHTML
5. Highlights active link based on current URL
6. Mobile dropdown toggles use event delegation on `.br-nav-links` (not per-element listeners) so they survive innerHTML replacement

### 15.2 Custom Pages (Page Builder)

Custom pages are created from admin-navigation.html and rendered by page.html.

**Database tables:**
```sql
-- Pages
CREATE TABLE custom_pages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  meta_description TEXT,
  template TEXT DEFAULT 'blank',
  status TEXT DEFAULT 'draft',   -- 'draft' or 'published'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Blocks (each page has multiple blocks)
CREATE TABLE page_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id UUID REFERENCES custom_pages(id) ON DELETE CASCADE,
  block_type TEXT NOT NULL,
  content JSONB DEFAULT '{}',
  sort_order INT DEFAULT 0,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Block types (11 total):**
hero, text, image-text, products, gallery, faq, cta, form, html, spacer, section

**Templates (8 total):**
blank, content, blog, product-showcase, gallery, landing, contact, faq

**Rendering flow (page.html):**
1. Reads `?slug=` from URL
2. Fetches page from `custom_pages` + active blocks from `page_blocks`
3. Calls `brRenderPageBlocks(container, page, blocks)` from content-loader.js
4. Each block renders using existing CSS classes (br-section, br-hero, br-container, etc.)
5. Product blocks auto-default category to `page-{slug}` if no explicit category set
6. If no product block exists but products with category `page-{slug}` exist in DB, a product grid is auto-appended

**URL routing (vercel.json):**
```json
{ "source": "/p/:slug", "destination": "/page.html?slug=:slug" }
```
So `/p/blog` renders the custom page with slug "blog".

### 15.3 Product Categories → Pages

Products are assigned to pages via the `category` field:

| Category Value | Shows On Page | Type |
|---------------|---------------|------|
| `apparel` | product.html | Static |
| `headgear` | headgear.html | Static |
| `basicpoly` | basicpoly.html | Static |
| `stockdesigns` | stockdesigns.html | Static |
| `sublimation` | sublimationprinting.html | Static |
| `design` | grapicdesign.html | Static |
| `logos` | customlogos.html | Static |
| `wraps` | wrapdesign.html | Static |
| `page-blog` | /p/blog | Custom Page |
| `page-{slug}` | /p/{slug} | Custom Page |

The admin product form shows categories in optgroups: "Site Pages" (static pages with their .html filename shown) and "Custom Pages" (loaded dynamically from the `custom_pages` table).

### 15.4 Responsive Navbar (Full-Width, Edge-to-Edge)

The navbar spans the full viewport width with logo at the far left and nav items at the far right. The nav container overrides the default `.br-container` max-width:

```css
/* Navbar container — full width, no centering */
.br-nav > .br-container {
  max-width: none;      /* Override .br-container's 1200px */
  width: 100%;
  margin: 0;            /* No auto-centering */
  padding: 0 40px;      /* Breathing room at edges */
}

/* Fixed sizing for nav links */
.br-nav-links > li > a {
  font-size: 0.82rem;
  padding: 8px 12px;
  white-space: nowrap;
}

/* Intermediate breakpoint — tighter spacing */
@media (max-width: 1200px) {
  .br-nav-links > li > a { padding: 8px 8px; font-size: 0.78rem; }
  .br-nav-actions .br-btn { font-size: 0.75rem; padding: 8px 14px; }
  .br-nav-actions { gap: 6px; margin-left: 8px; }
}

/* Hamburger menu — kicks in at 1100px */
@media (max-width: 1100px) {
  .br-nav-toggle { display: flex; }
  .br-nav-menu { position: fixed; right: -100%; width: min(360px, 88vw); ... }
  .br-nav-menu.open { right: 0; }
}
```

**Breakpoints:**
- **> 1200px** — Full desktop, edge-to-edge navbar with comfortable spacing
- **1100–1200px** — Reduced padding/font-size for nav items
- **< 1100px** — Hamburger menu (raised from 768px to accommodate 8+ items)
- **< 768px** — Layout adjustments (grids go single-column, etc.)
- **< 480px** — Mobile: tighter container padding

**Key:** The nav container uses `max-width: none` to override the global `.br-container { max-width: var(--container-max) }` which is 1200px. This ensures the navbar always uses the full viewport width regardless of screen size.

---

## 16. Cache Version Tracking

Always bump version numbers when editing shared files:

| File | Current Version | Usage |
|------|----------------|-------|
| `overhaul.css` | `?v=10` | All public pages |
| `content-loader.js` | `?v=19` | All public pages |
| `supabase-config.js` | `?v=7` | All pages |

---

## 17. Hosting on Hostinger

See **[GUIDE-HOSTINGER.md](GUIDE-HOSTINGER.md)** for the simple 4-step Hostinger hosting guide:

1. Buy Hostinger hosting + domain
2. Connect GitHub repo for auto-deploy (webhook)
3. Create `.htaccess` (homepage + HTTPS)
4. Update Supabase redirect URLs

Your Supabase stays separate — Hostinger only hosts the static HTML/CSS/JS files.


---

## 18. Session Log � April 20, 2026

### Changes Made This Session

#### ? Customer Reviews System (Full Stack)

**Feature:** Customers can leave reviews on the home page. Admin can approve/deny/edit/delete them. Approved reviews display publicly.

**Database table** (eviews) � added to supabase-setup.sql Section 13:
`sql
CREATE TABLE IF NOT EXISTS reviews (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  author_name TEXT NOT NULL,
  location    TEXT,
  rating      INTEGER CHECK (rating BETWEEN 1 AND 5) DEFAULT 5,
  review_text TEXT NOT NULL,
  approved    BOOLEAN DEFAULT false,
  sort_order  INTEGER DEFAULT 0
);
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
-- Policies: anon can SELECT approved=true, anon can INSERT approved=false, admin can do ALL
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT, INSERT ON TABLE reviews TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE reviews TO authenticated;
`

**home.html � Reviews section added:**
- Grid: <div id="reviewsGrid" class="br-reviews-grid"> populated by JS
- Empty state: <div id="reviewsEmpty"> shown if 0 approved reviews
- User submission form: id="reviewForm" with name, location, star picker, textarea
- Inline JS: loadReviews() polls until db is ready, fetches approved reviews, builds cards with .animated class directly (bypasses IntersectionObserver invisible bug)
- Star picker: <div id="starPicker"> with 5 <span data-val="N"> elements, JS highlights gold on hover/click
- Form submit: inserts with pproved: false, shows confirmation message

**overhaul.css � New classes added:**
- .br-reviews-grid � CSS grid, auto-fit columns min 280px
- .br-review-card � white card with border, hover lift
- .br-review-stars / .br-star / .br-star.active � star display (active = #f59e0b gold)
- .br-star-picker / .br-star-picker span � interactive star input
- .br-review-form-wrap / .br-review-form � submission form layout
- .br-review-avatar � circular initial avatar
- .br-section-label-lg � larger label variant (used in Why Us / How It Works)

**admin-reviews.html � New admin page:**
- Auth guard: rRequireAdmin() before revealing
- Stats row: Total, Approved, Pending, Avg Rating
- Table: Date | Name | Location | Rating (stars) | Review (truncated) | Status badge | Actions
- Actions: Approve / Deny toggle, Edit (modal), Delete (with confirm)
- Filter dropdown: All / Pending / Approved
- Search: live filter by name or review text
- Add Review button: opens modal to manually add a review
- Edit modal: name, location, rating, review text, approved toggle
- Toast notifications for all actions

**All 15 admin sidebars updated:** dmin-reviews.html link added under Contacts in every admin page sidebar.

---

#### ? Bug Fixes This Session

| Bug | Cause | Fix |
|-----|-------|-----|
| Reviews not showing (blank grid) | JS syntax error � corrupted duplicate loadReviews call left orphaned .catch blocks after a bad edit | Removed duplicate lines, kept single clean loadReviews() call |
| Review cards invisible (space but no content) | Cards had data-animate="fade-up" ? CSS sets opacity:0 by default, IntersectionObserver not triggering for dynamically-injected elements | Changed to class="br-review-card animated" � nimated class sets opacity:1 immediately |
| Star picker showing black stars | CSS color:#f59e0b was already in .br-star-picker span � was masked by JS syntax error above | Fixed by resolving the JS syntax error |

---

#### ? Key Lesson: data-animate on Dynamic Elements

**Problem:** Any element built by JS and injected into the DOM AFTER the IntersectionObserver was set up will NOT be observed automatically. The CSS rule [data-animate] { opacity: 0 } makes them invisible permanently.

**Solution:** For JS-rendered cards/items, add the nimated class directly in the HTML string:
`javascript
html += '<div class="br-review-card animated">'; // NOT data-animate="fade-up"
`
This makes the element immediately visible without needing the observer.

---

### Current Project State (April 20, 2026)

| Feature | Status |
|---------|--------|
| Hosting (bleachresistant.com, Hostinger) | ? Live |
| GitHub auto-push | ? (tzkusman/bleach-resistant, master) |
| Supabase (URL, auth, RLS) | ? Wired |
| Logo (src/logo.png) on all pages | ? |
| Social links (Instagram, Facebook, TikTok) in footer | ? |
| Google Search Console verified | ? |
| Sitemap (bleachresistant.com URLs) | ? |
| Reviews � user submission form | ? |
| Reviews � display on home page | ? |
| Reviews � admin-reviews.html | ? |
| Reviews � sidebar link on all admin pages | ? |
| Why Us / How It Works � larger labels | ? |
| og:url / og:image SEO meta | ? |

### Files Changed This Session
- home.html � reviews section, JS loader, star picker, form
- overhaul.css � review CSS classes
- dmin-reviews.html � NEW FILE created
- dmin.html + all dmin-*.html � Reviews sidebar link added
- GUIDE-PROJECT.md � this update
