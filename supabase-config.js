/*  ============================================================
 *  supabase-config.js — Shared Supabase Client
 *  Bleach Resistant
 *  ============================================================
 *
 *  SETUP:
 *  1) Go to https://supabase.com → your project → Settings → API
 *  2) Replace the two values below with your real credentials
 *  3) Run supabase-setup.sql in the SQL Editor first
 *
 *  ORDERS TABLE — run this migration in Supabase SQL Editor if
 *  you haven't already (adds columns for the new order form):
 *
 *  ALTER TABLE orders
 *    ADD COLUMN IF NOT EXISTS first_name   TEXT,
 *    ADD COLUMN IF NOT EXISTS last_name    TEXT,
 *    ADD COLUMN IF NOT EXISTS company      TEXT,
 *    ADD COLUMN IF NOT EXISTS city         TEXT,
 *    ADD COLUMN IF NOT EXISTS country      TEXT,
 *    ADD COLUMN IF NOT EXISTS service_type TEXT,
 *    ADD COLUMN IF NOT EXISTS sizes        TEXT,
 *    ADD COLUMN IF NOT EXISTS colors       TEXT,
 *    ADD COLUMN IF NOT EXISTS urgency      TEXT,
 *    ADD COLUMN IF NOT EXISTS budget_range TEXT,
 *    ADD COLUMN IF NOT EXISTS attachment_url TEXT,
 *    ADD COLUMN IF NOT EXISTS vehicle_model TEXT,
 *    ADD COLUMN IF NOT EXISTS design_format TEXT,
 *    ADD COLUMN IF NOT EXISTS source       TEXT,
 *    ADD COLUMN IF NOT EXISTS source_page  TEXT,
 *    ADD COLUMN IF NOT EXISTS user_id      UUID REFERENCES auth.users(id) ON DELETE SET NULL;
 *
 *  Also create the storage bucket for attachments:
 *  INSERT INTO storage.buckets (id, name, public)
 *    VALUES ('order-attachments', 'order-attachments', true)
 *    ON CONFLICT DO NOTHING;
 *
 *  This file is loaded by ALL pages (public + admin).
 *  The anon key is safe in HTML because RLS restricts it.
 *  ============================================================ */

const SUPABASE_URL  = 'https://dbppxzkkgdtnmikkviyt.supabase.co';
const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRicHB4emtrZ2R0bm1pa2t2aXl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4MDI0NzMsImV4cCI6MjA4MzM3ODQ3M30.HSrv-AOr5FISZTPb-QbFTNXAxHagzBwDoDRnFDDPlak';

// Initialize client (supabase-js CDN must be loaded before this file)
const db = supabase.createClient(SUPABASE_URL, SUPABASE_ANON);

/* ---------- Admin Config ---------- */

const BR_ADMIN_EMAIL = 'usman@gmail.com';

/* ---------- Auth Helpers (used by admin pages) ---------- */

async function brGetUser() {
  const { data: { user } } = await db.auth.getUser();
  return user;
}

function brIsAdmin(user) {
  return user && user.email && user.email.toLowerCase() === BR_ADMIN_EMAIL.toLowerCase();
}

async function brRequireAuth() {
  const user = await brGetUser();
  if (!user) {
    window.location.href = 'login.html';
    throw new Error('Not authenticated');
  }
  return user;
}

async function brRequireAdmin() {
  const user = await brRequireAuth();
  if (!brIsAdmin(user)) {
    window.location.replace('home.html');
    throw new Error('Admin access required');
  }
  // Reveal admin page content (hidden by default via .admin-hidden)
  document.body.classList.remove('admin-hidden');
  document.body.style.display = '';
  return user;
}

async function brSignOut() {
  await db.auth.signOut();
  window.location.href = 'home.html';
}

/* ---------- Storage Helpers ---------- */

async function brUploadFile(bucket, file, folder) {
  const ext = file.name.split('.').pop();
  const name = folder + '/' + Date.now() + '_' + Math.random().toString(36).slice(2, 8) + '.' + ext;
  const { data, error } = await db.storage.from(bucket).upload(name, file, {
    cacheControl: '3600',
    upsert: false
  });
  if (error) throw error;
  const { data: urlData } = db.storage.from(bucket).getPublicUrl(name);
  return { path: name, url: urlData.publicUrl };
}

async function brDeleteFile(bucket, path) {
  const { error } = await db.storage.from(bucket).remove([path]);
  if (error) throw error;
}

/* ---------- Page Content Helpers ---------- */

async function brGetPageContent(pageName) {
  const { data, error } = await db
    .from('page_content')
    .select('*')
    .eq('page_name', pageName);
  if (error) throw error;
  return data || [];
}

async function brUpsertContent(pageName, selector, contentType, contentValue) {
  const { data, error } = await db
    .from('page_content')
    .upsert({
      page_name: pageName,
      element_selector: selector,
      content_type: contentType,
      content_value: contentValue,
      updated_at: new Date().toISOString()
    }, { onConflict: 'page_name,element_selector' });
  if (error) throw error;
  return data;
}

/* ---------- Utility ---------- */

function brFormatDate(isoStr) {
  if (!isoStr) return '—';
  const d = new Date(isoStr);
  return d.toLocaleDateString('en-CA', { year: 'numeric', month: 'short', day: 'numeric' })
       + ' ' + d.toLocaleTimeString('en-CA', { hour: '2-digit', minute: '2-digit' });
}

function brEscapeHtml(str) {
  if (!str) return '';
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}
