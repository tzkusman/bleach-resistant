/* ============================================================
 *  content-loader.js — Dynamic Content Loader
 *  Bleach Resistant / FinPrint Inc.
 *  ============================================================
 *  Loaded on ALL 20 public pages (after supabase-config.js).
 *  Fetches page_content overrides from Supabase and applies
 *  them to the DOM — images, text, HTML, backgrounds, styles.
 *  ============================================================ */

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
