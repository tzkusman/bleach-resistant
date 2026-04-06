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
│  │(email/  │  │(11 tables│  │  (media,         │  │
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
├── About.html                ← About page
├── FAQs.html                 ← FAQ with accordion
├── Pricelist.html            ← Pricing page
│
├── admin.html                ← Admin dashboard
├── admin-products.html       ← Product CRUD
├── admin-orders.html         ← Order management
├── admin-contacts.html       ← Contact/chat messages + reply
├── admin-slider.html         ← Hero slider CRUD
├── admin-sections.html       ← Page section editor
├── admin-pages.html          ← Visual page editor
├── admin-media.html          ← Media library
├── admin-navigation.html     ← Nav menu editor + Page Creator + Page Builder
├── admin-settings.html       ← Site settings (branding, SEO, etc.)
├── admin-analytics.html      ← Analytics dashboard
│
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
  <link rel="stylesheet" href="overhaul.css?v=7">
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
<link rel="stylesheet" href="overhaul.css?v=7">
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

Use this prompt with any AI assistant to create a similar project from scratch:

```
Create a complete business website with admin panel using ONLY:
- Static HTML files (no framework, no build step)
- Vanilla CSS with design tokens (CSS custom properties)
- Vanilla JavaScript (no libraries except Supabase JS SDK)
- Supabase for database, auth, and file storage
- Vercel for hosting

The website needs:

PUBLIC PAGES:
- Homepage with dynamic hero slider (slides managed from admin)
- Product catalog with dynamic category tabs from DB
- Individual product detail page
- Multiple category/service pages (each loads dynamic sections from admin)
- Multi-step order wizard form (conditional fields per service type, file upload)
- FAQ page with accordion
- About, Contact, Privacy, Terms pages
- Chat widget on every page (saves to DB, admin can reply)

AUTH SYSTEM:
- Email/password login/signup via Supabase Auth
- Admin guard: single admin email checked on every admin page
- Admin pages hidden with display:none until auth confirmed
- Auth-aware navbar (shows "My Account" when logged in)

CLIENT ACCOUNT:
- Order history (fetched by user_id and email)
- Profile editing (saves to auth.user_metadata)
- Password change

ADMIN PANEL (10+ pages):
- Dashboard with stat cards and recent activity
- Products CRUD (image upload to Supabase Storage, gallery, categories)
- Orders management (search, filter, status update, CSV export)
- Contacts/messages with admin reply feature
- Hero slider CRUD with image upload
- Page sections editor (admin creates sections for any page)
- Visual page editor (iframe preview, click-to-select elements)
- Media library (drag & drop upload, search)
- Navigation menu editor
- Site settings (business info, branding colors, SEO, social media, custom code injection, maintenance mode, backup/export)
- Analytics dashboard

DATABASE (Supabase Postgres):
- 11 tables: orders, contacts, products, hero_slides, category_sections, page_content, site_settings, media, nav_items, custom_pages, page_blocks
- Row Level Security on every table
- Public read for products/slides/sections/settings/nav_items/published pages
- Admin-only write for everything
- Storage buckets: order-attachments (public), media (admin)

CSS DESIGN SYSTEM:
- Custom properties for colors, shadows, radii, transitions
- Consistent component classes (buttons, cards, grids, badges, forms)
- Scroll-triggered animations via IntersectionObserver
- Responsive breakpoints (1200px, 1100px, 1024px, 768px, 480px)
- Auto-adjusting navbar with CSS clamp() (scales gap/padding/font-size)
- Hamburger menu at 1100px (supports 8+ nav items)
- Separate admin.css for admin panel

DYNAMIC CONTENT (content-loader.js):
- brLoadProducts(containerId, options) — fetch and render products
- brLoadCategorySection() — replace static content with DB sections
- brLoadHeroSlider() — build slider from DB slides
- brLoadDynamicNav() — replace static nav with DB-managed navigation
- brRenderPageBlocks(container, page, blocks) — render custom page blocks (11 block types)
- Content overrides from page_content table
- Auth-aware navbar
- Chat widget auto-injected on all public pages
- Event delegation for mobile dropdown toggles (survives innerHTML replacement)

NAVIGATION & CUSTOM PAGES:
- Dynamic nav from nav_items table (admin-managed, replaces static HTML)
- Custom pages created from admin with 8 templates and 11 block types
- page.html renders custom pages via ?slug= parameter
- Products auto-assigned to custom pages via page-{slug} category
- URL rewrite: /p/{slug} → page.html?slug={slug}

DEPLOYMENT:
- Vercel auto-deploy from GitHub push
- Cache busting via ?v=N query params on CSS/JS
- No environment variables needed (Supabase anon key is safe with RLS)

Every admin page should be self-contained HTML with inline <script>.
No npm, no Node.js, no bundler, no framework.
The entire site runs client-side with Supabase handling security via RLS.
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

### 15.4 Responsive Navbar (Auto-Adjusting)

The navbar auto-adjusts spacing based on the number of items using CSS `clamp()`:

```css
/* Nav links spacing scales with viewport */
.br-nav-links { gap: clamp(0px, 0.3vw, 4px); }
.br-nav-links > li > a {
  font-size: clamp(0.7rem, 0.75vw + 0.15rem, 0.85rem);
  padding: 8px clamp(6px, 0.7vw, 14px);
}
.br-nav-menu { gap: clamp(4px, 0.5vw, 8px); flex: 1 1 auto; }
.br-nav-actions { gap: clamp(6px, 0.6vw, 12px); margin-left: clamp(8px, 1vw, 16px); }
```

**Breakpoints:**
- **> 1200px** — Full desktop spacing
- **1100–1200px** — Reduced padding/font-size for nav items
- **< 1100px** — Hamburger menu (was 768px, raised to accommodate 8+ items)
- **< 768px** — Layout adjustments (grids go single-column, etc.)

This means as you add more pages to the navigation, the nav items automatically shrink their padding and font size. When items no longer fit, the hamburger menu kicks in at 1100px instead of waiting until 768px.

---

## 16. Cache Version Tracking

Always bump version numbers when editing shared files:

| File | Current Version | Usage |
|------|----------------|-------|
| `overhaul.css` | `?v=7` | All public pages |
| `content-loader.js` | `?v=15` | All public pages |
| `supabase-config.js` | `?v=7` | All pages |
