# Admin Panel Blueprint — Complete Build Guide

> **How to build a production-grade admin panel with zero backend code.**
> Copy this pattern for any project: web, desktop (Electron), or mobile (Capacitor/WebView).

---

## Table of Contents

1. [Architecture Pattern](#1-architecture-pattern)
2. [Admin CSS Framework](#2-admin-css-framework)
3. [Page Layout Template](#3-page-layout-template)
4. [The CRUD Page Blueprint](#4-the-crud-page-blueprint)
5. [Dashboard Page](#5-dashboard-page)
6. [Products CRUD (Full Example)](#6-products-crud-full-example)
7. [Orders Management](#7-orders-management)
8. [Contacts & Reply System](#8-contacts--reply-system)
9. [Hero Slider CRUD](#9-hero-slider-crud)
10. [Page Sections Editor](#10-page-sections-editor)
11. [Visual Page Editor](#11-visual-page-editor)
12. [Media Library](#12-media-library)
13. [Site Settings](#13-site-settings)
14. [Reusable Components](#14-reusable-components)
15. [Adapting for Desktop & Mobile](#15-adapting-for-desktop--mobile)
16. [Blog CMS](#16-blog-cms)
17. [Cotton CMS](#17-cotton-cms)
18. [Complete Prompt for AI Recreation](#18-complete-prompt-for-ai-recreation)

---

## 1. Architecture Pattern

Every admin page is a **self-contained HTML file** with:

```
admin-[feature].html
├── <head>          → Meta, fonts, admin.css, Supabase SDK, supabase-config.js
├── <body>          → Starts hidden (display:none)
│   ├── Sidebar     → Same on every admin page (copy-paste)
│   ├── Main Content
│   │   ├── Topbar  → Page title + breadcrumb
│   │   └── Content → Data table/cards + modal form
│   └── Toast       → Notification element
└── <script>        → ALL JS inline (no external files)
    ├── Auth check  → brRequireAdmin()
    ├── Load data   → SELECT from Supabase
    ├── Render      → Build HTML from data
    ├── CRUD ops    → INSERT, UPDATE, DELETE
    ├── Modal       → Open/close/populate form
    ├── Search      → Client-side filter
    ├── Export      → CSV/JSON download
    └── Init        → Load on page ready
```

**Why self-contained?** Each page works independently. You can copy a single file to another project and it works. No build step, no imports, no dependencies between admin pages.

---

## 2. Admin CSS Framework

### 2.1 Core Layout

```css
/* Sidebar + Main Content */
body {
  display: flex; min-height: 100vh; margin: 0;
  font-family: 'Montserrat', sans-serif; background: #f4f5f7;
}

/* Sidebar */
.sidebar {
  width: 260px; background: #1a1a2e; color: #fff;
  display: flex; flex-direction: column; position: fixed;
  height: 100vh; overflow-y: auto; z-index: 100;
}
.sidebar-brand { padding: 24px 20px; border-bottom: 1px solid rgba(255,255,255,0.08); }
.sidebar-brand h2 { font-size: 16px; color: #C7065C; margin: 0; }
.sidebar-brand small { font-size: 10px; color: rgba(255,255,255,0.4); text-transform: uppercase; letter-spacing: 2px; }

/* Nav Links */
.sidebar-nav a {
  display: flex; align-items: center; gap: 10px;
  padding: 10px 20px; color: rgba(255,255,255,0.6); font-size: 13px;
  text-decoration: none; transition: all 0.15s;
}
.sidebar-nav a:hover { background: rgba(255,255,255,0.05); color: #fff; }
.sidebar-nav a.active { background: rgba(199,6,92,0.15); color: #C7065C; border-right: 3px solid #C7065C; }

/* Nav Sections */
.nav-section {
  font-size: 10px; font-weight: 700; text-transform: uppercase;
  letter-spacing: 2px; color: rgba(255,255,255,0.25);
  padding: 20px 20px 8px;
}

/* Main Content */
.main-content {
  flex: 1; margin-left: 260px; display: flex; flex-direction: column;
}

/* Topbar */
.topbar {
  padding: 20px 32px; border-bottom: 1px solid #e5e5e5; background: #fff;
  display: flex; align-items: center; justify-content: space-between;
}
.topbar h1 { font-size: 20px; font-weight: 800; margin: 0; }
.breadcrumb { font-size: 12px; color: #999; }

/* Content Area */
.content-area { padding: 24px 32px; flex: 1; }
```

### 2.2 Component Classes

```css
/* Buttons */
.btn {
  padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 600;
  border: none; cursor: pointer; transition: all 0.15s; font-family: inherit;
}
.btn-primary { background: #C7065C; color: #fff; }
.btn-primary:hover { background: #a00548; }
.btn-secondary { background: #f0f0f0; color: #555; }
.btn-danger { background: #e74c3c; color: #fff; }
.btn-success { background: #22c55e; color: #fff; }
.btn-sm { padding: 6px 14px; font-size: 12px; }
.btn-block { width: 100%; }

/* Stat Cards */
.stat-card {
  background: #fff; border-radius: 12px; padding: 24px;
  border-left: 4px solid #C7065C; box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
.stat-card .stat-number { font-size: 28px; font-weight: 800; }
.stat-card .stat-label { font-size: 12px; color: #888; text-transform: uppercase; }

/* Data Tables */
.data-table { width: 100%; border-collapse: collapse; }
.data-table th {
  font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;
  color: #888; text-align: left; padding: 12px 16px; border-bottom: 2px solid #eee;
}
.data-table td { padding: 14px 16px; border-bottom: 1px solid #f0f0f0; font-size: 13px; }
.data-table tr:hover { background: #fafafa; }

/* Badges */
.badge {
  display: inline-block; padding: 3px 10px; border-radius: 20px;
  font-size: 11px; font-weight: 700;
}
.badge-new { background: #e3f2fd; color: #1976d2; }
.badge-progress { background: #fff3e0; color: #f57c00; }
.badge-complete { background: #e8f5e9; color: #2e7d32; }
.badge-closed { background: #f5f5f5; color: #999; }

/* Modal */
.modal-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 9999;
  display: none; align-items: center; justify-content: center;
}
.modal-overlay.active { display: flex; }
.modal {
  background: #fff; border-radius: 16px; width: 95%; max-width: 600px;
  max-height: 90vh; overflow-y: auto; box-shadow: 0 16px 48px rgba(0,0,0,0.2);
}
.modal-header {
  padding: 20px 24px; border-bottom: 1px solid #eee;
  display: flex; align-items: center; justify-content: space-between;
}
.modal-body { padding: 24px; }
.modal-footer {
  padding: 16px 24px; border-top: 1px solid #eee;
  display: flex; justify-content: flex-end; gap: 8px;
}

/* Forms */
.form-group { margin-bottom: 16px; }
.form-group label {
  display: block; font-size: 11px; font-weight: 700;
  text-transform: uppercase; letter-spacing: 0.5px; color: #555; margin-bottom: 6px;
}
.form-group input,
.form-group select,
.form-group textarea {
  width: 100%; padding: 10px 14px; border: 1px solid #ddd; border-radius: 8px;
  font-size: 13px; font-family: inherit; box-sizing: border-box; transition: border-color 0.2s;
}
.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  border-color: #C7065C; outline: none; box-shadow: 0 0 0 3px rgba(199,6,92,0.1);
}

/* Toast */
.toast {
  position: fixed; bottom: 24px; right: 24px; padding: 14px 24px;
  border-radius: 10px; font-size: 13px; font-weight: 600; z-index: 99999;
  opacity: 0; transform: translateY(20px); transition: all 0.3s;
}
.toast.show { opacity: 1; transform: translateY(0); }
.toast-success { background: #22c55e; color: #fff; }
.toast-error { background: #e74c3c; color: #fff; }
.toast-info { background: #3b82f6; color: #fff; }

/* Responsive */
@media (max-width: 768px) {
  .sidebar { width: 60px; }
  .sidebar-brand h2, .sidebar-nav .nav-section, .sidebar-nav a span:not(.icon) { display: none; }
  .main-content { margin-left: 60px; }
}
```

---

## 3. Page Layout Template

Copy-paste this for every new admin page:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Feature Name — Admin Panel</title>
  <link rel="icon" href="favicon.svg">
  <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="admin.css">
  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
  <script src="supabase-config.js?v=7"></script>
</head>
<body class="admin-hidden" style="display:none">

  <!-- ═══ SIDEBAR (same on every page) ═══ -->
  <nav class="sidebar">
    <div class="sidebar-brand"><h2>Brand Name</h2><small>Admin Panel</small></div>
    <div class="sidebar-nav">
      <div class="nav-section">Main</div>
      <a href="admin.html"><span class="icon">📊</span> Dashboard</a>
      <a href="admin-orders.html"><span class="icon">📦</span> Orders</a>
      <a href="admin-contacts.html"><span class="icon">💬</span> Contacts</a>
      <div class="nav-section">Content</div>
      <a href="admin-products.html" class="active"><span class="icon">🛍️</span> Products</a>
      <a href="admin-slider.html"><span class="icon">🎠</span> Hero Slider</a>
      <a href="admin-sections.html"><span class="icon">📐</span> Page Sections</a>
      <a href="admin-media.html"><span class="icon">🖼️</span> Media Library</a>
      <div class="nav-section">Settings</div>
      <a href="admin-settings.html"><span class="icon">⚙️</span> Site Settings</a>
    </div>
    <div class="sidebar-footer">
      <div class="user-info">
        <div class="user-avatar" id="user-avatar">A</div>
        <div>
          <div id="user-name" style="font-size:12px;font-weight:600;">Admin</div>
          <div id="user-email" class="user-email">loading…</div>
        </div>
      </div>
      <button class="btn btn-secondary btn-sm btn-block" onclick="brSignOut()">Sign Out</button>
    </div>
  </nav>

  <!-- ═══ MAIN CONTENT ═══ -->
  <div class="main-content">
    <div class="topbar">
      <div>
        <h1>Feature Name</h1>
        <div class="breadcrumb">Manage your feature items</div>
      </div>
      <button class="btn btn-primary" onclick="openEditor()">+ Add New</button>
    </div>

    <div class="content-area">
      <!-- Search bar -->
      <div style="display:flex;gap:12px;margin-bottom:20px;">
        <input type="text" id="search" placeholder="Search..." class="form-group input"
               style="flex:1;padding:10px 16px;border:1px solid #ddd;border-radius:8px;font-size:13px;"
               oninput="filterItems()">
        <span id="item-count" style="font-size:13px;color:#888;align-self:center;">(0)</span>
      </div>

      <!-- Data display -->
      <div id="items-list"></div>
    </div>
  </div>

  <!-- ═══ MODAL ═══ -->
  <div class="modal-overlay" id="modal-overlay">
    <div class="modal">
      <div class="modal-header">
        <h3 id="modal-title">Add Item</h3>
        <button onclick="closeModal()" style="background:none;border:none;font-size:20px;cursor:pointer;">&times;</button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="item-id">
        <!-- Form fields here -->
        <div class="form-group">
          <label>Name</label>
          <input type="text" id="item-name">
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" onclick="closeModal()">Cancel</button>
        <button class="btn btn-primary" id="save-btn" onclick="saveItem()">Save</button>
      </div>
    </div>
  </div>

  <!-- ═══ TOAST ═══ -->
  <div id="toast" class="toast"></div>

  <script>
    // ═══════════════════════════════════════════════
    //  ALL JS FOR THIS PAGE GOES HERE
    // ═══════════════════════════════════════════════

    let allItems = [];

    // ── Toast ──
    function showToast(msg, type) {
      const t = document.getElementById('toast');
      t.className = 'toast toast-' + (type || 'info');
      t.textContent = msg;
      t.classList.add('show');
      setTimeout(() => t.classList.remove('show'), 3000);
    }

    // ── Modal ──
    function closeModal() {
      document.getElementById('modal-overlay').classList.remove('active');
    }

    function openEditor(item) {
      document.getElementById('modal-title').textContent = item ? 'Edit Item' : 'Add Item';
      document.getElementById('item-id').value = item ? item.id : '';
      document.getElementById('item-name').value = item ? item.name : '';
      document.getElementById('modal-overlay').classList.add('active');
    }

    // ── HTML Escape (security) ──
    function esc(s) {
      const d = document.createElement('div');
      d.textContent = s || '';
      return d.innerHTML;
    }

    // ── Load Data ──
    async function loadItems() {
      try {
        const { data, error } = await db.from('your_table').select('*')
          .order('created_at', { ascending: false });
        if (error) throw error;
        allItems = data || [];
        renderItems();
      } catch (err) {
        document.getElementById('items-list').innerHTML =
          '<p style="color:#e74c3c;">Error: ' + esc(err.message) + '</p>';
      }
    }

    // ── Render Data ──
    function renderItems() {
      const container = document.getElementById('items-list');
      document.getElementById('item-count').textContent = '(' + allItems.length + ')';

      if (allItems.length === 0) {
        container.innerHTML = '<div style="text-align:center;padding:40px;">' +
          '<p>No items yet.</p>' +
          '<button class="btn btn-primary btn-sm" onclick="openEditor()">+ Add First Item</button></div>';
        return;
      }

      container.innerHTML = '<table class="data-table"><thead><tr>' +
        '<th>Name</th><th>Created</th><th>Actions</th>' +
        '</tr></thead><tbody>' +
        allItems.map(item =>
          '<tr><td>' + esc(item.name) + '</td>' +
          '<td>' + new Date(item.created_at).toLocaleDateString() + '</td>' +
          '<td><button class="btn btn-sm btn-secondary" onclick="editItem(\'' + item.id + '\')">Edit</button> ' +
          '<button class="btn btn-sm btn-danger" onclick="deleteItem(\'' + item.id + '\')">Delete</button></td></tr>'
        ).join('') +
        '</tbody></table>';
    }

    // ── Edit ──
    function editItem(id) {
      const item = allItems.find(x => x.id === id);
      if (item) openEditor(item);
    }

    // ── Save (Create or Update) ──
    async function saveItem() {
      const id = document.getElementById('item-id').value;
      const data = {
        name: document.getElementById('item-name').value.trim()
      };

      if (!data.name) { showToast('Name is required', 'error'); return; }

      const btn = document.getElementById('save-btn');
      btn.disabled = true;
      btn.textContent = 'Saving...';

      try {
        let result;
        if (id) {
          result = await db.from('your_table').update(data).eq('id', id);
        } else {
          result = await db.from('your_table').insert(data);
        }
        if (result.error) throw result.error;

        showToast(id ? 'Updated!' : 'Created!', 'success');
        closeModal();
        loadItems();
      } catch (err) {
        showToast('Error: ' + err.message, 'error');
      }

      btn.disabled = false;
      btn.textContent = 'Save';
    }

    // ── Delete ──
    async function deleteItem(id) {
      if (!confirm('Delete this item?')) return;
      try {
        const { error } = await db.from('your_table').delete().eq('id', id);
        if (error) throw error;
        showToast('Deleted', 'success');
        loadItems();
      } catch (err) {
        showToast('Error: ' + err.message, 'error');
      }
    }

    // ── Search/Filter ──
    function filterItems() {
      const q = document.getElementById('search').value.toLowerCase();
      const rows = document.querySelectorAll('.data-table tbody tr');
      rows.forEach(row => {
        row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
      });
    }

    // ── CSV Export ──
    function exportCSV() {
      if (allItems.length === 0) return;
      const headers = Object.keys(allItems[0]);
      const csv = [headers.join(','),
        ...allItems.map(row => headers.map(h =>
          '"' + String(row[h] || '').replace(/"/g, '""') + '"'
        ).join(','))
      ].join('\n');

      const blob = new Blob([csv], { type: 'text/csv' });
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = 'export.csv';
      a.click();
    }

    // ── INIT ──
    (async function() {
      const user = await brRequireAdmin();
      document.getElementById('user-name').textContent =
        user.user_metadata?.full_name || user.email.split('@')[0];
      document.getElementById('user-email').textContent = user.email;
      document.getElementById('user-avatar').textContent =
        (user.email || 'A')[0].toUpperCase();
      loadItems();
    })();
  </script>
</body>
</html>
```

**That's the complete blueprint.** Every admin page is a variation of this template.

---

## 4. The CRUD Page Blueprint

Every CRUD page has these 7 functions:

| # | Function | Purpose |
|---|----------|---------|
| 1 | `loadItems()` | Fetch from Supabase → store in `allItems` → call `renderItems()` |
| 2 | `renderItems()` | Build HTML table/cards from `allItems` array |
| 3 | `openEditor(item?)` | Open modal, populate form (empty for new, filled for edit) |
| 4 | `saveItem()` | Read form → `insert()` or `update()` → `loadItems()` |
| 5 | `deleteItem(id)` | Confirm → `delete()` → `loadItems()` |
| 6 | `filterItems()` | Client-side search filter on rendered table |
| 7 | `init()` | Auth check → set user info → `loadItems()` |

**The only things that change between pages:**
- Table name in Supabase queries
- Form fields in the modal
- Columns in the render function
- Any special logic (image upload, status workflow, etc.)

---

## 5. Dashboard Page

The dashboard aggregates data from multiple tables:

```javascript
async function loadDashboard() {
  // Fetch counts in parallel
  const [orders, contacts, media, pages] = await Promise.all([
    db.from('orders').select('*', { count: 'exact', head: true }),
    db.from('contacts').select('*', { count: 'exact', head: true }),
    db.from('media').select('*', { count: 'exact', head: true }),
    db.from('page_content').select('*', { count: 'exact', head: true })
  ]);

  // Update stat cards
  document.getElementById('stat-orders').textContent = orders.count || 0;
  document.getElementById('stat-contacts').textContent = contacts.count || 0;
  document.getElementById('stat-media').textContent = media.count || 0;
  document.getElementById('stat-pages').textContent = pages.count || 0;

  // Fetch recent items for tables
  const { data: recentOrders } = await db.from('orders').select('*')
    .order('created_at', { ascending: false }).limit(5);
  renderRecentOrders(recentOrders);

  const { data: recentContacts } = await db.from('contacts').select('*')
    .order('created_at', { ascending: false }).limit(5);
  renderRecentContacts(recentContacts);
}
```

**Stat cards layout:**
```html
<div style="display:grid; grid-template-columns:repeat(4, 1fr); gap:20px; margin-bottom:32px;">
  <div class="stat-card">
    <div class="stat-number" id="stat-orders">—</div>
    <div class="stat-label">Total Orders</div>
  </div>
  <!-- repeat for other stats -->
</div>
```

---

## 6. Products CRUD (Full Example)

### 6.1 What Makes Products Special

- **Image upload** → Supabase Storage → save URL in `image_url` column
- **Gallery** → Multiple images stored as JSON array
- **Auto-slug** → Generate URL-safe slug from name
- **Category dropdown** → Predefined categories
- **Toggle fields** → Featured, Active (boolean switches)
- **JSON fields** → Sizes, colors, features stored as JSON arrays

### 6.2 Image Upload in Modal

```html
<div class="form-group">
  <label>Product Image</label>
  <div style="display:flex;gap:12px;align-items:flex-start;">
    <div style="flex:1;">
      <input type="text" id="p-image-url" placeholder="Image URL or upload">
      <input type="file" id="p-image-file" accept="image/*" style="margin-top:8px;">
    </div>
    <div id="p-image-preview" style="width:80px;height:80px;border-radius:8px;overflow:hidden;">
      <span>No image</span>
    </div>
  </div>
</div>
```

```javascript
// Handle file upload
document.getElementById('p-image-file').addEventListener('change', async function() {
  const file = this.files[0];
  if (!file) return;
  try {
    const result = await brUploadFile('media', file, 'products');
    document.getElementById('p-image-url').value = result.url;
    document.getElementById('p-image-preview').innerHTML =
      '<img src="' + result.url + '" style="width:100%;height:100%;object-fit:cover;">';
  } catch (err) {
    showToast('Upload failed: ' + err.message, 'error');
  }
});
```

### 6.3 Auto-Slug

```javascript
document.getElementById('p-name').addEventListener('input', function() {
  if (!document.getElementById('p-id').value) { // Only auto-slug for new items
    document.getElementById('p-slug').value = this.value
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '');
  }
});
```

### 6.4 Gallery Management

```javascript
let gallery = [];

function addToGallery(url) {
  gallery.push(url);
  renderGalleryPreview();
}

function removeFromGallery(index) {
  gallery.splice(index, 1);
  renderGalleryPreview();
}

function renderGalleryPreview() {
  container.innerHTML = gallery.map((url, i) =>
    '<div style="position:relative;width:80px;height:80px;">' +
      '<img src="' + url + '" style="width:100%;height:100%;object-fit:cover;border-radius:6px;">' +
      '<button onclick="removeFromGallery(' + i + ')" style="position:absolute;top:-6px;right:-6px;">×</button>' +
    '</div>'
  ).join('');
}

// Save gallery as JSON in the product record
data.gallery = gallery; // Stored as JSONB in Postgres
```

---

## 7. Orders Management

### 7.1 What Makes Orders Special

- **Status workflow:** new → in-progress → complete → closed
- **View modal** (read-only) instead of edit modal — shows ~25 fields grouped
- **Status update** via dropdown in the view modal
- **CSV export** with all columns
- **Pagination** (20 items per page)
- **Search across** name, email, company, service type
- **Filter by status** via tab buttons

### 7.2 Status Badges

```javascript
function statusBadge(status) {
  const map = {
    'new': 'badge-new',
    'in-progress': 'badge-progress',
    'complete': 'badge-complete',
    'closed': 'badge-closed'
  };
  return '<span class="badge ' + (map[status] || 'badge-new') + '">' +
    (status || 'new').toUpperCase() + '</span>';
}
```

### 7.3 Pagination

```javascript
let currentPage = 1;
const perPage = 20;

function renderOrders() {
  const start = (currentPage - 1) * perPage;
  const pageData = filteredOrders.slice(start, start + perPage);
  const totalPages = Math.ceil(filteredOrders.length / perPage);

  // Render table rows from pageData...

  // Render pagination
  paginationEl.innerHTML =
    '<button onclick="goPage(' + (currentPage - 1) + ')" ' + (currentPage === 1 ? 'disabled' : '') + '>← Prev</button>' +
    '<span>Page ' + currentPage + ' of ' + totalPages + '</span>' +
    '<button onclick="goPage(' + (currentPage + 1) + ')" ' + (currentPage === totalPages ? 'disabled' : '') + '>Next →</button>';
}

function goPage(n) {
  currentPage = Math.max(1, Math.min(n, Math.ceil(filteredOrders.length / perPage)));
  renderOrders();
}
```

### 7.4 CSV Export

```javascript
function exportCSV() {
  const headers = ['ID','Date','Name','Email','Service','Status','Quantity','Budget'];
  const csv = [headers.join(','),
    ...allOrders.map(o => [
      o.id, o.created_at, o.first_name + ' ' + o.last_name,
      o.email, o.service_type, o.status, o.quantity, o.budget_range
    ].map(v => '"' + String(v || '').replace(/"/g, '""') + '"').join(','))
  ].join('\n');

  const blob = new Blob([csv], { type: 'text/csv' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'orders-' + new Date().toISOString().split('T')[0] + '.csv';
  a.click();
}
```

---

## 8. Contacts & Reply System

### 8.1 What Makes Contacts Special

- **Reply feature** → Admin types reply → saved to `admin_reply` column + `replied_at` timestamp
- **Reply badge** → Shows "Replied" badge in table
- **Page source** → Shows which page the message came from (chat widget sends this)
- **Mailto link** → Quick link to reply via email client

### 8.2 Reply in Modal

```javascript
async function sendReply(id) {
  const reply = document.getElementById('admin-reply').value.trim();
  if (!reply) return;

  const { error } = await db.from('contacts')
    .update({ admin_reply: reply, replied_at: new Date().toISOString() })
    .eq('id', id);

  if (error) { showToast('Error: ' + error.message, 'error'); return; }
  showToast('Reply saved!', 'success');
  loadContacts();
}
```

---

## 9. Hero Slider CRUD

### 9.1 What Makes Slider Special

- **Complex fields:** title, highlight span, subtitle, badge array (JSON), background type/value, 2 CTA buttons with text/link/style, optional product image, sort order
- **Background toggle:** gradient picker vs image upload
- **Badge editor:** JSON array rendered as tag pills
- **Image upload:** Product showcase image for split-layout slides
- **Sort order:** Drag-reorder or manual number
- **Active toggle:** Show/hide individual slides

### 9.2 Badge Array Editor

```javascript
let badges = [];

function addBadge() {
  const input = document.getElementById('badge-input');
  const val = input.value.trim();
  if (val) { badges.push(val); renderBadges(); input.value = ''; }
}

function removeBadge(i) {
  badges.splice(i, 1);
  renderBadges();
}

function renderBadges() {
  container.innerHTML = badges.map((b, i) =>
    '<span class="tag">' + esc(b) +
    '<button onclick="removeBadge(' + i + ')">×</button></span>'
  ).join('');
}

// Save: data.badges = badges; (stored as JSONB)
```

---

## 10. Page Sections Editor

### 10.1 What Makes Sections Special

- **Page dropdown:** Admin picks which page this section appears on
- **Checklist editor:** Multiline textarea → saved as JSON array
- **Image upload + URL paste:** Dual input method
- **Live preview:** Updates as admin types
- **Button pair:** Two optional CTAs with text + link

### 10.2 Live Preview Pattern

```javascript
['sec-label','sec-heading','sec-description','sec-checklist','sec-image-url','sec-btn1-text'].forEach(id => {
  document.getElementById(id).addEventListener('input', updatePreview);
});

function updatePreview() {
  const label = document.getElementById('sec-label').value;
  const heading = document.getElementById('sec-heading').value;
  // ... read all fields
  document.getElementById('sec-preview').innerHTML = /* build preview HTML */;
}
```

---

## 11. Visual Page Editor

### 11.1 How It Works

1. Admin selects a page from dropdown
2. Page loads in an `<iframe>`
3. Admin clicks any element in the iframe
4. The element's CSS selector is captured
5. Admin chooses override type (text, HTML, image, link, style, hide, show)
6. Changes saved to `page_content` table
7. On public pages, `content-loader.js` reads overrides and applies them

### 11.2 Selector Capture

```javascript
iframe.contentDocument.addEventListener('click', function(e) {
  e.preventDefault();
  var el = e.target;

  // Build a unique CSS selector
  var selector = buildSelector(el); // e.g. ".br-section:nth-child(2) h2"

  // Populate editor
  document.getElementById('selector').value = selector;
  document.getElementById('current-content').textContent = el.textContent;
});
```

---

## 12. Media Library

### 12.1 Core Features

- **Drag & drop upload** to Supabase Storage `media` bucket
- **Grid view** with thumbnails
- **Search** by filename
- **Detail modal:** shows URL, dimensions, size, type
- **Copy URL** button
- **Delete** with confirmation

### 12.2 Drag & Drop Upload

```javascript
var dropzone = document.getElementById('dropzone');

dropzone.addEventListener('dragover', e => { e.preventDefault(); dropzone.classList.add('active'); });
dropzone.addEventListener('dragleave', () => dropzone.classList.remove('active'));
dropzone.addEventListener('drop', async e => {
  e.preventDefault();
  dropzone.classList.remove('active');

  const files = Array.from(e.dataTransfer.files);
  for (const file of files) {
    const { path, url } = await brUploadFile('media', file, 'library');
    // Save metadata to media table
    await db.from('media').insert({
      name: file.name, url: url, path: path,
      size: file.size, mime_type: file.type, bucket: 'media'
    });
  }
  loadMedia();
});
```

---

## 13. Site Settings

### 13.1 Key-Value Pattern

The settings page uses a tabbed interface with 10 panels:

| Panel | Settings |
|-------|----------|
| Business Info | Name, tagline, phone, email, address, hours |
| Branding | Primary/secondary/bg/text colors, heading/body fonts |
| Social Media | Facebook, Instagram, YouTube, Twitter, LinkedIn, TikTok URLs |
| SEO | Title suffix, meta description, keywords, OG image, domain |
| Custom Code | Head injection, body injection (for analytics, chat widgets) |
| Maintenance | Toggle + custom message |
| Email Settings | Order notification email, contact form email |
| Notifications | Toggle: email on new order, status change, new contact |
| Backup & Export | Export orders CSV, contacts CSV, settings JSON, full backup JSON |
| Danger Zone | Clear page overrides, reset all settings |

### 13.2 Tab Switching

```javascript
function showPanel(name, el) {
  document.querySelectorAll('.settings-panel').forEach(p => {
    p.classList.remove('sp-active');
    p.classList.add('sp-hidden');
  });
  document.querySelectorAll('.settings-nav a').forEach(a => a.classList.remove('active'));
  document.getElementById('panel-' + name).classList.remove('sp-hidden');
  document.getElementById('panel-' + name).classList.add('sp-active');
  el.classList.add('active');
  event.preventDefault();
}
```

### 13.3 Color Picker Sync

```javascript
['primary','secondary','bg','text'].forEach(key => {
  const colorInput = document.getElementById('s-color-' + key);
  const hexInput = document.getElementById('s-color-' + key + '-hex');
  colorInput.addEventListener('input', () => { hexInput.value = colorInput.value; });
  hexInput.addEventListener('input', () => {
    if (/^#[0-9a-fA-F]{6}$/.test(hexInput.value)) colorInput.value = hexInput.value;
  });
});
```

### 13.4 Full Backup Export

```javascript
async function exportAll() {
  const [orders, contacts, pages, settings, media] = await Promise.all([
    db.from('orders').select('*'),
    db.from('contacts').select('*'),
    db.from('page_content').select('*'),
    db.from('site_settings').select('*'),
    db.from('media').select('*')
  ]);

  const backup = {
    exported_at: new Date().toISOString(),
    orders: orders.data, contacts: contacts.data,
    page_content: pages.data, site_settings: settings.data, media: media.data
  };

  downloadFile(JSON.stringify(backup, null, 2),
    'backup-' + new Date().toISOString().split('T')[0] + '.json',
    'application/json');
}
```

---

## 14. Reusable Components

### 14.1 Toast Notification

```javascript
function showToast(msg, type) {
  const t = document.getElementById('toast');
  t.className = 'toast toast-' + (type || 'info');
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), 3000);
}
```

### 14.2 Modal Open/Close

```javascript
function closeModal() {
  document.getElementById('modal-overlay').classList.remove('active');
}

function openModal() {
  document.getElementById('modal-overlay').classList.add('active');
}
```

### 14.3 HTML Escape (XSS Prevention)

```javascript
function esc(s) {
  const d = document.createElement('div');
  d.textContent = s || '';
  return d.innerHTML;
}
```

**ALWAYS use `esc()` when rendering user data into HTML.** Never do `innerHTML = userInput`. This prevents XSS attacks.

### 14.4 Date Formatter

```javascript
function formatDate(iso) {
  return new Date(iso).toLocaleDateString('en-US', {
    year: 'numeric', month: 'short', day: 'numeric'
  });
}
```

### 14.5 File Download Helper

```javascript
function downloadFile(content, filename, mimeType) {
  const blob = new Blob([content], { type: mimeType });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(a.href);
}
```

---

## 15. Adapting for Desktop & Mobile

### 15.1 Desktop App (Electron)

This admin panel works directly in Electron with zero changes:

```javascript
// main.js
const { app, BrowserWindow } = require('electron');

app.on('ready', () => {
  const win = new BrowserWindow({ width: 1400, height: 900 });
  win.loadFile('admin.html');
});
```

The Supabase client works in Electron exactly like in the browser.

### 15.2 Mobile App (Capacitor / WebView)

Wrap the admin panel in Capacitor for iOS/Android:

```bash
npm init -y
npm install @capacitor/core @capacitor/cli
npx cap init "Admin Panel" com.yourapp.admin
npx cap add android
npx cap add ios
```

Point the web directory to your HTML files. The Supabase JS SDK works in WebView.

### 15.3 Progressive Web App (PWA)

Add a `manifest.json` and service worker to make it installable:

```json
{
  "name": "Admin Panel",
  "short_name": "Admin",
  "start_url": "/admin.html",
  "display": "standalone",
  "theme_color": "#1a1a2e",
  "background_color": "#f4f5f7"
}
```

### 15.4 React/Vue/Svelte Port

The pattern stays identical. Replace HTML string building with components:

```jsx
// React equivalent of renderItems()
function ItemList({ items }) {
  return (
    <table className="data-table">
      <thead><tr><th>Name</th><th>Actions</th></tr></thead>
      <tbody>
        {items.map(item => (
          <tr key={item.id}>
            <td>{item.name}</td>
            <td><button onClick={() => editItem(item)}>Edit</button></td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

The Supabase calls, auth pattern, and CRUD logic stay exactly the same.

---

## 16. Blog CMS

**File:** `admin-blog.html`
**Tables:** `blog_posts`, `blog_categories`
**Migration:** `supabase-migration-blog.sql`

Full CRUD for blog articles with:
- Rich text editor (bold, italic, headings, lists, blockquote, links, images, HTML source)
- Featured image upload to `media/blog/` in Supabase Storage
- Tags (JSONB array), category selection, status (published/draft)
- Auto-slug generation from title
- SEO meta description with character count
- Grid/list view toggle, search, stats bar
- Category manager modal (add/edit/delete categories)

**Public pages:** `blog.html` (listing with category filters, search, pagination) and `blog-post.html` (detail with related posts, share buttons, view counter)

---

## 17. Cotton CMS

**File:** `admin-cotton.html`
**Tables:** `cotton_posts`, `cotton_categories`
**Migration:** `supabase-migration-cotton.sql`

Identical pattern to Blog CMS — full CRUD for cotton articles. Same feature set:
- Rich text editor, image upload to `media/cotton/`, tags, categories, status
- Auto-slug, SEO meta, grid/list view, search, stats, category manager

**Public pages:** `cotton.html` (listing page in Products dropdown) and `cotton-detail.html` (detail page with related posts, share buttons, view counter)

**Key difference from Blog:** Cotton appears under **Products** dropdown in navigation, while Blog is a top-level nav item.

---

## 18. Complete Prompt for AI Recreation

Use this prompt to build a similar admin panel from scratch:

```
Build a complete admin panel with these exact specifications:

TECHNOLOGY:
- Single HTML file per admin page (self-contained, no imports between pages)
- Vanilla CSS in one admin.css file
- All JavaScript inline in each HTML page's <script> block
- Supabase JS SDK loaded from CDN
- Supabase for auth, database (Postgres + RLS), and file storage

LAYOUT:
- Fixed left sidebar (260px, dark navy #1a1a2e background)
  - Brand logo + name at top
  - Navigation links grouped by section (Main, Content, Settings)
  - Now includes link to Page Builder under Content section
  - Active link highlighted with brand color border
  - User info + sign out button at bottom
- Main content area (flex:1, light gray #f4f5f7 background)
  - Top bar with page title + primary action button
  - Content area with cards/tables

AUTH:
- Admin email stored as constant in config file
- Every admin page calls brRequireAdmin() which:
  1. Checks if user is logged in
  2. Checks if email matches admin email
  3. Redirects non-admin to home page
  4. Reveals the page (body starts as display:none)

PAGES NEEDED:
1. Dashboard — 4 stat cards + recent orders table + recent contacts table
2. Products — Full CRUD table, modal form with image upload + gallery + category + slug
3. Orders — Read-only table, status badge, view modal, status update, CSV export, pagination
4. Contacts — Table + reply feature (admin_reply column), CSV export
5. Hero Slider — CRUD with background type, badge JSON array, 2 CTA buttons, image upload
6. Page Sections — CRUD per page, checklist textarea→JSON, image upload, live preview
7. Media Library — Drag & drop upload grid, search, detail modal, copy URL
8. Site Settings — Tabbed interface: business info, branding (color pickers), social, SEO, code injection, maintenance mode, backups
9. Navigation Editor — Menu links CRUD + Page Creator + Block-based Page Builder
10. Analytics — Stat cards with time range filter

EVERY CRUD PAGE PATTERN:
- let allItems = [] (global state)
- loadItems() → SELECT from Supabase → renderItems()
- renderItems() → HTML table with action buttons
- openEditor(item?) → modal form (empty=create, filled=edit)
- saveItem() → INSERT or UPDATE based on hidden id field
- deleteItem(id) → confirm → DELETE
- filterItems() → client-side search on table rows
- showToast(msg, type) → bottom-right notification
- esc(string) → HTML escape for XSS prevention

CSS COMPONENTS:
- .btn, .btn-primary, .btn-secondary, .btn-danger, .btn-sm
- .stat-card with .stat-number and .stat-label
- .data-table with zebra striping
- .badge-new (blue), .badge-progress (orange), .badge-complete (green), .badge-closed (gray)
- .modal-overlay + .modal + .modal-header/body/footer
- .form-group with uppercase labels and pink focus ring
- .toast with success/error/info variants
- Responsive: sidebar collapses at 768px

DATABASE TABLES:
- orders, contacts, products, hero_slides, category_sections, page_content, site_settings, media, nav_items, custom_pages, page_blocks (11 total)

NAVIGATION SYSTEM (admin-navigation.html — 5 tabs):
- Tab 1: Navigation — CRUD for nav_items (label, href, parent, sort_order, target). Supports top-level + dropdown children.
- Tab 2: Pages — List of custom pages with status badges (draft/published), edit/delete.
- Tab 3: Page Builder — Block-based visual page editor:
  - 8 templates: blank, content, blog, product-showcase, gallery, landing, contact, faq
  - 11 block types: hero, text, image-text, products, gallery, faq, cta, form, html, spacer, section
  - Drag to reorder blocks, inline content editing, live preview
  - Product grid blocks auto-filter by page-{slug} category
- Tab 4: Custom Links — External links or anchors
- Tab 5: Redirects — URL redirect management

CUSTOM PAGES RENDERING (page.html):
- Reads slug from URL (?slug= or /p/{slug} via Vercel rewrite)
- Fetches custom_pages + page_blocks from Supabase
- Calls brRenderPageBlocks() to render blocks using existing CSS classes
- Auto-appends product grid if products with page-{slug} category exist but no products block is defined
- Draft preview mode with yellow banner

PRODUCT CATEGORIES:
- Admin product form shows categories in 2 optgroups:
  - "Site Pages": 8 static page categories (apparel, headgear, basicpoly, etc.) with .html filename shown
  - "Custom Pages": dynamically loaded from custom_pages table, uses page-{slug} as category value
- Products assigned to page-{slug} automatically appear on that custom page
- Custom category text input still available as fallback

RESPONSIVE NAVBAR:
- Navbar container uses max-width:none + width:100% + margin:0 to override .br-container's 1200px centering
- Logo at far left edge, nav items + actions at far right, padding: 0 40px
- Fixed font-size (0.82rem) and padding (8px 12px) for nav links
- Hamburger menu triggers at 1100px (raised from 768px to accommodate 8+ nav items)
- Intermediate breakpoint at 1200px for slightly reduced spacing
- Event delegation on .br-nav-links for mobile dropdown toggles (survives innerHTML replacement by dynamic nav)

RLS PATTERN:
- Public SELECT for content tables (products, slides, sections, settings, nav_items, published custom_pages/page_blocks)
- Admin (auth.email() = 'admin@email.com') for ALL operations
- Anon INSERT for orders and contacts (public forms)

Make each admin page completely self-contained. No shared JS files between admin pages.
Copy-paste the sidebar HTML into each page.
All Supabase queries go directly in the inline <script>.
```

---

## Summary

The entire admin panel is built on **one repeating pattern:**

1. **Guard** → `brRequireAdmin()` blocks non-admins
2. **Load** → `db.from('table').select('*')` gets data
3. **Render** → JS builds HTML strings from data arrays
4. **Modal** → Form for create/edit, toggled by CSS class
5. **Save** → `db.from('table').insert()` or `.update()`
6. **Delete** → Confirm → `db.from('table').delete()`
7. **Toast** → Notify user of success/error

That's it. Everything else is just variations of this pattern with different fields, different table names, and occasional extras like file upload, CSV export, or live preview.

**No backend. No API routes. No framework. Just HTML files talking directly to Supabase.**
