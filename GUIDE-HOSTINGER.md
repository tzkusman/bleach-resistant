# Hosting on Hostinger — Complete Guide

> **How to move this project from Vercel to Hostinger with a custom domain.**
> This covers buying a domain, setting up hosting, uploading files, SSL, email, and going live.

---

## Table of Contents

1. [Why Hostinger?](#1-why-hostinger)
2. [Buy a Hostinger Plan](#2-buy-a-hostinger-plan)
3. [Register Your Domain](#3-register-your-domain)
4. [Set Up Your Hosting](#4-set-up-your-hosting)
5. [Upload Your Website Files](#5-upload-your-website-files)
6. [Set home.html as Homepage](#6-set-homehtml-as-homepage)
7. [Enable SSL (HTTPS)](#7-enable-ssl-https)
8. [Set Up Professional Email](#8-set-up-professional-email)
9. [Update Supabase Config for New Domain](#9-update-supabase-config-for-new-domain)
10. [Update Google Analytics](#10-update-google-analytics)
11. [DNS Records Reference](#11-dns-records-reference)
12. [Test Everything](#12-test-everything)
13. [Vercel vs Hostinger — Decision Guide](#13-vercel-vs-hostinger--decision-guide)
14. [Migration Checklist (Vercel → Hostinger)](#14-migration-checklist-vercel--hostinger)
15. [Troubleshooting Common Issues](#15-troubleshooting-common-issues)

---

## 1. Why Hostinger?

| Feature | Vercel (Current) | Hostinger |
|---------|------------------|-----------|
| **Custom domain** | Requires DNS config | Included — buy & manage in one place |
| **Email** | Not included | Professional email (name@yourdomain.com) |
| **File Manager** | Git push only | Web file manager + FTP + Git |
| **SSL** | Auto (free) | Auto (free Let's Encrypt) |
| **Price** | Free tier | ~$2.99/month (Premium plan) |
| **PHP/Backend** | Not supported | Supported (if you ever need it) |
| **Storage** | No limit (static) | 100GB+ |
| **Bandwidth** | 100GB/month free | Unlimited |

**Verdict:** Hostinger is better when you want a custom domain, professional email, and one dashboard for everything.

---

## 2. Buy a Hostinger Plan

1. Go to [hostinger.com](https://www.hostinger.com)
2. Click **Web Hosting** (not WordPress Hosting, not VPS)
3. Choose **Premium Web Hosting** plan (recommended):
   - 100 websites
   - Free domain (1 year)
   - Free SSL
   - Professional email
   - ~$2.99/month (on 48-month plan)
4. Create your account and complete payment
5. You'll get a **Welcome Email** with your hosting credentials

> **Tip:** The 48-month plan gives the best monthly rate. If testing, the 1-month plan works too but costs more per month.

---

## 3. Register Your Domain

### Option A: Free Domain with Hosting Plan (Recommended)

Premium plan includes 1 free domain for 1 year.

1. After purchase, Hostinger dashboard will prompt: **"Claim your free domain"**
2. Search for your domain: `bleachresistant.com` (or `.ca`, `.store`, etc.)
3. If available → **Register** it
4. Fill in WHOIS contact info (name, email, address — Hostinger protects this with WHOIS privacy)
5. Domain is now registered and auto-connected to your hosting

### Option B: Buy Domain Separately

1. In Hostinger dashboard → **Domains** → **Register a New Domain**
2. Search for your domain name
3. Select and purchase (`.com` = ~$9.99/year, `.ca` = ~$12.99/year)
4. It will auto-connect to your hosting account

### Option C: Use a Domain from Another Registrar (GoDaddy, Namecheap, etc.)

1. In your Hostinger dashboard → **Hosting** → **Plan Details**
2. Find your Hostinger **nameservers** (usually):
   ```
   ns1.dns-parking.com
   ns2.dns-parking.com
   ```
   Or the actual assigned nameservers (check your hosting welcome email)
3. Go to your domain registrar (GoDaddy, Namecheap, etc.)
4. Find **DNS Settings** or **Nameservers**
5. Change nameservers to the Hostinger ones
6. Wait 24-48 hours for DNS propagation

### Option D: Transfer a Domain to Hostinger

If you already own a domain at another registrar and want to move it entirely to Hostinger:

1. At your current registrar: **Unlock** the domain and get the **EPP/Authorization Code**
2. In Hostinger dashboard → **Domains** → **Transfer Domain**
3. Enter your domain name and the EPP code
4. Pay the transfer fee (~$9.99 — adds 1 year to registration)
5. Approve the transfer via email confirmation
6. Wait 5-7 days for the transfer to complete
7. Domain is now fully managed in Hostinger

> **Note:** Domain must be at least 60 days old and not expired to transfer. WHOIS email must be accessible for approval.

---

## 4. Set Up Your Hosting

After buying hosting + domain, set up the hosting account:

1. Log in to [hpanel.hostinger.com](https://hpanel.hostinger.com) (Hostinger's control panel)
2. You'll see your hosting plan. Click **Setup** or **Manage**
3. When asked "What do you want to build?", select **"Upload my own website"** (skip any website builder prompts)
4. Select your domain from the dropdown
5. Skip any template/WordPress suggestions — you're uploading your own files
6. The hosting is now active and tied to your domain

### Understanding hPanel

hPanel is Hostinger's custom control panel (not cPanel). Key sections:

| Section | What It Does |
|---------|-------------|
| **Website** | Manage domains, auto-installer |
| **Files** | File Manager, FTP accounts, backups |
| **Databases** | MySQL databases (not needed for this project — we use Supabase) |
| **Emails** | Email accounts, forwarders, webmail |
| **Domains** | DNS zone editor, subdomains, redirects |
| **Security** | SSL, backups, malware scanner |
| **Advanced** | Git, Cron Jobs, PHP config, .htaccess editor |
| **Performance** | CDN, cache, speed optimization |

---

## 5. Upload Your Website Files

There are 3 ways to upload. Choose one:

### Method A: File Manager (Easiest — No Software Needed)

1. In hPanel → **Files** → **File Manager**
2. Navigate to `public_html/` (this is your website's root folder — everything in here is publicly accessible)
3. **Delete** any default files inside `public_html/` (like `index.html` placeholder)
4. Click **Upload** (top toolbar)
5. Upload ALL your project files:

```
Files to upload to public_html/:
├── overhaul.css
├── admin.css
├── supabase-config.js
├── content-loader.js
├── home.html
├── product.html
├── product-detail.html
├── order.html
├── account.html
├── login.html
├── signup.html
├── headgear.html
├── basicpoly.html
├── stockdesigns.html
├── fabricdescriptions.html
├── sublimationprinting.html
├── services.html
├── grapicdesign.html
├── customlogos.html
├── wrapdesign.html
├── copyofwashingsamples.html
├── About.html
├── FAQs.html
├── Pricelist.html
├── sizechart.html
├── finprint.html
├── privacypolicy.html
├── termsconditions.html
├── page.html
├── admin.html
├── admin-products.html
├── admin-orders.html
├── admin-contacts.html
├── admin-slider.html
├── admin-sections.html
├── admin-pages.html
├── admin-media.html
├── admin-navigation.html
├── admin-settings.html
├── admin-analytics.html
├── sitemap.xml
├── favicon.svg
└── .htaccess                ← Create this (see Step 6)
```

> **Tip:** ZIP all files on your computer → upload the single ZIP → right-click → **Extract** inside File Manager. Much faster than uploading 40+ files one by one.

> **Do NOT upload:** `vercel.json` (Vercel-specific, not needed), `node_modules/` (doesn't exist in this project anyway), `.git/` folder.

### Method B: FTP Upload (Best for Bulk Files)

1. In hPanel → **Files** → **FTP Accounts**
2. Note the default FTP credentials (or create a new FTP account):
   - **Host:** `ftp.yourdomain.com` or the IP shown in hPanel
   - **Username:** Your FTP username (shown in hPanel)
   - **Password:** Your hosting password or set a new one
   - **Port:** `21` (or `22` for SFTP — more secure)
3. Download [FileZilla](https://filezilla-project.org/) (free FTP client)
4. Open FileZilla → enter credentials → **Quickconnect**
5. Left panel = your computer. Navigate to your project folder (`E:\786786\bleach`)
6. Right panel = server. Navigate to `/public_html/`
7. Select all files on the left → drag to the right panel
8. Wait for upload to complete

**FileZilla settings for Hostinger:**
```
Host: ftp.yourdomain.com (or IP from hPanel)
Username: (from hPanel → Files → FTP Accounts)
Password: (your set password)
Port: 21
Encryption: Use explicit FTP over TLS if available
```

> **Security:** Use SFTP (port 22) instead of FTP (port 21) when possible — it encrypts the connection. Enable SSH access in hPanel → Advanced → SSH Access.

### Method C: Git Deploy (Advanced — Auto-Deploy Like Vercel)

Hostinger supports connecting a Git repository so you can auto-deploy on push:

1. In hPanel → **Advanced** → **Git**
2. Click **Create a New Repository** or **Manage**
3. Set the **Repository URL**: `https://github.com/tzkusman/bleach-resistant.git`
4. Set the **Branch**: `master`
5. Set the **Deployment Path**: `public_html`
6. Click **Create**
7. Click **Deploy** to pull your latest code

**Set up auto-deploy webhook (like Vercel auto-deploy):**
1. In hPanel → Git → copy the **Webhook URL**
2. In GitHub → your repo → **Settings** → **Webhooks** → **Add webhook**
3. Paste the Hostinger webhook URL as **Payload URL**
4. Content type: `application/json`
5. Secret: leave empty (or set one for extra security)
6. Events: Select **"Just the push event"**
7. Click **Add webhook**
8. Now every `git push origin master` auto-deploys to Hostinger (just like Vercel!)

**Test it:**
```bash
# Make a small change
git add -A
git commit -m "Test Hostinger auto-deploy"
git push origin master
# Wait ~30 seconds, then refresh your domain — changes should be live
```

> **Note:** If you're running both Vercel and Hostinger, a single `git push` deploys to BOTH automatically.

---

## 6. Set home.html as Homepage

By default, web servers look for `index.html` as the homepage. Your site uses `home.html`. You need to tell the server.

### Step 1: Create .htaccess

Create a file called `.htaccess` in `public_html/` (use File Manager → New File, or upload it).

**This is the most important file for Hostinger hosting.** It replaces `vercel.json`:

```apache
# ================================================
# .htaccess — Bleach Resistant (Hostinger)
# Replaces vercel.json for Apache-based hosting
# ================================================

# Set home.html as the default homepage
DirectoryIndex home.html index.html

# Enable URL rewriting
RewriteEngine On

# ── Custom page URL rewrites ──────────────────
# /p/blog → page.html?slug=blog
# /p/some-page → page.html?slug=some-page
RewriteRule ^p/([a-zA-Z0-9_-]+)/?$ /page.html?slug=$1 [L,QSA]

# ── Force HTTPS ───────────────────────────────
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}/$1 [R=301,L]

# ── Force www (optional — uncomment if you want www) ──
# RewriteCond %{HTTP_HOST} !^www\. [NC]
# RewriteRule ^(.*)$ https://www.%{HTTP_HOST}/$1 [R=301,L]

# ── Force non-www (recommended — uncomment if you want no www) ──
# RewriteCond %{HTTP_HOST} ^www\.(.+)$ [NC]
# RewriteRule ^(.*)$ https://%1/$1 [R=301,L]

# ── Security headers ─────────────────────────
<IfModule mod_headers.c>
  Header set X-Frame-Options "DENY"
  Header set X-Content-Type-Options "nosniff"
  Header set X-XSS-Protection "1; mode=block"
  Header set Referrer-Policy "strict-origin-when-cross-origin"
  Header set Permissions-Policy "camera=(), microphone=(), geolocation=()"
</IfModule>

# ── Block access to sensitive files ──────────
<FilesMatch "\.(sql|md|gitignore)$">
  Order allow,deny
  Deny from all
</FilesMatch>

# Block access to .htaccess itself
<Files ".htaccess">
  Order allow,deny
  Deny from all
</Files>

# ── Cache static assets ─────────────────────
# CSS/JS use ?v=N for cache busting, so long cache is safe
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType text/css "access plus 1 year"
  ExpiresByType application/javascript "access plus 1 year"
  ExpiresByType image/svg+xml "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType image/webp "access plus 1 year"
  ExpiresByType font/woff2 "access plus 1 year"
  # HTML files — short cache (always fetch latest)
  ExpiresByType text/html "access plus 0 seconds"
</IfModule>

# ── Gzip compression ────────────────────────
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/html text/css application/javascript application/json image/svg+xml text/xml text/plain
</IfModule>

# ── Prevent directory listing ────────────────
Options -Indexes

# ── Custom error pages ──────────────────────
ErrorDocument 404 /home.html
ErrorDocument 403 /home.html
```

### Step 2: Create index.html Fallback (Optional but Recommended)

Some edge cases may bypass `.htaccess`. Create `index.html` in `public_html/`:

```html
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="refresh" content="0; url=home.html">
  <link rel="canonical" href="https://yourdomain.com/home.html">
  <title>Redirecting...</title>
</head>
<body>
  <p>Redirecting to <a href="home.html">Home</a>...</p>
</body>
</html>
```

### What .htaccess Replaces

| vercel.json Feature | .htaccess Equivalent |
|--------------------|--------------------|
| `"rewrites": [{"source": "/p/:slug", ...}]` | `RewriteRule ^p/([a-zA-Z0-9_-]+)` |
| `"headers": [{"key": "X-Frame-Options", ...}]` | `Header set X-Frame-Options "DENY"` |
| (not in Vercel) | Force HTTPS redirect |
| (not in Vercel) | Gzip compression |
| (not in Vercel) | Long-term caching |
| (not in Vercel) | Block sensitive files (.sql, .md) |
| (not in Vercel) | Disable directory listing |

---

## 7. Enable SSL (HTTPS)

**SSL gives you the padlock icon and `https://` — required for customer trust and Supabase Auth.**

1. In hPanel → **Security** → **SSL**
2. Your domain should be listed. Click **Setup** or **Install**
3. Choose **Free SSL** (Let's Encrypt) — auto-renews every 90 days
4. Click **Install**
5. Wait 5-10 minutes for SSL to activate
6. Test: visit `https://yourdomain.com` — padlock icon should appear

### Force HTTPS Everywhere

After SSL is active:

1. In hPanel → **Security** → **SSL** → find your domain
2. Toggle **Force HTTPS** to ON
3. The `.htaccess` file also enforces HTTPS as a backup

### Verify SSL is Working

Visit these URLs — all should show the padlock:
- `https://yourdomain.com`
- `https://yourdomain.com/product.html`
- `https://yourdomain.com/admin.html`
- `https://yourdomain.com/p/test` (custom page URL)

> **Troubleshooting:** If you see "mixed content" warnings, some resources (images, scripts) might be loading via `http://`. Check browser console for details. All Supabase calls already use `https://`.

---

## 8. Set Up Professional Email

### 8.1 Create Email Accounts

1. In hPanel → **Emails** → **Email Accounts**
2. Click **Create Email Account**
3. Enter: `info@yourdomain.com` (or `orders@`, `support@`, etc.)
4. Set a strong password
5. Click **Create**

**Recommended email addresses for a business:**
| Address | Purpose |
|---------|---------|
| `info@yourdomain.com` | General inquiries (show on website) |
| `orders@yourdomain.com` | Order notifications |
| `support@yourdomain.com` | Customer support |
| `admin@yourdomain.com` | Admin/internal use |

### 8.2 Access Your Email

**Option 1: Webmail (Browser)**
- Go to `https://mail.yourdomain.com`
- Or: hPanel → **Emails** → **Webmail**
- Log in with your email + password

**Option 2: Gmail (Add as external account)**
1. In Gmail → Settings (gear icon) → **See all settings** → **Accounts and Import**
2. Under "Check mail from other accounts" → **Add a mail account**
3. Enter your Hostinger email address
4. Choose **Import emails from my other account (POP3)**
5. Settings:
   ```
   POP Server: pop.hostinger.com
   Port: 995
   ✅ Always use a secure connection (SSL)
   Username: info@yourdomain.com
   Password: (your email password)
   ```
6. To also SEND from Gmail as your domain email:
   - Under "Send mail as" → **Add another email address**
   ```
   SMTP Server: smtp.hostinger.com
   Port: 465
   ✅ Secured connection using SSL
   Username: info@yourdomain.com
   Password: (your email password)
   ```

**Option 3: Phone (iPhone/Android)**

**iPhone:**
Settings → Mail → Accounts → Add Account → Other → Add Mail Account
```
Name: Your Name
Email: info@yourdomain.com
Password: (your password)
Description: Bleach Resistant

Incoming Mail Server:
  Host: imap.hostinger.com
  Username: info@yourdomain.com
  Password: (your password)

Outgoing Mail Server:
  Host: smtp.hostinger.com
  Username: info@yourdomain.com
  Password: (your password)
```

**Android (Gmail app):**
Gmail app → Profile icon → Add account → Other → Enter email → Manual setup → IMAP
```
Incoming: imap.hostinger.com, Port 993, SSL/TLS
Outgoing: smtp.hostinger.com, Port 465, SSL/TLS
```

**Option 4: Desktop (Outlook / Thunderbird)**
```
Incoming (IMAP):
  Server: imap.hostinger.com
  Port: 993
  Encryption: SSL/TLS
  Username: info@yourdomain.com

Outgoing (SMTP):
  Server: smtp.hostinger.com
  Port: 465
  Encryption: SSL/TLS
  Username: info@yourdomain.com
```

### 8.3 Email Forwarding (Optional)

Forward all emails from `info@yourdomain.com` to your personal Gmail:

1. hPanel → **Emails** → **Email Forwarding**
2. Add forward: `info@yourdomain.com` → `yourpersonal@gmail.com`
3. All incoming mail gets copied to your Gmail automatically

### 8.4 Prevent Emails Going to Spam

Set up these DNS records (hPanel → **Domains** → **DNS Zone Editor**):

**SPF Record (prevents spoofing):**
```
Type: TXT
Name: @
Value: v=spf1 include:_spf.hostinger.com ~all
```

**DKIM Record (verify emails are authentic):**
1. hPanel → **Emails** → **Email DNS Records**
2. Copy the DKIM record shown
3. Add it in DNS Zone Editor

**DMARC Record (policy for failed checks):**
```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=quarantine; rua=mailto:info@yourdomain.com
```

---

## 9. Update Supabase Config for New Domain

After moving to Hostinger, update the allowed redirect URLs in Supabase:

1. Go to [supabase.com](https://supabase.com) → your project → **Authentication** → **URL Configuration**
2. Set **Site URL**: `https://yourdomain.com`
3. Under **Redirect URLs**, add:
   ```
   https://yourdomain.com/**
   https://www.yourdomain.com/**
   ```
4. (Optional) Remove the old Vercel URL if you're fully migrating, or keep it for staging

**What stays the same (no changes needed):**
```javascript
// supabase-config.js — these values do NOT change when switching hosts
var SUPABASE_URL = 'https://dbppxzkkgdtnmikkviyt.supabase.co';
var SUPABASE_ANON_KEY = '(your existing anon key)';
// Supabase is a separate service. It doesn't care where the HTML is hosted.
// The anon key is safe to expose because RLS policies protect all data.
```

> **Key Point:** Supabase URL and anon key never change. The database lives on Supabase's servers, not your hosting. You're just moving where the HTML/CSS/JS files are served from.

---

## 10. Update Google Analytics

1. Go to [analytics.google.com](https://analytics.google.com)
2. Navigate to **Admin** (gear icon) → **Data Streams**
3. Click your existing data stream
4. Under **Website URL**, update to `https://yourdomain.com`
5. (Optional) Add the `www.yourdomain.com` variant too

The GA tracking code in your HTML files stays the same:
```html
<!-- This doesn't change -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-BKMJVM1TY0"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments)}
  gtag('js', new Date());
  gtag('config', 'G-BKMJVM1TY0');
</script>
```

### Update Sitemap URLs

Edit `sitemap.xml` — replace all `https://bleach-resistant.vercel.app/` with `https://yourdomain.com/`:

```xml
<!-- Before -->
<loc>https://bleach-resistant.vercel.app/home.html</loc>

<!-- After -->
<loc>https://yourdomain.com/home.html</loc>
```

### Submit Sitemap to Google

1. Go to [Google Search Console](https://search.google.com/search-console)
2. Add your new domain as a property
3. Verify ownership (DNS TXT record method is easiest with Hostinger)
4. Go to **Sitemaps** → Submit `https://yourdomain.com/sitemap.xml`

---

## 11. DNS Records Reference

If you need to manually configure DNS (e.g., using a domain from another registrar), go to hPanel → **Domains** → **DNS Zone Editor** and add these records:

| Record Type | Name | Value | TTL | Purpose |
|------------|------|-------|-----|---------|
| **A** | `@` | `(Hostinger IP)` | 14400 | Points domain to server |
| **A** | `www` | `(Hostinger IP)` | 14400 | Points www subdomain |
| **CNAME** | `www` | `yourdomain.com` | 14400 | Alternative to A record for www |
| **MX** | `@` | `mx1.hostinger.com` (priority 5) | 14400 | Email routing |
| **MX** | `@` | `mx2.hostinger.com` (priority 10) | 14400 | Email routing backup |
| **TXT** | `@` | `v=spf1 include:_spf.hostinger.com ~all` | 14400 | Email SPF (anti-spam) |
| **TXT** | `_dmarc` | `v=DMARC1; p=quarantine; rua=mailto:info@yourdomain.com` | 14400 | Email DMARC policy |

**Find your Hostinger server IP:**
- hPanel → **Hosting** → **Plan Details** → **Server IP Address**

**Check DNS propagation:**
- Use [dnschecker.org](https://dnschecker.org) to verify your DNS changes have propagated globally
- Or use [whatsmydns.net](https://www.whatsmydns.net)

---

## 12. Test Everything

After uploading and configuring, verify all features work:

### Pre-Launch Checklist

**Basic:**
- [ ] `https://yourdomain.com` loads home page (not Hostinger parking page)
- [ ] SSL padlock visible in browser
- [ ] `https://yourdomain.com/home.html` works
- [ ] All navigation links work (click through every page)

**Dynamic Content (Supabase):**
- [ ] `https://yourdomain.com/product.html` loads products from database
- [ ] Hero slider loads dynamic slides on homepage
- [ ] Navigation loads from database (dynamic nav items appear)
- [ ] Chat widget appears on public pages (bottom-right corner)
- [ ] Category pages load sections (headgear, basicpoly, etc.)

**Forms & Auth:**
- [ ] Order form works: submit → saved to Supabase → shows success
- [ ] Signup works: create new account → confirmation
- [ ] Login works: email + password → logged in
- [ ] Client account page shows order history
- [ ] Password change works

**Admin Panel:**
- [ ] `https://yourdomain.com/admin.html` — login with admin email
- [ ] Dashboard loads stats (product count, order count, etc.)
- [ ] Product CRUD works (create, edit, delete, image upload)
- [ ] Orders visible and status update works
- [ ] Navigation editor works
- [ ] Page builder works

**Custom Pages:**
- [ ] `https://yourdomain.com/p/your-slug` renders custom page (if you have one)
- [ ] `.htaccess` rewrite works (no 404 on `/p/` URLs)

**Email:**
- [ ] Send a test email FROM `info@yourdomain.com`
- [ ] Receive a test email TO `info@yourdomain.com`
- [ ] Email doesn't land in spam folder
- [ ] Check SPF/DKIM/DMARC: [mail-tester.com](https://www.mail-tester.com)

**Performance:**
- [ ] Page loads in under 3 seconds
- [ ] Gzip compression active (check with browser dev tools → Network → Response Headers)
- [ ] Static assets being cached (check `Expires` header in dev tools)

---

## 13. Vercel vs Hostinger — Decision Guide

| Scenario | Use Vercel | Use Hostinger |
|----------|-----------|---------------|
| Just need free hosting | ✅ | |
| Want custom domain + email | | ✅ |
| Auto-deploy from GitHub | ✅ (built-in) | ✅ (webhook setup) |
| Need PHP backend later | | ✅ |
| Need cron jobs | | ✅ |
| Global CDN speed | ✅ (better) | ⚠️ (single server, but Hostinger CDN available) |
| Budget = $0 | ✅ | |
| Professional business setup | | ✅ |
| Multiple websites | | ✅ (100 sites on Premium) |
| File uploads via FTP | | ✅ |
| Database hosting (MySQL) | | ✅ (not needed — we use Supabase) |
| Serverless functions | ✅ | |
| Server-side rendering | ✅ | |

**Best approach: Run both.**
- **Vercel** = staging environment (`bleach-resistant.vercel.app`)
- **Hostinger** = production (`yourdomain.com`)
- Push to GitHub → deploys to both automatically
- Test changes on Vercel first, then they go live on Hostinger too

---

## 14. Migration Checklist (Vercel → Hostinger)

Print this and check off each step:

```
PREPARATION:
1. □ Buy Hostinger Premium Web Hosting plan ($2.99/mo)
2. □ Register domain (or claim free domain with plan)
3. □ Wait for domain DNS propagation (up to 48 hours)

FILES:
4. □ Upload all project files to public_html/
5. □ Create .htaccess file (URL rewrites, HTTPS, security, caching)
6. □ Create index.html redirect fallback
7. □ Verify: visit yourdomain.com — site loads

SECURITY:
8. □ Enable Free SSL (Let's Encrypt) in hPanel
9. □ Toggle Force HTTPS in hPanel
10. □ Verify: padlock icon visible on all pages

EMAIL:
11. □ Create professional email account(s)
12. □ Set up SPF, DKIM, DMARC DNS records
13. □ Test send/receive from all email accounts
14. □ Add email to phone/Gmail/Outlook

SERVICES:
15. □ Update Supabase Auth redirect URLs to new domain
16. □ Update Google Analytics data stream URL
17. □ Update sitemap.xml URLs to new domain
18. □ Submit new sitemap to Google Search Console

TESTING:
19. □ Test all public pages load correctly
20. □ Test dynamic content (products, slider, nav, chat)
21. □ Test order form submission
22. □ Test login/signup/account
23. □ Test admin panel (login, CRUD, uploads)
24. □ Test custom page URLs (/p/slug)
25. □ Test on mobile device

OPTIONAL:
26. □ Set up Git auto-deploy webhook
27. □ Keep Vercel as staging environment
28. □ Set up Hostinger CDN for performance
29. □ Set up automated backups in hPanel
```

---

## 15. Troubleshooting Common Issues

### "Site shows Hostinger parking page"
**Cause:** Files not uploaded to `public_html/` yet, or no `home.html`/`index.html`.
**Fix:** Upload your files. Ensure `home.html` exists in `public_html/`. Create `.htaccess` with `DirectoryIndex home.html`.

### "SSL not working / browser shows 'Not Secure'"
**Cause:** SSL certificate not yet issued (takes 5-30 minutes).
**Fix:** Wait 30 minutes. Then in hPanel → Security → SSL → Force HTTPS → ON. If still not working, reinstall the SSL certificate.

### "Custom page URLs like /p/blog give 404"
**Cause:** `.htaccess` rewrite rules not configured or `mod_rewrite` not enabled.
**Fix:** Create/verify `.htaccess` with the `RewriteRule` shown in Step 6. Hostinger has `mod_rewrite` enabled by default.

### "500 Internal Server Error"
**Cause:** Syntax error in `.htaccess` file.
**Fix:** Rename `.htaccess` to `.htaccess.bak` (fixes the error immediately). Then check for typos, fix, and rename back.

### "Supabase queries fail / CORS error"
**Cause:** Very rare — Supabase anon key allows requests from any origin by default.
**Fix:** Go to Supabase → Settings → API → verify CORS is set to `*` (default). If restricted, add your domain.

### "Email going to spam"
**Cause:** SPF/DKIM/DMARC records not configured.
**Fix:**
1. Add SPF TXT record: `v=spf1 include:_spf.hostinger.com ~all`
2. Set up DKIM: hPanel → Emails → Email DNS Records → copy DKIM value → add as TXT record
3. Add DMARC TXT record: `v=DMARC1; p=quarantine; rua=mailto:info@yourdomain.com`
4. Test at [mail-tester.com](https://www.mail-tester.com) — aim for 9/10 or higher

### "Changes not showing after update"
**Cause:** Browser cache serving old files.
**Fix:** Hard refresh with `Ctrl + Shift + R`. Or bump the `?v=N` version number on CSS/JS files across all HTML files.

### "Git deploy shows wrong files / old version"
**Cause:** Deployment path not set to `public_html`, or wrong branch.
**Fix:** hPanel → Advanced → Git → edit repository → set path to `public_html` and branch to `master`. Click **Deploy** manually to force update.

### "www.yourdomain.com shows different site than yourdomain.com"
**Cause:** DNS not configured for www subdomain, or no redirect rule.
**Fix:** Add a `CNAME` record for `www` pointing to `yourdomain.com`. Then uncomment the www redirect in `.htaccess` (Force non-www recommended).

### "File upload in admin not working"
**Cause:** This uploads to Supabase Storage, not Hostinger. If it was working on Vercel, it should work on Hostinger too.
**Fix:** Check browser console for errors. Verify Supabase Storage bucket exists and has correct policies. The hosting provider doesn't affect Supabase operations.

---

## Quick Reference Card

```
HOSTINGER LOGIN:       https://hpanel.hostinger.com
FILE MANAGER:          hPanel → Files → File Manager → public_html/
FTP:                   ftp.yourdomain.com, Port 21 (or SFTP Port 22)
GIT:                   hPanel → Advanced → Git
SSL:                   hPanel → Security → SSL
EMAIL:                 hPanel → Emails → Email Accounts
WEBMAIL:               https://mail.yourdomain.com
DNS:                   hPanel → Domains → DNS Zone Editor
BACKUPS:               hPanel → Files → Backups
SSH:                   hPanel → Advanced → SSH Access

SUPABASE (unchanged):  https://dbppxzkkgdtnmikkviyt.supabase.co
GITHUB:                https://github.com/tzkusman/bleach-resistant
VERCEL (staging):      https://bleach-resistant.vercel.app
```
