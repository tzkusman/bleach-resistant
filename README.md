# Bleach Resistant &#x2014; Custom Apparel Website

Full-featured static website for **Bleach Resistant** (formerly FinPrint Inc.), a custom apparel and sublimation printing company. Built from Wix Thunderbolt HTML snapshots with a completely custom admin panel, Supabase backend, and deployed on Vercel.

**Live Site:** [bleach-resistant.vercel.app](https://bleach-resistant.vercel.app)

---

## Quick Start

### Local Development

```bash
git clone https://github.com/tzkusman/bleach-resistant.git
cd bleach-resistant

# Option A  just open in browser
start home.html

# Option B  local HTTP server (recommended to avoid CORS errors)
python -m http.server 8080
# then open http://localhost:8080/home.html
```

### Admin Panel

Navigate to `/admin.html` (requires Supabase login).  
Default admin email: `usman@gmail.com`

---

## Project Structure

```
bleach-resistant/

  Public Pages (20 HTML files)
    home.html                 # Homepage with feature image slider
    finprint.html             # Alternate homepage
    About.html                # About Us
    services.html             # Services overview
    product.html              # Product landing
    Pricelist.html            # Price list / products index
    headgear.html             # Headgear products
    basicpoly.html            # Basic poly products
    stockdesigns.html         # Stock design catalog
    fabricdescriptions.html   # Fabric info
    sublimationprinting.html  # Sublimation printing info
    grapicdesign.html         # Logos & graphic design
    customlogos.html          # Logo showcase
    wrapdesign.html           # Vehicle wrap design
    copyofwashingsamples.html # Washing samples / showcase
    sizechart.html            # Size chart reference
    order.html                # Order form
    FAQs.html                 # Frequently asked questions
    privacypolicy.html        # Privacy policy
    termsconditions.html      # Terms & conditions

  Admin Panel (10 HTML files)
    login.html                # Admin login page
    signup.html               # Admin signup page
    admin.html                # Dashboard  orders, contacts overview
    admin-orders.html         # Manage orders
    admin-contacts.html       # Manage contact submissions
    admin-pages.html          # Visual page editor (click-to-edit)
    admin-media.html          # Media library
    admin-navigation.html     # Navigation & page management
    admin-settings.html       # Site settings (branding, SEO, etc.)
    admin-analytics.html      # Analytics dashboard

  Styles & Assets
    overhaul.css              # Master stylesheet (~2870 lines, 4 phases)
    admin.css                 # Admin panel styles (3-breakpoint responsive)
    favicon.svg               # BR branded favicon

  JavaScript
    supabase-config.js        # Supabase client + auth helpers
    content-loader.js         # Mobile scaling, hamburger nav, Supabase content overrides

  Database
    supabase-setup.sql        # Full DB setup: tables, RLS policies, grants, storage buckets
    SUPABASE_GUIDE.md         # Supabase setup documentation

  Deployment
    vercel.json               # Vercel config (rewrites, security + cache headers)
    robots.txt                # Search engine crawl rules
    sitemap.xml               # XML sitemap for SEO

  Documentation
     README.md                 # This file
     PROJECT_COMPLETE_GUIDE.md # Detailed project history & modifications
     SITE_GUIDE.md             # Original site structure reference
```

---

## Tech Stack

| Layer       | Technology                                                         |
| ----------- | ------------------------------------------------------------------ |
| Frontend    | Static HTML, CSS, vanilla JavaScript                               |
| Styling     | `overhaul.css`  custom theme overriding Wix defaults (4 phases)  |
| Mobile      | JS viewport transform-scale + injected hamburger nav overlay       |
| Backend     | [Supabase](https://supabase.com) (Postgres + Auth + Storage)       |
| Hosting     | [Vercel](https://vercel.com)  static deployment with custom headers |
| Source      | Wix Thunderbolt HTML snapshots (fully localized, no Wix CDN deps)  |

---

## Key Features

- **Feature Image Slider**  Auto-rotating carousel on homepage with prev/next arrows, dots, touch/swipe support, opacity fade transitions
- **CSS Hover Dropdowns**  PRODUCTS and SERVICES nav menus work without JS
- **Mobile-Responsive**  JS viewport scaling (`transform: scale`) keeps Wix absolute layouts intact on all screen sizes; hamburger nav overlay with accordion sub-menus for screens  980 px
- **Admin Dashboard**  Full CMS: orders, contacts, visual page editor, media library, settings, analytics
- **Supabase Content Overrides**  `content-loader.js` pulls `page_content` rows from Supabase and patches live DOM on every public page
- **SEO Optimized**  Meta tags, Open Graph, structured data, sitemap, robots.txt
- **Security Headers**  X-Frame-Options, COOP/COEP headers, admin pages `noindex`, `no-store` cache
- **Static Cache Control**  CSS/JS/images cached for 1 year immutable; HTML served `no-cache`
- **Fully Self-Contained**  All navigation uses local `.html` files; no external Wix CDN required

---

## Navigation Map

| Menu Item        | File                        |
| ---------------- | --------------------------- |
| Home             | `home.html`                 |
| **PRODUCTS **   |                             |
| Pricelist        | `Pricelist.html`            |
| Head Gear        | `headgear.html`             |
| Basics           | `basicpoly.html`            |
| Stock Designs    | `stockdesigns.html`         |
| Fabric Info      | `fabricdescriptions.html`   |
| Sublimation      | `sublimationprinting.html`  |
| **SERVICES **   |                             |
| Logos & Design   | `grapicdesign.html`         |
| Logo Showcase    | `customlogos.html`          |
| Wrap Design      | `wrapdesign.html`           |
| Showcase         | `copyofwashingsamples.html` |
| Order            | `order.html`                |
| Size Chart       | `sizechart.html`            |
| FAQs             | `FAQs.html`                 |

---

## Supabase Database Tables

| Table           | Purpose                                                          |
| --------------- | ---------------------------------------------------------------- |
| `orders`        | Customer orders submitted via order.html                         |
| `contacts`      | Contact form submissions                                         |
| `page_content`  | Visual editor overrides (keyed by page + CSS selector)           |
| `media`         | Uploaded media files metadata                                    |
| `site_settings` | Site configuration (branding, SEO, social links, etc.)           |

Run `supabase-setup.sql` in your Supabase SQL Editor to create all tables with RLS policies.  
Supabase URL: `https://dbppxzkkgdtnmikkviyt.supabase.co`

---

## Mobile Responsiveness

Wix Thunderbolt exports use absolute pixel positioning  standard CSS media-query reflow cannot move elements. The solution used here:

### Viewport Scaling (`content-loader.js` IIFE 1)

```js
// Shrinks the entire #SITE_CONTAINER proportionally on narrow screens
function getScale() {
  return Math.min(1, window.innerWidth / 980);
}
function applyScale() {
  const scale = getScale();
  container.style.transform = `scale(${scale})`;
  container.style.transformOrigin = 'top left';
  // Corrects scroll height lost to scale:
  container.style.marginBottom = `-(originHeight - originHeight * scale)px`;
}
```

### Hamburger Nav (`buildHamburgerNav()` in `content-loader.js`)

Injects a full mobile navigation panel into every public page at runtime:

- `#br-mnav`  wrapper div, `display:none` on desktop, shown via JS at  980 px
- `#br-mtoggle`  fixed pink `#C7065C` button at `top: 44px; right: 14px; z-index: 1000002`
- `#br-moverlay`  full-height slide-in panel (`right: -100%`  `right: 0`) at `z-index: 1000001`
- Accordion sub-menus for PRODUCTS and SERVICES
- Swipe-to-close and dimmer backdrop
- Re-applied on `DOMContentLoaded`, `setTimeout(600ms)`, `setTimeout(1500ms)`, `window.load`, `resize`, `orientationchange`

### Z-Index Hierarchy

| Element              | z-index   |
| -------------------- | --------- |
| Auth bar             | 999 999   |
| Hamburger toggle btn | 1 000 002 |
| Hamburger overlay    | 1 000 001 |

---

## Deployment

Deployed on Vercel as a static site. Linked to project `tzkusmans-projects/bleach-resistant`.

```bash
# Install Vercel CLI (once)
npm i -g vercel

# Link to correct Vercel project (once per machine)
vercel link --project bleach-resistant

# Deploy to production
vercel --prod
```

### `vercel.json` Summary

- `/` rewrites to `home.html`
- Security headers on all routes (X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy)
- `Cross-Origin-Opener-Policy: same-origin-allow-popups` (allows Supabase OAuth popups)
- `Cross-Origin-Embedder-Policy: unsafe-none`
- Static assets (css/js/svg/png/jpg/webp/woff2) cached `max-age=31536000, immutable`
- HTML files cached `no-cache`
- Admin & auth pages cached `no-store`

---

## Brand Colors

| Usage      | Value                      |
| ---------- | -------------------------- |
| Primary    | `#C7065C` (magenta/pink)   |
| Text       | `rgb(141,198,63)` (green)  |
| Hover      | `rgb(160,160,159)` (gray)  |
| Background | `rgb(36,35,35)` / `#fff`   |

Fonts: Montserrat, Oswald, Bebas Neue (loaded via Wix inline styles).

---

## Known Limitations

These are cosmetic console errors from the Wix runtime bundle  they do not affect site functionality:

| Error | Cause | Impact |
| ----- | ----- | ------ |
| `forwardRef` is not defined | Wix JS expects React on the Wix CDN | None  Wix layout already rendered in static HTML |
| `did not find pageId` | Wix router expects Wix CDN infrastructure | None  navigation uses direct `.html` hrefs |
| `blob:home.html/uuid` (historical) | Wix exporter hardcoded dead blob: script tags | Fixed  all removed from all 20 pages |

---

## Changelog

| Commit    | Date          | Description |
| --------- | ------------- | ----------- |
| `77d24b6` | 2026-04-04    | Fix: remove `.select()` after insert so anon role can submit orders (RLS 401 fix) |
| `06017f6` | 2026-04-04    | Rebuild order page: comprehensive inquiry form + admin panel upgrade |
| `fb2aa87` | 2026-04-04    | Update README: comprehensive guide + April 4 2026 changes |
| `e03c612` | 2026-04-04    | Fix encoding: replace garbled triple-encoded em dashes with `&#x2014;` in all 20 pages; remove U+009D control chars |
| `68ad9b5` | 2026-04-04    | Fix: remove dead `blob:` scripts from all pages, fix z-index conflicts, correct scale height, improve vercel.json security+cache headers |
| `b6a209e` | 2026-04-04    | Mobile fix: DOCTYPE all pages, JS viewport scaling, hamburger nav Phase 4 CSS rewrite |
| `7931fd2` | 2026-04-04    | Mobile responsive: all 20 public pages + full admin panel (admin.css 3-breakpoint) |
| `54240fe` | earlier       | Slider v5  minimal CSS approach, keeps Wix grid intact, only overrides image left/opacity |
| `8541b59` | earlier       | Slider v4  eliminated gap with padding-top approach |
| `3b2768c` | earlier       | Fixed UTF-8 mojibake encoding in all 10 admin & auth pages |
| `255c34b` | earlier       | Slider v3 CSS fix, added README, updated .gitignore |
| `d8adfc9` | earlier       | Replaced old FinPrint favicon with new BR branded favicon.svg |
| `cba4b0d` | earlier       | Rebuilt page editor  fixed blank preview, added element scanner |
| `881c336` | earlier       | Slider v2, admin upgrade  navigation/settings/analytics pages |
| `adcf356` | earlier       | Initial production release  20 pages, admin panel, Supabase CMS, SEO |

---

## What Was Fixed (April 4, 2026)

### 1. Quirks Mode (18 pages missing `DOCTYPE`)
All 20 Wix HTML pages were missing `<!DOCTYPE html>`, causing browsers to render in Quirks Mode (broken box model, incorrect font sizes, mispositioned elements).  
**Fix:** Added `<!DOCTYPE html>` as the very first line of every page.

### 2. Dead `blob:` Script Tags
Wix's HTML exporter injected `<script src="blob:home.html/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"></script>` into every page. These are ephemeral browser-memory URLs that only existed in the original Wix tab session  they throw `SecurityError` on every page load.  
**Fix:** Removed all such `<script src="blob:...">` tags from all 20 pages.

### 3. Mobile Responsiveness
Wix Thunderbolt uses absolute pixel positions for every element  CSS media queries cannot reflow absolute layouts. A previous attempt at CSS-only Phase 4 was broken.  
**Fix:**
- `content-loader.js` now computes `scale = min(1, screenWidth / 980)` and applies `transform: scale(n)` to `#SITE_CONTAINER`, proportionally shrinking the entire page
- Negative `marginBottom` correction restores scroll height after scaling
- `buildHamburgerNav()` injects a complete `#br-moverlay` slide-in panel with all nav links and accordion sub-menus  toggled by a fixed pink `#br-mtoggle` button
- `overhaul.css` Phase 4 completely rewritten with hamburger nav CSS only (no broken media-query reflow)

### 4. Garbled Tab Titles (`Âââ Custom...`)
Wix exported em dashes (`&#x2014;`) as raw UTF-8 multi-byte sequences. These bytes were then misread as Windows-1252, producing the character sequence `[195, 162, 8218, 172, 8364]` plus the control character U+009D. Browsers rendered this as `Âââ`.  
**Fix:** Used raw byte analysis to identify the exact corrupted byte sequence, replaced it with `&#x2014;` in all 20 pages, and stripped all U+009D control characters.

### 5. Z-Index Conflict
The fixed auth bar (which shows login/logout) sat at `z-index: 999999`. The hamburger toggle button was initially rendered beneath it.  
**Fix:** Auth bar stays at `999999`. Hamburger toggle: `z-index: 1000002`, `top: 44px` (below auth bar). Overlay panel: `z-index: 1000001`.

### 6. Admin Panel Mobile (3 Breakpoints)
`admin.css` was rewritten with full responsive support:
- ` 1024px`  stacked layout, smaller sidebar
- ` 768px`  horizontal scrollable nav strip instead of sidebar
- ` 480px`  compact table cells, full-width forms
### 7. Order Page — Complete Rebuild
The old `order.html` (Wix-exported static page) was fully replaced with a custom-built inquiry and order form.

**Form structure (4 steps):**
- **Step 1 — Service Type:** Dropdown with 15 services across 4 categories (Apparel & Printing, Design Services, Vehicle & Signage, Other). Dynamic sub-fields appear per service selection:
  - Apparel → item type, quantity, size checkboxes (XS–3XL + Youth), colour tag picker (13 colours)
  - Head Gear → cap style, quantity
  - Design/Logo → deliverable type, file format preference
  - Vehicle Wrap → wrap type, vehicle make/model
  - International → destination country, quantity
- **Step 2 — Contact Info:** First/last name, email, phone, company/team/school, city. Auto-filled when user is signed in.
- **Step 3 — Order Details:** Deadline date picker, urgency quick-pick (Flexible / 2–3 Weeks / 1 Week / Rush ⚡), budget range dropdown, design notes textarea, artwork file upload (drag & drop, 20 MB max, all art formats), how did you hear about us.
- **Submit:** Inserts to Supabase `orders` table → success screen with random reference number (e.g. `REF: BR-A3F7K2`)

**Auth:** Completely optional — guests submit freely, logged-in users get name/email pre-filled and `user_id` linked to the row.

**Admin panel (`admin-orders.html`) upgrades:**
- Table columns expanded: Service (badge), Item, Qty, Deadline/Urgency, Budget, Company
- View modal shows all fields in grouped sections: Contact / Order Details / Notes + attachment download link
- CSV export now includes 19 columns
- Search also matches company name and service type

### 8. Supabase SQL Queries Run (April 4, 2026)
All SQL executed in the Supabase SQL Editor (now saved in `supabase-setup.sql`):

1. `ALTER TABLE orders ADD COLUMN IF NOT EXISTS ...` — added 16 new columns to the orders table
2. `INSERT INTO storage.buckets ...` — created `order-attachments` bucket
3. RLS policies — `DROP POLICY` + `CREATE POLICY` for orders (public INSERT, admin SELECT/UPDATE/DELETE)
4. Storage policies — anyone can upload/view `order-attachments`, admin manages `media`
5. `GRANT INSERT ON TABLE orders TO anon` + sequences grant — fixed 401 error for guest submissions
6. `ALTER TABLE orders ALTER COLUMN quantity TYPE TEXT` — fixed 400 error (quantity stored as range string e.g. `"6-10"`, not integer)
---

## License

Private repository. All rights reserved.
