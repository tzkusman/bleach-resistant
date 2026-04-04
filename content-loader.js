/* ============================================================
 *  content-loader.js — Dynamic Content Loader
 *  Bleach Resistant / FinPrint Inc.
 *  ============================================================
 *  Loaded on ALL 20 public pages (after supabase-config.js).
 *  Fetches page_content overrides from Supabase and applies
 *  them to the DOM — images, text, HTML, backgrounds, styles.
 *  ============================================================ */

/* ============================================================
 *  MOBILE OPTIMISATION — Activate Wix device-mobile-optimized
 *  ============================================================
 *  Wix Thunderbolt pages ship with built-in mobile CSS under
 *  the class "device-mobile-optimized".  Wix JS normally adds
 *  this class at runtime; on static deployments we do it here.
 *  ============================================================ */
(function () {
  'use strict';

  var MOBILE_BREAKPOINT = 768;

  var mobileTargets = ['html', 'body', 'SITE_CONTAINER', 'masterPage'];

  function getTargets() {
    var els = [document.documentElement, document.body];
    mobileTargets.slice(2).forEach(function (id) {
      var el = document.getElementById(id);
      if (el) els.push(el);
    });
    return els;
  }

  function applyMobileClass(isMobile) {
    getTargets().forEach(function (el) {
      if (!el) return;
      if (isMobile) {
        el.classList.add('device-mobile-optimized');
      } else {
        el.classList.remove('device-mobile-optimized');
      }
    });
  }

  var mq = window.matchMedia('(max-width: ' + MOBILE_BREAKPOINT + 'px)');

  // Apply immediately (before DOMContentLoaded for fastest activation)
  applyMobileClass(mq.matches);

  // Re-apply once DOM is ready (catches late-added elements)
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      applyMobileClass(mq.matches);
    });
  }

  // Watch for viewport resize (e.g. orientation change, DevTools)
  try {
    mq.addEventListener('change', function (e) { applyMobileClass(e.matches); });
  } catch (e) {
    // Fallback for older Safari
    mq.addListener(function (e) { applyMobileClass(e.matches); });
  }
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
