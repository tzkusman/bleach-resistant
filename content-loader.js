/* ============================================================
 *  content-loader.js — Dynamic Content Loader
 *  Bleach Resistant / FinPrint Inc.
 *  ============================================================
 *  Loaded on ALL 20 public pages (after supabase-config.js).
 *  Fetches page_content overrides from Supabase and applies
 *  them to the DOM — images, text, HTML, backgrounds, styles.
 *  ============================================================ */

/* ============================================================
 *  MOBILE RESPONSIVENESS — Viewport Scaling + Hamburger Nav
 *  ============================================================
 *  Wix Thunderbolt exports use a fixed 980px pixel layout with
 *  absolute/relative positions.  Standard media-query CSS
 *  cannot reflow these pages.  Instead we:
 *    1. Scale #SITE_CONTAINER via CSS transform so the 980px
 *       design fits any viewport width (no horizontal scroll).
 *    2. Inject a fixed hamburger navigation overlay that gives
 *       proper touch-friendly navigation on mobile.
 *  All Wix links, forms, and functionality remain intact.
 *  ============================================================ */
(function () {
  'use strict';

  var DESIGN_WIDTH = 980;  // Wix desktop canvas width (px)
  var ADMIN_RE = /admin/i;  // skip scaling on admin pages
  var isAdmin = ADMIN_RE.test(window.location.pathname);

  /* ─── 1. VIEWPORT SCALING ───────────────────────────────── */
  function getScale() {
    return Math.min(1, window.innerWidth / DESIGN_WIDTH);
  }

  function applyScale() {
    if (isAdmin) return;
    var sc = document.getElementById('SITE_CONTAINER') ||
             document.getElementById('masterPage');
    if (!sc) return;

    var scale = getScale();
    if (scale < 1) {
      // Reset transform to measure true height
      sc.style.transform    = '';
      sc.style.marginBottom = '';
      var originH = sc.offsetHeight || sc.scrollHeight;

      sc.style.transformOrigin = 'top left';
      sc.style.transform       = 'scale(' + scale + ')';
      sc.style.width           = DESIGN_WIDTH + 'px';
      sc.style.minWidth        = DESIGN_WIDTH + 'px';

      // Collapse the extra space below the scaled element so the page
      // doesn't scroll past the visual content.
      // Without this, a 3000px tall container scaled to 0.4 still
      // occupies 3000px in the document flow instead of 1200px.
      var visualH = Math.ceil(originH * scale);
      sc.style.marginBottom = '-' + Math.ceil(originH - visualH) + 'px';

      document.body.style.overflowX = 'hidden';
    } else {
      sc.style.transform       = '';
      sc.style.transformOrigin = '';
      sc.style.width           = '';
      sc.style.minWidth        = '';
      sc.style.marginBottom    = '';
      document.body.style.overflowX = '';
    }
  }

  /* ─── 2. HAMBURGER NAVIGATION OVERLAY ───────────────────── */
  var NAV_LINKS = [
    { href: 'home.html',                   label: 'HOME' },
    { href: 'product.html',                label: 'PRODUCTS',  children: [
        { href: 'Pricelist.html',          label: 'Pricelist' },
        { href: 'headgear.html',           label: 'Head Gear' },
        { href: 'basicpoly.html',          label: 'Basics' },
        { href: 'stockdesigns.html',       label: 'Stock Designs' },
        { href: 'fabricdescriptions.html', label: 'Fabric Descriptions' },
        { href: 'sublimationprinting.html',label: 'Sublimation Printing' }
    ]},
    { href: 'services.html',               label: 'SERVICES',  children: [
        { href: 'grapicdesign.html',       label: 'Logos & Graphic Design' },
        { href: 'customlogos.html',        label: 'Logo Showcase' }
    ]},
    { href: 'copyofwashingsamples.html',   label: 'SHOWCASE' },
    { href: 'order.html',                  label: 'ORDER' },
    { href: 'sizechart.html',              label: 'SIZE CHART' },
    { href: 'About.html',                  label: 'ABOUT' },
    { href: 'FAQs.html',                   label: 'FAQs' },
    { href: 'login.html',                  label: 'LOGIN' },
    { href: 'signup.html',                 label: 'SIGN UP' }
  ];

  function buildHamburgerNav() {
    if (document.getElementById('br-mnav')) return;
    if (isAdmin) return;

    // Build menu HTML
    var linksHtml = NAV_LINKS.map(function (item) {
      var sub = '';
      if (item.children && item.children.length) {
        sub = '<ul class="br-msubnav">' +
          item.children.map(function (c) {
            return '<li><a href="' + c.href + '">' + c.label + '</a></li>';
          }).join('') +
          '</ul>';
      }
      return '<li class="' + (item.children ? 'br-has-sub' : '') + '">' +
             '<a href="' + item.href + '">' + item.label + '</a>' +
             sub + '</li>';
    }).join('');

    var nav = document.createElement('div');
    nav.id = 'br-mnav';
    nav.setAttribute('role', 'navigation');
    nav.setAttribute('aria-label', 'Mobile navigation');
    nav.innerHTML =
      '<button id="br-mtoggle" aria-label="Open menu" aria-expanded="false">' +
        '<span></span><span></span><span></span>' +
      '</button>' +
      '<div id="br-moverlay" aria-hidden="true">' +
        '<button id="br-mclose" aria-label="Close menu">&times;</button>' +
        '<ul>' + linksHtml + '</ul>' +
      '</div>';
    document.body.appendChild(nav);

    var toggle  = document.getElementById('br-mtoggle');
    var overlay = document.getElementById('br-moverlay');
    var close   = document.getElementById('br-mclose');

    function openMenu() {
      overlay.setAttribute('aria-hidden', 'false');
      overlay.classList.add('br-open');
      toggle.setAttribute('aria-expanded', 'true');
      document.body.style.overflow = 'hidden';
    }
    function closeMenu() {
      overlay.setAttribute('aria-hidden', 'true');
      overlay.classList.remove('br-open');
      toggle.setAttribute('aria-expanded', 'false');
      document.body.style.overflow = '';
    }

    toggle.addEventListener('click', openMenu);
    close.addEventListener('click', closeMenu);

    // Accordion for sub-menus
    overlay.querySelectorAll('.br-has-sub > a').forEach(function (a) {
      a.addEventListener('click', function (e) {
        e.preventDefault();
        var li = a.parentNode;
        li.classList.toggle('br-sub-open');
      });
    });

    // Swipe-to-close
    var touchStartX = 0;
    overlay.addEventListener('touchstart', function (e) {
      touchStartX = e.touches[0].clientX;
    }, { passive: true });
    overlay.addEventListener('touchend', function (e) {
      if (e.changedTouches[0].clientX - touchStartX > 60) closeMenu();
    }, { passive: true });

    // Show only on mobile
    updateNavVisibility();
  }

  function updateNavVisibility() {
    var nav = document.getElementById('br-mnav');
    if (!nav) return;
    var scale = getScale();
    nav.style.display = scale < 1 ? 'block' : 'none';
  }

  /* ─── 3. INIT & EVENT LISTENERS ─────────────────────────── */
  function init() {
    applyScale();
    buildHamburgerNav();
    // Re-apply after Wix JS has had time to paint additional content
    setTimeout(function () { applyScale(); updateNavVisibility(); }, 600);
    setTimeout(function () { applyScale(); }, 1500);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // Re-apply on window load (all images/fonts loaded — final heights)
  window.addEventListener('load', function () {
    applyScale();
    updateNavVisibility();
  });

  window.addEventListener('resize', function () {
    applyScale();
    updateNavVisibility();
  });

  window.addEventListener('orientationchange', function () {
    setTimeout(function () { applyScale(); updateNavVisibility(); }, 300);
  });
})();

(function() {
  'use strict';

  // Determine current page filename
  var path = window.location.pathname;
  var pageName = path.substring(path.lastIndexOf('/') + 1) || 'home.html';

  // Wait for DOM
  function onReady(fn) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', fn);
    } else {
      fn();
    }
  }

  onReady(function() {
    // Only load if Supabase client exists
    if (typeof db === 'undefined') return;

    loadPageOverrides(pageName);
  });

  async function loadPageOverrides(page) {
    try {
      var result = await db
        .from('page_content')
        .select('element_selector, content_type, content_value')
        .eq('page_name', page);

      if (result.error) {
        console.warn('[content-loader] Error fetching overrides:', result.error.message);
        return;
      }

      var items = result.data || [];
      if (items.length === 0) return;

      items.forEach(function(item) {
        applyOverride(item.element_selector, item.content_type, item.content_value);
      });

    } catch (err) {
      console.warn('[content-loader] Failed to load overrides:', err.message);
    }
  }

  function applyOverride(selector, type, value) {
    try {
      var elements = document.querySelectorAll(selector);
      if (elements.length === 0) {
        console.warn('[content-loader] No elements found for selector:', selector);
        return;
      }

      elements.forEach(function(el) {
        switch (type) {
          case 'image':
            // If it's an <img>, set src. If it's a <wix-image>, find the img inside.
            if (el.tagName === 'IMG') {
              el.src = value;
              el.srcset = '';
              el.removeAttribute('fetchpriority');
            } else {
              var img = el.querySelector('img');
              if (img) {
                img.src = value;
                img.srcset = '';
              } else {
                el.style.backgroundImage = 'url(' + value + ')';
              }
            }
            break;

          case 'text':
            el.textContent = value;
            break;

          case 'html':
            el.innerHTML = value;
            break;

          case 'background':
            el.style.backgroundImage = 'url(' + value + ')';
            el.style.backgroundSize = 'cover';
            el.style.backgroundPosition = 'center';
            break;

          case 'style':
            el.style.cssText += ';' + value;
            break;

          case 'attribute':
            // value format: "attrName=attrValue"
            var eq = value.indexOf('=');
            if (eq > 0) {
              el.setAttribute(value.substring(0, eq), value.substring(eq + 1));
            }
            break;

          case 'href':
            el.href = value;
            break;

          case 'hide':
            el.style.display = 'none';
            break;

          case 'show':
            el.style.display = value || 'block';
            break;

          default:
            el.textContent = value;
        }
      });
    } catch (e) {
      console.warn('[content-loader] Error applying override:', selector, e.message);
    }
  }

})();
