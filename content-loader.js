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
    var hero = document.querySelector('.br-category-hero');
    if (!hero || typeof db === 'undefined') return;

    try {
      var page = window.location.pathname.split('/').pop() || '';
      var result = await db.from('category_sections').select('*')
        .eq('page_name', page).eq('active', true).limit(1).maybeSingle();
      if (result.error) throw result.error;
      var s = result.data;
      if (!s) return; // keep static content as fallback

      var esc = function(str) { var d = document.createElement('div'); d.textContent = str || ''; return d.innerHTML; };

      // Update section label
      var labelEl = hero.querySelector('.br-section-label');
      if (labelEl && s.section_label) labelEl.textContent = s.section_label;

      // Update heading
      var h2 = hero.querySelector('h2');
      if (h2 && s.heading) h2.textContent = s.heading;

      // Update description
      var desc = hero.querySelector('h2 ~ p');
      if (desc && s.description) desc.textContent = s.description;

      // Update checklist
      if (s.checklist) {
        var items = typeof s.checklist === 'string' ? JSON.parse(s.checklist) : (s.checklist || []);
        var ul = hero.querySelector('.br-checklist');
        if (ul && items.length) {
          ul.innerHTML = items.map(function(item) { return '<li>' + esc(item) + '</li>'; }).join('');
        }
      }

      // Update image
      var imgDiv = hero.querySelector('.br-category-image');
      if (imgDiv && s.image_url) {
        imgDiv.style.cssText = '';
        imgDiv.innerHTML = '<img src="' + esc(s.image_url) + '" alt="' + esc(s.section_label || '') + '" style="width:100%;height:100%;object-fit:cover;border-radius:inherit;">';
      }

      // Update buttons
      var btnGroup = hero.querySelector('.br-btn-group');
      if (btnGroup) {
        var btns = btnGroup.querySelectorAll('a');
        if (s.btn1_text && btns[0]) {
          btns[0].textContent = s.btn1_text;
          if (s.btn1_link) btns[0].href = s.btn1_link;
        }
        if (s.btn2_text && btns[1]) {
          btns[1].textContent = s.btn2_text;
          if (s.btn2_link) btns[1].href = s.btn2_link;
        } else if (s.btn2_text && !btns[1] && btnGroup) {
          // Create second button if doesn't exist
          var newBtn = document.createElement('a');
          newBtn.href = s.btn2_link || '#';
          newBtn.className = 'br-btn br-btn-outline br-btn-sm';
          newBtn.textContent = s.btn2_text;
          btnGroup.appendChild(newBtn);
        }
      }
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
      if (slides.length === 0) return; // keep static slides as fallback

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

        div.innerHTML =
          '<div class="br-hero-slide-bg" style="' + bgStyle + '"></div>' +
          '<div class="br-container"><div class="br-hero-content">' +
            badges +
            '<h1>' + title + '</h1>' +
            (s.subtitle ? '<p>' + esc(s.subtitle) + '</p>' : '') +
            (btns ? '<div class="br-btn-group">' + btns + '</div>' : '') +
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
            '<input type="email" id="br-chat-email" placeholder="Your email" required>' +
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

    // Restore saved info
    var savedName = localStorage.getItem('br_chat_name') || '';
    var savedEmail = localStorage.getItem('br_chat_email') || '';
    var nameInput = document.getElementById('br-chat-name');
    var emailInput = document.getElementById('br-chat-email');
    if (savedName) nameInput.value = savedName;
    if (savedEmail) emailInput.value = savedEmail;
    if (savedName && savedEmail) {
      document.getElementById('br-chat-fields').style.display = 'none';
    }

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
        // Insert just the core fields
        var result = await db.from('contacts').insert({ name: name, email: email, message: msg });
        console.log('[chat] insert result:', result);
        if (result.error) throw result.error;

        // Save info
        localStorage.setItem('br_chat_name', name);
        localStorage.setItem('br_chat_email', email);
        document.getElementById('br-chat-fields').style.display = 'none';

        // Show confirmation
        var confirm = document.createElement('div');
        confirm.className = 'br-chat-message br-chat-msg-them';
        confirm.innerHTML = '<p>Thanks ' + name.replace(/</g, '&lt;') + '! &#9989; Message sent! We\'ll reply to <strong>' + email.replace(/</g, '&lt;') + '</strong> soon.</p>';
        body.appendChild(confirm);
        body.scrollTop = body.scrollHeight;
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

})();
