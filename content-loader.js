/* ============================================================
   content-loader.js — Bleach Resistant
   Dynamic functionality: nav, slider, animations, products
   Complete rebuild April 2026
   ============================================================ */
(function() {
  'use strict';

  /* ── NAVBAR SCROLL EFFECT ────────────────────────────────── */
  var navbar = document.getElementById('navbar');
  function updateNav() {
    if (navbar) navbar.classList.toggle('scrolled', window.scrollY > 50);
  }
  window.addEventListener('scroll', updateNav, { passive: true });
  updateNav();

  /* ── MOBILE NAV TOGGLE ───────────────────────────────────── */
  var navToggle = document.getElementById('navToggle');
  var navMenu = document.getElementById('navMenu');

  if (navToggle && navMenu) {
    var overlay = document.createElement('div');
    overlay.className = 'br-nav-overlay';
    document.body.appendChild(overlay);

    function openNav() {
      navMenu.classList.add('open');
      overlay.classList.add('active');
      navToggle.classList.add('active');
      navToggle.setAttribute('aria-expanded', 'true');
      document.body.style.overflow = 'hidden';
    }
    function closeNav() {
      navMenu.classList.remove('open');
      overlay.classList.remove('active');
      navToggle.classList.remove('active');
      navToggle.setAttribute('aria-expanded', 'false');
      document.body.style.overflow = '';
    }
    navToggle.addEventListener('click', function() {
      navMenu.classList.contains('open') ? closeNav() : openNav();
    });
    overlay.addEventListener('click', closeNav);

    // Mobile dropdown toggles — use event delegation so it works even after
    // brLoadDynamicNav() replaces the nav HTML
    var navLinksEl = document.querySelector('.br-nav-links');
    if (navLinksEl) {
      navLinksEl.addEventListener('click', function(e) {
        if (window.innerWidth > 768) return;
        var link = e.target.closest('.br-dropdown > a');
        if (!link) return;
        e.preventDefault();
        var parent = link.parentElement;
        navLinksEl.querySelectorAll('.br-dropdown.open').forEach(function(d) {
          if (d !== parent) d.classList.remove('open');
        });
        parent.classList.toggle('open');
      });
    }
  }

  // Active nav link
  var currentPage = window.location.pathname.split('/').pop() || 'home.html';
  document.querySelectorAll('.br-nav-links a').forEach(function(a) {
    var href = a.getAttribute('href');
    if (href === currentPage) a.classList.add('active');
  });

  /* ── AUTH-AWARE NAVBAR ───────────────────────────────────── */
  // Show "My Account" button for logged-in users on public pages
  if (typeof db !== 'undefined' && currentPage.indexOf('admin') !== 0 && currentPage !== 'login.html' && currentPage !== 'signup.html') {
    (async function() {
      try {
        var navActions = document.querySelector('.br-nav-actions');
        if (!navActions) return;
        var user = await brGetUser();
        if (!user) return;

        // Check if a My Account link already exists
        if (navActions.querySelector('.br-nav-account')) return;

        var accountBtn = document.createElement('a');
        accountBtn.href = brIsAdmin(user) ? 'admin.html' : 'account.html';
        accountBtn.className = 'br-btn br-btn-outline br-btn-sm br-nav-account';
        accountBtn.textContent = 'My Account';
        navActions.insertBefore(accountBtn, navActions.firstChild);
      } catch(e) {}
    })();
  }

  /* ── SCROLL ANIMATIONS (Intersection Observer) ───────────── */
  var animObserver = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        entry.target.classList.add('animated');
        animObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });

  document.querySelectorAll('[data-animate]').forEach(function(el) {
    animObserver.observe(el);
  });

  // Stagger children index
  document.querySelectorAll('[data-stagger]').forEach(function(parent) {
    Array.from(parent.children).forEach(function(child, i) {
      child.style.setProperty('--i', i);
    });
  });

  /* ── SLIDER INIT (reusable) ──────────────────────────────── */
  window.brInitSlider = function() {
    var hero = document.querySelector('.br-hero');
    if (!hero) return;
    var slides = hero.querySelectorAll('.br-hero-slide');
    var dots = hero.querySelectorAll('.br-hero-dot');
    if (slides.length <= 1) return;

    // Clear any existing timer
    if (window._brSlideTimer) clearInterval(window._brSlideTimer);
    var cur = 0;

    function go(i) {
      slides.forEach(function(s) { s.classList.remove('active'); });
      dots.forEach(function(d) { d.classList.remove('active'); });
      cur = ((i % slides.length) + slides.length) % slides.length;
      if (slides[cur]) slides[cur].classList.add('active');
      if (dots[cur]) dots[cur].classList.add('active');
    }

    function reset() { clearInterval(window._brSlideTimer); window._brSlideTimer = setInterval(function() { go(cur + 1); }, 6000); }
    reset();

    dots.forEach(function(d, i) { d.addEventListener('click', function() { go(i); reset(); }); });

    var prev = hero.querySelector('.br-hero-prev');
    var next = hero.querySelector('.br-hero-next');
    if (prev) prev.addEventListener('click', function() { go(cur - 1); reset(); });
    if (next) next.addEventListener('click', function() { go(cur + 1); reset(); });

    var tx = 0;
    hero.addEventListener('touchstart', function(e) { tx = e.touches[0].clientX; }, { passive: true });
    hero.addEventListener('touchend', function(e) {
      var d = e.changedTouches[0].clientX - tx;
      if (Math.abs(d) > 50) { d > 0 ? go(cur - 1) : go(cur + 1); reset(); }
    }, { passive: true });
  };

  /* ── HERO SLIDER (static init — may be overridden by brLoadHeroSlider on home) ── */
  var heroSlides = document.querySelectorAll('.br-hero-slide');
  if (heroSlides.length > 1) {
    brInitSlider();
  }

  /* ── FAQ ACCORDION ───────────────────────────────────────── */
  document.querySelectorAll('.br-faq-question').forEach(function(btn) {
    btn.addEventListener('click', function() {
      var item = btn.closest('.br-faq-item');
      var wasOpen = item.classList.contains('active');
      document.querySelectorAll('.br-faq-item.active').forEach(function(i) { i.classList.remove('active'); });
      if (!wasOpen) item.classList.add('active');
    });
  });

  /* ── GALLERY LIGHTBOX ────────────────────────────────────── */
  var lightbox = document.getElementById('lightbox');
  var lbImg = lightbox ? lightbox.querySelector('img') : null;
  var galleryImages = [];
  var lbIndex = 0;

  document.querySelectorAll('.br-gallery-item[data-src]').forEach(function(item, i) {
    galleryImages.push(item.getAttribute('data-src') || item.querySelector('img').src);
    item.addEventListener('click', function() {
      lbIndex = i;
      if (lbImg) lbImg.src = galleryImages[lbIndex];
      if (lightbox) { lightbox.classList.add('active'); document.body.style.overflow = 'hidden'; }
    });
  });

  if (lightbox) {
    var lbClose = lightbox.querySelector('.br-lightbox-close');
    var lbPrev = lightbox.querySelector('.br-lightbox-prev');
    var lbNext = lightbox.querySelector('.br-lightbox-next');

    function closeLB() { lightbox.classList.remove('active'); document.body.style.overflow = ''; }
    if (lbClose) lbClose.addEventListener('click', closeLB);
    lightbox.addEventListener('click', function(e) { if (e.target === lightbox) closeLB(); });

    function showLB(i) {
      lbIndex = ((i % galleryImages.length) + galleryImages.length) % galleryImages.length;
      if (lbImg) lbImg.src = galleryImages[lbIndex];
    }
    if (lbPrev) lbPrev.addEventListener('click', function(e) { e.stopPropagation(); showLB(lbIndex - 1); });
    if (lbNext) lbNext.addEventListener('click', function(e) { e.stopPropagation(); showLB(lbIndex + 1); });

    document.addEventListener('keydown', function(e) {
      if (!lightbox.classList.contains('active')) return;
      if (e.key === 'Escape') closeLB();
      if (e.key === 'ArrowLeft') showLB(lbIndex - 1);
      if (e.key === 'ArrowRight') showLB(lbIndex + 1);
    });
  }

  /* ── PRODUCT TABS / FILTER ───────────────────────────────── */
  document.querySelectorAll('.br-tabs').forEach(function(tabContainer) {
    tabContainer.querySelectorAll('.br-tab').forEach(function(tab) {
      tab.addEventListener('click', function() {
        tabContainer.querySelectorAll('.br-tab').forEach(function(t) { t.classList.remove('active'); });
        tab.classList.add('active');
        var filter = tab.getAttribute('data-filter');
        var targetId = tabContainer.getAttribute('data-target');
        var grid = document.getElementById(targetId);
        if (!grid) return;
        grid.querySelectorAll('.br-product-card').forEach(function(card) {
          if (!filter || filter === 'all') {
            card.style.display = '';
          } else {
            card.style.display = card.getAttribute('data-category') === filter ? '' : 'none';
          }
        });
      });
    });
  });

  /* ── PRODUCT LOADING FROM SUPABASE ───────────────────────── */
  window.brLoadProducts = async function(containerId, options) {
    options = options || {};
    var container = document.getElementById(containerId);
    if (!container || typeof db === 'undefined') return;

    container.innerHTML = '<div class="br-loading"><div class="br-spinner"></div><p>Loading products...</p></div>';

    try {
      var query = db.from('products').select('*').eq('active', true);
      if (options.category) query = query.eq('category', options.category);
      if (options.featured) query = query.eq('featured', true);
      if (options.limit) query = query.limit(options.limit);
      query = query.order('sort_order', { ascending: true });

      var result = await query;
      if (result.error) throw result.error;
      var data = result.data || [];

      if (data.length === 0) {
        container.innerHTML = '<div class="br-empty"><p>No products available yet. Check back soon!</p></div>';
        return data;
      }

      container.innerHTML = data.map(function(p) {
        var esc = typeof brEscapeHtml === 'function' ? brEscapeHtml : function(s) { return s || ''; };
        var imgHtml = p.image_url
          ? '<img src="' + p.image_url + '" alt="' + esc(p.name) + '" loading="lazy">'
          : '<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:var(--br-bg-alt);color:var(--br-text-muted);font-size:0.85rem">No Image</div>';
        var detailUrl = 'product-detail.html?slug=' + encodeURIComponent(p.slug || p.id);
        return '<div class="br-product-card" data-category="' + esc(p.category) + '" data-animate="fade-up">' +
          '<a href="' + detailUrl + '" class="br-product-card-link">' +
          '<div class="br-product-image">' + imgHtml +
            '<div class="br-product-overlay"><span class="br-btn br-btn-primary br-btn-sm">View Details</span></div>' +
            (p.featured ? '<span class="br-product-badge">Featured</span>' : '') +
          '</div>' +
          '<div class="br-product-info">' +
            '<span class="br-product-category">' + esc(p.category).replace(/-/g, ' ') + '</span>' +
            '<h3 class="br-product-title">' + esc(p.name) + '</h3>' +
            (p.short_description ? '<p class="br-product-desc">' + esc(p.short_description) + '</p>' : '') +
            '<div class="br-product-footer">' +
              (p.price_from ? '<span class="br-product-price">From $' + parseFloat(p.price_from).toFixed(0) + '</span>' : '<span class="br-product-price">Get Quote</span>') +
              '<span class="br-product-link">View Details &#8594;</span>' +
            '</div>' +
          '</div></a></div>';
      }).join('');

      // Re-observe for animations
      container.querySelectorAll('[data-animate]').forEach(function(el) { animObserver.observe(el); });

      // Build dynamic category tabs from actual product data
      var tabContainer = document.getElementById('productTabs');
      if (tabContainer && !tabContainer.hasChildNodes()) {
        var cats = [];
        data.forEach(function(p) {
          if (p.category && cats.indexOf(p.category) === -1) cats.push(p.category);
        });
        var allBtn = document.createElement('button');
        allBtn.className = 'br-tab active';
        allBtn.setAttribute('data-filter', 'all');
        allBtn.textContent = 'All';
        tabContainer.appendChild(allBtn);
        cats.forEach(function(cat) {
          var btn = document.createElement('button');
          btn.className = 'br-tab';
          btn.setAttribute('data-filter', cat);
          btn.textContent = cat.replace(/[-_]/g, ' ').replace(/\b\w/g, function(c) { return c.toUpperCase(); });
          tabContainer.appendChild(btn);
        });
        // Attach filter listeners
        tabContainer.querySelectorAll('.br-tab').forEach(function(tab) {
          tab.addEventListener('click', function() {
            tabContainer.querySelectorAll('.br-tab').forEach(function(t) { t.classList.remove('active'); });
            tab.classList.add('active');
            var filter = tab.getAttribute('data-filter');
            container.querySelectorAll('.br-product-card').forEach(function(card) {
              card.style.display = (!filter || filter === 'all') ? '' : (card.getAttribute('data-category') === filter ? '' : 'none');
            });
          });
        });
      }

      return data;
    } catch (err) {
      console.warn('[products]', err.message);
      container.innerHTML = '<div class="br-empty"><p>Unable to load products at this time.</p></div>';
      return [];
    }
  };

  /* ── SUPABASE CONTENT OVERRIDES ──────────────────────────── */
  if (typeof db !== 'undefined') {
    (async function() {
      try {
        var r = await db.from('page_content')
          .select('element_selector, content_type, content_value')
          .eq('page_name', currentPage);
        if (r.error || !r.data) return;
        r.data.forEach(function(item) {
          document.querySelectorAll(item.element_selector).forEach(function(el) {
            switch (item.content_type) {
              case 'text': el.textContent = item.content_value; break;
              case 'html': el.innerHTML = item.content_value; break;
              case 'image': if (el.tagName === 'IMG') el.src = item.content_value; else { var img = el.querySelector('img'); if (img) img.src = item.content_value; } break;
              case 'background': el.style.backgroundImage = 'url(' + item.content_value + ')'; break;
              case 'style': el.style.cssText += ';' + item.content_value; break;
              case 'href': el.href = item.content_value; break;
              case 'hide': el.style.display = 'none'; break;
              case 'show': el.style.display = ''; break;
            }
          });
        });
      } catch(e) { console.warn('[content-loader]', e.message); }
    })();
  }

  /* ── DYNAMIC CATEGORY SECTION LOADER ──────────────────────── */
  window.brLoadCategorySection = async function() {
    if (typeof db === 'undefined') return;

    try {
      var page = window.location.pathname.split('/').pop() || '';
      var result = await db.from('category_sections').select('*')
        .eq('page_name', page).eq('active', true);
      if (result.error) throw result.error;
      var sections = result.data || [];
      if (sections.length === 0) return; // keep static content as fallback

      // Sort by sort_order if available
      sections.sort(function(a, b) { return (a.sort_order || 0) - (b.sort_order || 0); });

      var esc = function(str) { var d = document.createElement('div'); d.textContent = str || ''; return d.innerHTML; };

      // Hide ALL existing static sections between .br-page-header and .br-cta-banner / footer
      // because we're replacing them with DB-driven content
      var pageHeader = document.querySelector('.br-page-header');
      if (pageHeader) {
        var sibling = pageHeader.nextElementSibling;
        while (sibling) {
          var tag = sibling.tagName.toLowerCase();
          var cls = sibling.className || '';
          // Stop before CTA banner, footer, or script
          if (cls.indexOf('br-cta-banner') >= 0 || tag === 'footer' || tag === 'script') break;
          // Don't hide sections that contain products grids
          if (!sibling.querySelector('.br-products-grid')) {
            sibling.style.display = 'none';
          }
          sibling = sibling.nextElementSibling;
        }
      }

      // Build and insert each DB section
      var insertBefore = pageHeader ? pageHeader.nextElementSibling : null;
      // Find the first still-visible element after hidden ones (the CTA or footer)
      while (insertBefore && insertBefore.style.display === 'none') {
        insertBefore = insertBefore.nextElementSibling;
      }

      sections.forEach(function(s, idx) {
        var items = [];
        try { items = typeof s.checklist === 'string' ? JSON.parse(s.checklist) : (s.checklist || []); } catch(e) {}

        var checklistHtml = '';
        if (items.length) {
          checklistHtml = '<ul class="br-checklist">' + items.map(function(item) { return '<li>' + esc(item) + '</li>'; }).join('') + '</ul>';
        }

        var btnHtml = '';
        if (s.btn1_text || s.btn2_text) {
          btnHtml = '<div class="br-btn-group" style="margin-top:24px">';
          if (s.btn1_text) btnHtml += '<a href="' + esc(s.btn1_link || '#') + '" class="br-btn br-btn-primary">' + esc(s.btn1_text) + '</a>';
          if (s.btn2_text) btnHtml += '<a href="' + esc(s.btn2_link || '#') + '" class="br-btn br-btn-outline br-btn-sm">' + esc(s.btn2_text) + '</a>';
          btnHtml += '</div>';
        }

        var imageHtml = '';
        if (s.image_url) {
          imageHtml = '<div class="br-category-image"><img src="' + esc(s.image_url) + '" alt="' + esc(s.section_label || s.heading || '') + '"></div>';
        }

        var descHtml = s.description ? '<p>' + esc(s.description) + '</p>' : '';
        var labelHtml = s.section_label ? '<span class="br-section-label">' + esc(s.section_label) + '</span>' : '';
        var headingHtml = s.heading ? '<h2>' + esc(s.heading) + '</h2>' : '';

        var wrapper = document.createElement('section');
        wrapper.className = idx % 2 === 0 ? 'br-section' : 'br-section-alt';
        wrapper.innerHTML =
          '<div class="br-container">' +
            '<div class="br-category-hero">' +
              '<div>' + labelHtml + headingHtml + descHtml + checklistHtml + btnHtml + '</div>' +
              imageHtml +
            '</div>' +
          '</div>';

        // Insert before the CTA banner / footer
        if (insertBefore && insertBefore.parentNode) {
          insertBefore.parentNode.insertBefore(wrapper, insertBefore);
        } else if (pageHeader && pageHeader.parentNode) {
          pageHeader.parentNode.appendChild(wrapper);
        }

        // Animate children that have data-animate (none by default, so section is immediately visible)
        wrapper.querySelectorAll('[data-animate]').forEach(function(el) {
          if (typeof animObserver !== 'undefined') animObserver.observe(el);
        });
      });
    } catch (err) {
      console.warn('[category-section]', err.message);
    }
  };

  /* ── DYNAMIC HERO SLIDER LOADER ──────────────────────────── */
  window.brLoadHeroSlider = async function() {
    var hero = document.querySelector('.br-hero');
    if (!hero || typeof db === 'undefined') return;

    try {
      var result = await db.from('hero_slides').select('*')
        .eq('active', true).order('sort_order', { ascending: true });
      if (result.error) throw result.error;
      var slides = result.data || [];
      if (slides.length === 0) {
        slides = [{
          title: 'Custom Sublimation', highlight: "The Way You'd Love",
          subtitle: 'Premium dye sublimation printing for teams, businesses, and individuals. 100% polyester, chemical-resistant fabric with vibrant, lasting prints.',
          badges: ['⚡ 24h Response', '📍 Guelph, Ontario', '🌎 Canada & International'],
          bg_type: 'gradient', bg_value: 'linear-gradient(135deg,#1a1a2e 0%,#16213e 50%,#0f3460 100%)',
          btn1_text: 'Order Today', btn1_link: 'order.html', btn1_style: 'primary',
          btn2_text: 'View Products', btn2_link: 'product.html', btn2_style: 'white',
          image_url: null
        }];
      }

      var esc = function(s) { var d = document.createElement('div'); d.textContent = s || ''; return d.innerHTML; };

      // Remove existing slides, arrows, dots
      hero.querySelectorAll('.br-hero-slide, .br-hero-arrows, .br-hero-dots').forEach(function(el) { el.remove(); });

      // Build slides
      slides.forEach(function(s, i) {
        var div = document.createElement('div');
        div.className = 'br-hero-slide' + (i === 0 ? ' active' : '');

        var bgStyle = '';
        if (s.bg_type === 'image' && s.bg_value) {
          bgStyle = 'background-image:url(' + s.bg_value + ');background-size:cover;background-position:center;';
        } else if (s.bg_value) {
          bgStyle = 'background:' + s.bg_value + ';';
        } else {
          bgStyle = 'background:linear-gradient(135deg,#1a1a2e 0%,#16213e 50%,#0f3460 100%);';
        }

        var badges = '';
        try {
          var badgeArr = typeof s.badges === 'string' ? JSON.parse(s.badges) : (s.badges || []);
          if (badgeArr.length) {
            badges = '<div class="br-hero-badges">' + badgeArr.map(function(b) {
              return '<span class="br-hero-badge">' + esc(b) + '</span>';
            }).join('') + '</div>';
          }
        } catch(e) {}

        var title = esc(s.title || '');
        if (s.highlight) title += ' <span>' + esc(s.highlight) + '</span>';

        var btns = '';
        if (s.btn1_text) {
          btns += '<a href="' + esc(s.btn1_link || '#') + '" class="br-btn br-btn-' + (s.btn1_style || 'primary') + ' br-btn-lg">' + esc(s.btn1_text) + '</a>';
        }
        if (s.btn2_text) {
          btns += '<a href="' + esc(s.btn2_link || '#') + '" class="br-btn br-btn-' + (s.btn2_style || 'white') + ' br-btn-lg">' + esc(s.btn2_text) + '</a>';
        }

        var imageHtml = '';
        if (s.image_url) {
          imageHtml = '<div class="br-hero-image"><img src="' + esc(s.image_url) + '" alt="' + esc(s.title || '') + '" loading="lazy"></div>';
        }

        var innerWrapper = s.image_url ? 'br-hero-split' : '';
        div.innerHTML =
          '<div class="br-hero-slide-bg" style="' + bgStyle + '"></div>' +
          '<div class="br-container"><div class="' + (innerWrapper ? 'br-hero-split' : '') + '">' +
            '<div class="br-hero-content">' +
              badges +
              '<h1>' + title + '</h1>' +
              (s.subtitle ? '<p>' + esc(s.subtitle) + '</p>' : '') +
              (btns ? '<div class="br-btn-group">' + btns + '</div>' : '') +
            '</div>' +
            imageHtml +
          '</div></div>';

        hero.appendChild(div);
      });

      // Build arrows
      var arrowsDiv = document.createElement('div');
      arrowsDiv.className = 'br-hero-arrows';
      arrowsDiv.innerHTML = '<button class="br-hero-arrow br-hero-prev" aria-label="Previous slide"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 18l-6-6 6-6"/></svg></button>' +
        '<button class="br-hero-arrow br-hero-next" aria-label="Next slide"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18l6-6-6-6"/></svg></button>';
      hero.appendChild(arrowsDiv);

      // Build dots
      var dotsDiv = document.createElement('div');
      dotsDiv.className = 'br-hero-dots';
      slides.forEach(function(_, i) {
        var dot = document.createElement('button');
        dot.className = 'br-hero-dot' + (i === 0 ? ' active' : '');
        dot.setAttribute('aria-label', 'Slide ' + (i + 1));
        dotsDiv.appendChild(dot);
      });
      hero.appendChild(dotsDiv);

      // Reinitialize slider
      brInitSlider();
    } catch (err) {
      console.warn('[hero-slider]', err.message);
    }
  };

  /* ── CHAT WIDGET ─────────────────────────────────────────── */
  (function() {
    // Don't show on admin pages
    if (currentPage.indexOf('admin') === 0 || currentPage === 'login.html' || currentPage === 'signup.html') return;

    // Build chat widget HTML
    var chatWidget = document.createElement('div');
    chatWidget.id = 'br-chat-widget';
    chatWidget.innerHTML =
      '<button class="br-chat-bubble" id="br-chat-toggle" aria-label="Chat with us">' +
        '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="br-chat-icon-open"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>' +
        '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="br-chat-icon-close" style="display:none"><path d="M18 6L6 18M6 6l12 12"/></svg>' +
      '</button>' +
      '<div class="br-chat-panel" id="br-chat-panel">' +
        '<div class="br-chat-header">' +
          '<div class="br-chat-header-info">' +
            '<div class="br-chat-avatar">BR</div>' +
            '<div><strong>Bleach Resistant</strong><span class="br-chat-status">We typically reply within a few hours</span></div>' +
          '</div>' +
          '<button class="br-chat-close" id="br-chat-close">&times;</button>' +
        '</div>' +
        '<div class="br-chat-body" id="br-chat-body">' +
          '<div class="br-chat-message br-chat-msg-them">' +
            '<p>Hi there! &#128075; How can we help you today? Send us a message and we\'ll get back to you as soon as possible.</p>' +
          '</div>' +
        '</div>' +
        '<form class="br-chat-form" id="br-chat-form">' +
          '<div class="br-chat-fields" id="br-chat-fields">' +
            '<input type="text" id="br-chat-name" placeholder="Your name" required>' +
            '<input type="text" id="br-chat-email" placeholder="Your email" required>' +
          '</div>' +
          '<div class="br-chat-input-row">' +
            '<textarea id="br-chat-message" placeholder="Type your message..." rows="2" required></textarea>' +
            '<button type="submit" class="br-chat-send" id="br-chat-send" aria-label="Send message">' +
              '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/></svg>' +
            '</button>' +
          '</div>' +
        '</form>' +
      '</div>';

    document.body.appendChild(chatWidget);

    var nameInput = document.getElementById('br-chat-name');
    var emailInput = document.getElementById('br-chat-email');

    // Toggle
    var toggle = document.getElementById('br-chat-toggle');
    var panel = document.getElementById('br-chat-panel');
    var iconOpen = toggle.querySelector('.br-chat-icon-open');
    var iconClose = toggle.querySelector('.br-chat-icon-close');
    var isOpen = false;

    function toggleChat() {
      isOpen = !isOpen;
      panel.classList.toggle('open', isOpen);
      toggle.classList.toggle('open', isOpen);
      iconOpen.style.display = isOpen ? 'none' : 'block';
      iconClose.style.display = isOpen ? 'block' : 'none';
    }

    toggle.addEventListener('click', toggleChat);
    document.getElementById('br-chat-close').addEventListener('click', toggleChat);

    // Send message
    var form = document.getElementById('br-chat-form');
    var body = document.getElementById('br-chat-body');

    form.addEventListener('submit', async function(e) {
      e.preventDefault();
      var name = nameInput.value.trim();
      var email = emailInput.value.trim();
      var msg = document.getElementById('br-chat-message').value.trim();
      if (!name || !email || !msg) return;

      var sendBtn = document.getElementById('br-chat-send');
      sendBtn.disabled = true;

      // Show user message in chat
      var userMsg = document.createElement('div');
      userMsg.className = 'br-chat-message br-chat-msg-you';
      userMsg.innerHTML = '<p>' + msg.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\n/g, '<br>') + '</p>';
      body.appendChild(userMsg);
      body.scrollTop = body.scrollHeight;
      document.getElementById('br-chat-message').value = '';

      try {
        if (typeof db === 'undefined') throw new Error('Not connected');
        var chatPage = window.location.pathname.split('/').pop() || 'chat';
        var result = await db.from('contacts').insert({ name: name, email: email, message: msg, page_source: chatPage });
        console.log('[chat] insert result:', result);
        if (result.error) throw result.error;

        // Show confirmation
        var confirm = document.createElement('div');
        confirm.className = 'br-chat-message br-chat-msg-them';
        confirm.innerHTML = '<p>Thanks ' + name.replace(/</g, '&lt;') + '! &#9989; Message sent! We\'ll get back to you soon.</p>';
        body.appendChild(confirm);
        body.scrollTop = body.scrollHeight;

        // Reset form for next message
        nameInput.value = '';
        emailInput.value = '';
      } catch (err) {
        console.error('[chat] error:', err);
        var errMsg = document.createElement('div');
        errMsg.className = 'br-chat-message br-chat-msg-them br-chat-msg-error';
        errMsg.innerHTML = '<p>Could not send. Please email us at <a href="mailto:bleachresistant@gmail.com" style="color:var(--br-primary);text-decoration:underline;">bleachresistant@gmail.com</a></p>';
        body.appendChild(errMsg);
        body.scrollTop = body.scrollHeight;
      }

      sendBtn.disabled = false;
    });
  })();

  /* ── DYNAMIC NAVIGATION FROM DB ──────────────────────────── */
  // If nav_items exist in DB, replace the static .br-nav-links HTML
  window.brLoadDynamicNav = async function() {
    if (typeof db === 'undefined') return;
    try {
      var result = await db.from('nav_items').select('*').eq('active', true).eq('location', 'main').order('sort_order');
      if (result.error) throw result.error;
      var items = result.data || [];
      if (items.length === 0) return; // keep static HTML nav

      var navLinks = document.querySelector('.br-nav-links');
      if (!navLinks) return;

      var topLevel = items.filter(function(i) { return !i.parent_id; });
      var children = items.filter(function(i) { return i.parent_id; });
      topLevel.sort(function(a,b) { return (a.sort_order||0) - (b.sort_order||0); });

      var svgArrow = '<svg width="10" height="6" viewBox="0 0 10 6"><path d="M1 1l4 4 4-4" stroke="currentColor" stroke-width="1.5" fill="none"/></svg>';
      var html = '<li><a href="home.html">Home</a></li>';

      topLevel.forEach(function(item) {
        var kids = children.filter(function(c) { return c.parent_id === item.id; });
        kids.sort(function(a,b) { return (a.sort_order||0) - (b.sort_order||0); });
        var hrefAttr = ' href="' + item.href.replace(/"/g, '&quot;') + '"';
        var targetAttr = item.target === '_blank' ? ' target="_blank" rel="noopener"' : '';

        if (kids.length > 0) {
          html += '<li class="br-dropdown"><a' + hrefAttr + '>' + (item.label||'').replace(/</g,'&lt;') + ' ' + svgArrow + '</a><ul class="br-dropdown-menu">';
          kids.forEach(function(k) {
            var kt = k.target === '_blank' ? ' target="_blank" rel="noopener"' : '';
            html += '<li><a href="' + (k.href||'#').replace(/"/g,'&quot;') + '"' + kt + '>' + (k.label||'').replace(/</g,'&lt;') + '</a></li>';
          });
          html += '</ul></li>';
        } else {
          html += '<li><a' + hrefAttr + targetAttr + '>' + (item.label||'').replace(/</g,'&lt;') + '</a></li>';
        }
      });

      navLinks.innerHTML = html;

      // Re-set active link
      var cp = window.location.pathname.split('/').pop() || 'home.html';
      navLinks.querySelectorAll('a').forEach(function(a) {
        if (a.getAttribute('href') === cp) a.classList.add('active');
      });
      // Mobile dropdown toggles handled by event delegation (top of file)
    } catch(e) {
      console.warn('[dynamic-nav]', e.message);
    }
  };

  // Auto-invoke on non-admin public pages
  if (typeof db !== 'undefined' && currentPage.indexOf('admin') !== 0 && currentPage !== 'login.html' && currentPage !== 'signup.html') {
    window.brLoadDynamicNav();
  }

  /* ── RENDER PAGE BLOCKS (for custom pages) ───────────────── */
  // Renders an array of page_blocks into a container element
  window.brRenderPageBlocks = function(container, page, blocks) {
    if (!container) return;
    var html = '';

    blocks.forEach(function(block, idx) {
      var c = block.content || {};
      var alt = idx % 2 === 1 ? ' br-section-alt' : '';

      switch (block.block_type) {
        case 'hero':
          var bgStyle = '';
          if (c.bg_type === 'image' && c.bg_value) bgStyle = 'background:url(' + c.bg_value.replace(/"/g,'') + ') center/cover no-repeat';
          else if (c.bg_type === 'color') bgStyle = 'background:' + (c.bg_value || '#1a1a2e');
          else bgStyle = 'background:' + (c.bg_value || 'linear-gradient(135deg,#1a1a2e,#0f3460)');
          html += '<section class="br-hero" style="min-height:45vh;display:flex;align-items:center;' + bgStyle + '">' +
            '<div class="br-hero-slide active" style="position:relative">' +
            '<div class="br-container" style="position:relative;z-index:2;text-align:center;color:#fff;padding:60px 20px">';
          if (c.title) html += '<h1 style="font-size:clamp(2rem,5vw,3.5rem);font-weight:900;margin-bottom:16px">' + sanitize(c.title) + '</h1>';
          if (c.subtitle) html += '<p style="font-size:clamp(1rem,2vw,1.25rem);opacity:.9;max-width:700px;margin:0 auto 24px">' + sanitize(c.subtitle) + '</p>';
          if (c.btn1_text || c.btn2_text) {
            html += '<div class="br-btn-group" style="justify-content:center">';
            if (c.btn1_text) html += '<a href="' + esc(c.btn1_link||'#') + '" class="br-btn br-btn-primary br-btn-lg">' + sanitize(c.btn1_text) + '</a>';
            if (c.btn2_text) html += '<a href="' + esc(c.btn2_link||'#') + '" class="br-btn br-btn-outline br-btn-lg">' + sanitize(c.btn2_text) + '</a>';
            html += '</div>';
          }
          html += '</div></div></section>';
          break;

        case 'text':
          html += '<section class="br-section' + alt + '"><div class="br-container" style="max-width:800px;text-align:' + (c.align||'left') + '">';
          if (c.heading) html += '<h2 class="br-section-title">' + sanitize(c.heading) + '</h2>';
          if (c.body) html += '<div class="br-text-content" style="line-height:1.8;font-size:1.05rem">' + c.body + '</div>';
          html += '</div></section>';
          break;

        case 'image-text':
          var reversed = c.image_position === 'left';
          html += '<section class="br-section' + alt + '"><div class="br-container"><div class="br-category-hero"' + (reversed ? ' style="direction:rtl"' : '') + '><div' + (reversed ? ' style="direction:ltr"' : '') + '>';
          if (c.label) html += '<span class="br-label">' + sanitize(c.label) + '</span>';
          if (c.heading) html += '<h2>' + sanitize(c.heading) + '</h2>';
          if (c.description) html += '<p>' + sanitize(c.description) + '</p>';
          if (c.checklist && c.checklist.length > 0) {
            html += '<ul class="br-checklist">' + c.checklist.map(function(item) { return '<li>' + sanitize(item) + '</li>'; }).join('') + '</ul>';
          }
          if (c.btn_text) html += '<div class="br-btn-group"><a href="' + esc(c.btn_link||'#') + '" class="br-btn br-btn-primary">' + sanitize(c.btn_text) + '</a></div>';
          html += '</div>';
          if (c.image_url) html += '<div class="br-category-image"' + (reversed ? ' style="direction:ltr"' : '') + '><img src="' + esc(c.image_url) + '" alt="' + esc(c.heading||'') + '" loading="lazy"></div>';
          html += '</div></div></section>';
          break;

        case 'products':
          var gridId = 'pg-' + block.id.replace(/-/g,'').substring(0,8);
          html += '<section class="br-section' + alt + '"><div class="br-container">';
          if (c.heading) html += '<h2 class="br-section-title" style="text-align:center;margin-bottom:32px">' + sanitize(c.heading) + '</h2>';
          html += '<div class="br-products-grid" id="' + gridId + '"></div></div></section>';
          // Schedule product loading after render
          setTimeout(function() {
            if (typeof window.brLoadProducts === 'function') {
              window.brLoadProducts(gridId, { category: c.category, featured: c.featured_only, limit: c.limit || 12 });
            }
          }, 100);
          break;

        case 'gallery':
          var cols = c.columns || 3;
          var images = c.images || [];
          html += '<section class="br-section' + alt + '"><div class="br-container">';
          if (c.heading) html += '<h2 class="br-section-title" style="text-align:center;margin-bottom:32px">' + sanitize(c.heading) + '</h2>';
          html += '<div class="block-gallery block-gallery-' + cols + '">';
          images.forEach(function(img) {
            var url = typeof img === 'string' ? img : img.url;
            var caption = typeof img === 'string' ? '' : img.caption || '';
            html += '<div><img src="' + esc(url) + '" alt="' + esc(caption) + '" loading="lazy">';
            if (caption) html += '<p style="text-align:center;font-size:13px;color:#888;margin-top:8px">' + sanitize(caption) + '</p>';
            html += '</div>';
          });
          html += '</div></div></section>';
          break;

        case 'faq':
          var items = c.items || [];
          html += '<section class="br-section' + alt + '"><div class="br-container" style="max-width:800px">';
          if (c.heading) html += '<h2 class="br-section-title" style="text-align:center;margin-bottom:32px">' + sanitize(c.heading) + '</h2>';
          html += '<div class="br-faq-list">';
          items.forEach(function(item) {
            html += '<div class="br-faq-item"><button class="br-faq-question">' + sanitize(item.question) + '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg></button><div class="br-faq-answer"><p>' + sanitize(item.answer) + '</p></div></div>';
          });
          html += '</div></div></section>';
          break;

        case 'cta':
          html += '<section class="br-cta-banner" style="background:' + (c.bg_color || '#1a1a2e') + ';padding:60px 20px;text-align:center;color:#fff"><div class="br-container">';
          if (c.heading) html += '<h2 style="font-size:clamp(1.5rem,3vw,2.5rem);margin-bottom:12px">' + sanitize(c.heading) + '</h2>';
          if (c.subtitle) html += '<p style="font-size:1.1rem;opacity:.9;margin-bottom:24px">' + sanitize(c.subtitle) + '</p>';
          if (c.btn_text) html += '<a href="' + esc(c.btn_link||'#') + '" class="br-btn br-btn-primary br-btn-lg">' + sanitize(c.btn_text) + '</a>';
          html += '</div></section>';
          break;

        case 'form':
          html += '<section class="br-section' + alt + '"><div class="br-container" style="max-width:700px">';
          if (c.heading) html += '<h2 class="br-section-title" style="text-align:center;margin-bottom:8px">' + sanitize(c.heading) + '</h2>';
          if (c.subtitle) html += '<p style="text-align:center;color:#888;margin-bottom:32px">' + sanitize(c.subtitle) + '</p>';
          html += '<form class="block-contact-form" onsubmit="return brSubmitBlockForm(event,this)">' +
            '<div class="form-row"><label>Name</label><input type="text" name="name" required placeholder="Your name"></div>' +
            '<div class="form-row"><label>Email</label><input type="email" name="email" required placeholder="your@email.com"></div>' +
            '<div class="form-row"><label>Message</label><textarea name="message" rows="5" required placeholder="How can we help?"></textarea></div>' +
            '<button type="submit" class="br-btn br-btn-primary br-btn-lg" style="width:100%">Send Message</button>' +
            '</form>';
          html += '</div></section>';
          break;

        case 'html':
          html += '<section class="br-section' + alt + '"><div class="br-container">' + (c.code || '') + '</div></section>';
          break;

        case 'spacer':
          html += '<div style="height:' + (parseInt(c.height) || 60) + 'px"></div>';
          break;

        case 'section':
          var secId = 'cs-' + block.id.replace(/-/g,'').substring(0,8);
          html += '<div id="' + secId + '"></div>';
          if (c.section_label) {
            setTimeout(function() {
              if (typeof window.brLoadCategorySection === 'function') {
                window.brLoadCategorySection(secId, c.section_label);
              }
            }, 100);
          }
          break;

        default:
          html += '<section class="br-section"><div class="br-container"><p style="color:#888">[Unknown block: ' + sanitize(block.block_type) + ']</p></div></section>';
      }
    });

    container.innerHTML = html;

    // Bind FAQ accordion toggles
    container.querySelectorAll('.br-faq-question').forEach(function(btn) {
      btn.addEventListener('click', function() {
        var item = this.closest('.br-faq-item');
        var wasActive = item.classList.contains('active');
        container.querySelectorAll('.br-faq-item').forEach(function(i) { i.classList.remove('active'); });
        if (!wasActive) item.classList.add('active');
      });
    });

    // Trigger scroll animations
    container.querySelectorAll('[data-animate]').forEach(function(el) {
      if (typeof animObserver !== 'undefined') animObserver.observe(el);
    });

    function esc(s) { return s ? s.replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/</g,'&lt;').replace(/>/g,'&gt;') : ''; }
    function sanitize(s) { return s ? s.replace(/</g,'&lt;').replace(/>/g,'&gt;') : ''; }
  };

  // Contact form handler for block forms
  window.brSubmitBlockForm = async function(e, form) {
    e.preventDefault();
    var name = form.querySelector('[name="name"]').value.trim();
    var email = form.querySelector('[name="email"]').value.trim();
    var message = form.querySelector('[name="message"]').value.trim();
    if (!name || !email || !message) return false;
    try {
      var r = await db.from('contacts').insert({ name: name, email: email, message: message, page_source: window.location.pathname.split('/').pop() || 'custom-page' });
      if (r.error) throw r.error;
      form.innerHTML = '<div style="text-align:center;padding:40px"><h3 style="color:#8DC63F">&#9989; Message Sent!</h3><p style="color:#888;margin-top:8px">Thanks ' + name.replace(/</g,'&lt;') + '! We\'ll get back to you soon.</p></div>';
    } catch(err) {
      alert('Error sending message: ' + err.message);
    }
    return false;
  };

})();
