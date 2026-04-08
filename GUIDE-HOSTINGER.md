# Hosting on Hostinger — Simple Guide

> **Simplest way to host this project on Hostinger with GitHub auto-deploy.**
> You already have Supabase — this just covers hosting the static files + connecting a domain.

---

## Overview (4 Steps)

1. Buy Hostinger hosting + domain
2. Connect your GitHub repo for auto-deploy
3. Create `.htaccess` file (sets homepage + HTTPS)
4. Update Supabase redirect URLs

**Total time: ~15 minutes** (plus up to 48h for DNS propagation)

---

## Step 1: Buy Hostinger + Domain

1. Go to [hostinger.com](https://www.hostinger.com) → **Web Hosting** (not WordPress)
2. Pick **Premium Web Hosting** (~$2.99/month) — includes free domain for 1 year
3. Complete purchase
4. When prompted, claim your free domain (e.g., `bleachresistant.com`)
5. If you already own a domain elsewhere, point its **nameservers** to:
   ```
   ns1.dns-parking.com
   ns2.dns-parking.com
   ```
   (Check your Hostinger welcome email for exact nameservers)

---

## Step 2: Connect GitHub for Auto-Deploy

This is the easiest method — push to GitHub and your site updates automatically (just like Vercel).

### 2a. Set Up Git Deploy

1. Log in to [hpanel.hostinger.com](https://hpanel.hostinger.com)
2. When asked "What do you want to build?", select **"Upload my own website"**
3. Go to **Advanced** → **Git**
4. Click **Create a New Repository**
5. Settings:
   - **Repository URL**: `https://github.com/tzkusman/bleach-resistant.git`
   - **Branch**: `master`
   - **Deployment Path**: `public_html`
6. Click **Create** → then **Deploy**

### 2b. Set Up Auto-Deploy Webhook

So every `git push` auto-deploys (no manual clicking):

1. In hPanel → **Advanced** → **Git** → copy the **Webhook URL**
2. In GitHub → your repo → **Settings** → **Webhooks** → **Add webhook**
3. **Payload URL**: paste the Hostinger webhook URL
4. **Content type**: `application/json`
5. **Events**: select **"Just the push event"**
6. Click **Add webhook**

**Now every `git push origin master` deploys to both Vercel AND Hostinger automatically.**

### 2c. Test It

```bash
git add -A
git commit -m "Test Hostinger deploy"
git push origin master
# Wait ~30 seconds, then visit your domain
```

---

## Step 3: Create .htaccess File

Your site uses `home.html` as homepage, not `index.html`. Create `.htaccess` in your project root:

```apache
# Set home.html as homepage
DirectoryIndex home.html index.html

# Enable URL rewriting
RewriteEngine On

# Custom page URLs: /p/slug → page.html?slug=slug
RewriteRule ^p/([a-zA-Z0-9_-]+)/?$ /page.html?slug=$1 [L,QSA]

# Force HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}/$1 [R=301,L]

# Security headers
<IfModule mod_headers.c>
  Header set X-Frame-Options "DENY"
  Header set X-Content-Type-Options "nosniff"
  Header set X-XSS-Protection "1; mode=block"
</IfModule>

# Block sensitive files
<FilesMatch "\.(sql|md|gitignore)$">
  Order allow,deny
  Deny from all
</FilesMatch>

# Prevent directory listing
Options -Indexes

# 404 → homepage
ErrorDocument 404 /home.html
```

Commit and push this file — it deploys automatically via the webhook.

**Also enable SSL in Hostinger:**
1. hPanel → **Security** → **SSL** → **Install** (Free Let's Encrypt)
2. Toggle **Force HTTPS** to ON

---

## Step 4: Update Supabase Redirect URLs

Your Supabase URL and keys stay exactly the same — Supabase is a separate service. Just update the auth redirect URLs:

1. Go to [supabase.com](https://supabase.com) → your project → **Authentication** → **URL Configuration**
2. Set **Site URL**: `https://yourdomain.com`
3. Under **Redirect URLs**, add:
   ```
   https://yourdomain.com/**
   https://www.yourdomain.com/**
   ```

> **Nothing else changes.** `supabase-config.js` keeps the same URL and anon key. The database lives on Supabase's servers regardless of where you host the HTML files.

---

## That's It!

Your workflow is now:
```
Edit code → git push origin master → Auto-deploys to Vercel + Hostinger
```

### Quick Checklist

- [ ] Domain loads your site (not Hostinger parking page)
- [ ] SSL padlock visible (`https://`)
- [ ] Products, blog, cotton pages load from Supabase
- [ ] Admin panel works (`/admin.html`)
- [ ] Order form submits successfully
- [ ] Login/signup works

### Troubleshooting

| Problem | Fix |
|---------|-----|
| Parking page showing | Wait for DNS (up to 48h). Check files are in `public_html/` |
| No SSL padlock | hPanel → Security → SSL → Install → Force HTTPS ON |
| 500 error | Check `.htaccess` for typos. Rename to `.htaccess.bak` to test |
| Custom URLs `/p/slug` give 404 | Verify `.htaccess` has the RewriteRule |
| Git deploy not updating | hPanel → Advanced → Git → click **Deploy** manually |

### Reference

```
HOSTINGER PANEL:  https://hpanel.hostinger.com
SUPABASE:         https://dbppxzkkgdtnmikkviyt.supabase.co
GITHUB:           https://github.com/tzkusman/bleach-resistant
VERCEL (staging): https://bleach-resistant.vercel.app
```
