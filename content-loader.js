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

    // Mobile dropdown toggles
    document.querySelectorAll('.br-dropdown > a').forEach(function(link) {
      link.addEventListener('click', function(e) {
        if (window.innerWidth <= 768) {
          e.preventDefault();
          var parent = link.parentElement;
          // Close others
          document.querySelectorAll('.br-dropdown.open').forEach(function(d) {
            if (d !== parent) d.classList.remove('open');
          });
          parent.classList.toggle('open');
        }
      });
    });
  }

  // Active nav link
  var currentPage = window.location.pathname.split('/').pop() || 'home.html';
  document.querySelectorAll('.br-nav-links a').forEach(function(a) {
    var href = a.getAttribute('href');
    if (href === currentPage) a.classList.add('active');
  });

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

  /* ── HERO SLIDER ─────────────────────────────────────────── */
  var heroSlides = document.querySelectorAll('.br-hero-slide');
  var heroDots = document.querySelectorAll('.br-hero-dot');
  var currentSlide = 0;
  var slideTimer;

  function goToSlide(index) {
    heroSlides.forEach(function(s) { s.classList.remove('active'); });
    heroDots.forEach(function(d) { d.classList.remove('active'); });
    currentSlide = ((index % heroSlides.length) + heroSlides.length) % heroSlides.length;
    if (heroSlides[currentSlide]) heroSlides[currentSlide].classList.add('active');
    if (heroDots[currentSlide]) heroDots[currentSlide].classList.add('active');
  }

  if (heroSlides.length > 1) {
    slideTimer = setInterval(function() { goToSlide(currentSlide + 1); }, 6000);

    heroDots.forEach(function(dot, i) {
      dot.addEventListener('click', function() {
        goToSlide(i);
        clearInterval(slideTimer);
        slideTimer = setInterval(function() { goToSlide(currentSlide + 1); }, 6000);
      });
    });

    var prevArrow = document.querySelector('.br-hero-prev');
    var nextArrow = document.querySelector('.br-hero-next');
    function resetTimer() {
      clearInterval(slideTimer);
      slideTimer = setInterval(function() { goToSlide(currentSlide + 1); }, 6000);
    }
    if (prevArrow) prevArrow.addEventListener('click', function() { goToSlide(currentSlide - 1); resetTimer(); });
    if (nextArrow) nextArrow.addEventListener('click', function() { goToSlide(currentSlide + 1); resetTimer(); });

    // Swipe
    var touchX = 0;
    var heroEl = document.querySelector('.br-hero');
    if (heroEl) {
      heroEl.addEventListener('touchstart', function(e) { touchX = e.touches[0].clientX; }, { passive: true });
      heroEl.addEventListener('touchend', function(e) {
        var diff = e.changedTouches[0].clientX - touchX;
        if (Math.abs(diff) > 50) { diff > 0 ? goToSlide(currentSlide - 1) : goToSlide(currentSlide + 1); resetTimer(); }
      }, { passive: true });
    }
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
        return '<div class="br-product-card" data-category="' + esc(p.category) + '" data-animate="fade-up">' +
          '<div class="br-product-image">' + imgHtml +
            '<div class="br-product-overlay"><a href="order.html?product=' + encodeURIComponent(p.slug || p.id) + '" class="br-btn br-btn-primary br-btn-sm">Get Quote</a></div>' +
            (p.featured ? '<span class="br-product-badge">Featured</span>' : '') +
          '</div>' +
          '<div class="br-product-info">' +
            '<span class="br-product-category">' + esc(p.category).replace(/-/g, ' ') + '</span>' +
            '<h3 class="br-product-title">' + esc(p.name) + '</h3>' +
            (p.short_description ? '<p class="br-product-desc">' + esc(p.short_description) + '</p>' : '') +
            '<div class="br-product-footer">' +
              (p.price_from ? '<span class="br-product-price">From $' + parseFloat(p.price_from).toFixed(0) + '</span>' : '<span class="br-product-price">Get Quote</span>') +
              '<a href="order.html?product=' + encodeURIComponent(p.slug || p.id) + '" class="br-product-link">Order &#8594;</a>' +
            '</div>' +
          '</div></div>';
      }).join('');

      // Re-observe for animations
      container.querySelectorAll('[data-animate]').forEach(function(el) { animObserver.observe(el); });
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

})();
