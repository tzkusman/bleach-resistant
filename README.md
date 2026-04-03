# Bleach Resistant — Custom Apparel Website

Full-featured static website for **Bleach Resistant** (formerly FinPrint Inc.), a custom apparel and sublimation printing company. Built from Wix Thunderbolt HTML snapshots with a custom admin panel, Supabase backend, and deployed on Vercel.

**Live Site:** [bleach-resistant.vercel.app](https://bleach-resistant.vercel.app)

---

## Quick Start

### Local Development

No build tools required — just open any HTML file in a browser:

```
# Clone the repo
git clone https://github.com/tzkusman/bleach-resistant.git
cd bleach-resistant

# Open in browser
start home.html        # Windows
open home.html         # macOS
xdg-open home.html     # Linux
```

Or use a local server for full functionality (Supabase features need HTTP):

```
# Using Python
python -m http.server 8000

# Using Node.js
npx serve .

# Then visit http://localhost:8000
```

### Admin Panel

Navigate to `/admin.html` (or `login.html`) and sign in with the admin email to access the dashboard.

---

## Project Structure

```
bleach-resistant/
│
├── 📄 Public Pages (20 HTML files)
│   ├── home.html                 # Homepage with feature image slider
│   ├── finprint.html             # Alternate homepage
│   ├── About.html                # About Us
│   ├── services.html             # Services overview
│   ├── product.html              # Product landing
│   ├── Pricelist.html            # Price list / products index
│   ├── headgear.html             # Headgear products
│   ├── basicpoly.html            # Basic poly products
│   ├── stockdesigns.html         # Stock design catalog
│   ├── fabricdescriptions.html   # Fabric info
│   ├── sublimationprinting.html  # Sublimation printing info
│   ├── grapicdesign.html         # Logos & graphic design
│   ├── customlogos.html          # Logo showcase
│   ├── wrapdesign.html           # Vehicle wrap design
│   ├── copyofwashingsamples.html # Washing samples / showcase
│   ├── sizechart.html            # Size chart reference
│   ├── order.html                # Order form
│   ├── FAQs.html                 # Frequently asked questions
│   ├── privacypolicy.html        # Privacy policy
│   └── termsconditions.html      # Terms & conditions
│
├── 🔐 Admin Panel (8 HTML files)
│   ├── login.html                # Admin login page
│   ├── signup.html               # Admin signup page
│   ├── admin.html                # Dashboard — orders, contacts overview
│   ├── admin-orders.html         # Manage orders
│   ├── admin-contacts.html       # Manage contact submissions
│   ├── admin-pages.html          # Visual page editor (click-to-edit)
│   ├── admin-media.html          # Media library
│   ├── admin-navigation.html     # Navigation & page management
│   ├── admin-settings.html       # Site settings (branding, SEO, etc.)
│   └── admin-analytics.html      # Analytics dashboard
│
├── 🎨 Styles & Assets
│   ├── overhaul.css              # Master stylesheet (~2600 lines)
│   ├── admin.css                 # Admin panel styles
│   └── favicon.svg               # BR branded favicon
│
├── ⚙️ JavaScript
│   ├── supabase-config.js        # Supabase client initialization
│   └── content-loader.js         # Loads Supabase content overrides on public pages
│
├── 🗄️ Database
│   ├── supabase-setup.sql        # SQL schema for all tables
│   └── SUPABASE_GUIDE.md         # Supabase setup documentation
│
├── 🚀 Deployment
│   ├── vercel.json               # Vercel config (rewrites, security headers)
│   ├── robots.txt                # Search engine crawl rules
│   └── sitemap.xml               # XML sitemap for SEO
│
└── 📝 Documentation
    ├── README.md                 # This file
    ├── PROJECT_COMPLETE_GUIDE.md # Detailed project history & modifications
    └── SITE_GUIDE.md             # Original site structure reference
```

---

## Tech Stack

| Layer       | Technology                                              |
| ----------- | ------------------------------------------------------- |
| Frontend    | Static HTML, CSS, vanilla JavaScript                    |
| Styling     | `overhaul.css` — custom theme overriding Wix defaults   |
| Backend     | [Supabase](https://supabase.com) (Postgres + Auth + Storage) |
| Hosting     | [Vercel](https://vercel.com) — static deployment        |
| Source      | Wix Thunderbolt HTML snapshots (fully localized)        |

---

## Key Features

- **Feature Image Slider** — Auto-rotating carousel on homepage with prev/next arrows, dots, touch/swipe support
- **CSS Hover Dropdowns** — PRODUCTS and SERVICES menus work without JavaScript
- **Admin Dashboard** — Full CMS with orders, contacts, visual page editor, media library, settings, analytics
- **Supabase Integration** — Real-time data for orders, contacts, page content overrides, site settings
- **SEO Optimized** — Meta tags, Open Graph, structured data, sitemap, robots.txt
- **Security Headers** — X-Frame-Options, CSP-adjacent headers, admin pages noindex'd
- **Responsive** — Mobile-friendly with media queries throughout
- **Fully Offline-Capable** — All navigation uses local `.html` files, no external routing

---

## Navigation Map

| Menu Item        | File                        |
| ---------------- | --------------------------- |
| Home             | `home.html`                 |
| **PRODUCTS ▾**   |                             |
| Pricelist        | `Pricelist.html`            |
| Head Gear        | `headgear.html`             |
| Basics           | `basicpoly.html`            |
| Stock Designs    | `stockdesigns.html`         |
| Fabric Info      | `fabricdescriptions.html`   |
| Sublimation      | `sublimationprinting.html`  |
| **SERVICES ▾**   |                             |
| Logos & Design   | `grapicdesign.html`         |
| Logo Showcase    | `customlogos.html`          |
| Wrap Design      | `wrapdesign.html`           |
| Showcase         | `copyofwashingsamples.html` |
| Order            | `order.html`                |
| Size Chart       | `sizechart.html`            |
| FAQs             | `FAQs.html`                 |

---

## Supabase Database Tables

| Table          | Purpose                                         |
| -------------- | ------------------------------------------------ |
| `orders`       | Customer orders from the order form              |
| `contacts`     | Contact form submissions                         |
| `page_content` | Visual editor overrides (unique page + selector) |
| `media`        | Uploaded media files metadata                    |
| `site_settings`| Site configuration (branding, SEO, social, etc.) |

Run `supabase-setup.sql` in your Supabase SQL Editor to create all tables with RLS policies.

---

## Deployment

The site is deployed on Vercel as a static site:

```bash
# Install Vercel CLI (once)
npm i -g vercel

# Deploy to production
vercel --prod
```

`vercel.json` handles:
- Root `/` → `home.html` rewrite
- Security headers on all routes
- `noindex` headers on admin and auth pages

---

## Brand Colors

| Usage      | Color                        |
| ---------- | ---------------------------- |
| Primary    | `#C7065C` (magenta/pink)     |
| Text       | `rgb(141,198,63)` (green)    |
| Hover      | `rgb(160,160,159)` (gray)    |
| Background | `rgb(36,35,35)` / `#fff`     |

---

## License

Private repository. All rights reserved.
