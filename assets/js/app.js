/* =====================================================================
   Gemini Dance – JS dùng chung cho mọi trang
   - Khởi tạo Supabase (window.sb)
   - Render header + footer chung (các trang liên kết với nhau)
   - Ghi lượt truy cập vào bảng page_views
   - Giỏ hàng (localStorage), helper định dạng, toast
   ===================================================================== */
(function () {
  const C = window.GD_CONFIG;
  const ROOT = document.body.dataset.root || "";
  window.GD_ROOT = ROOT;

  // ---------- Supabase ----------
  window.sb = (window.supabase && C.SUPABASE_KEY)
    ? window.supabase.createClient(C.SUPABASE_URL, C.SUPABASE_KEY)
    : null;

  // ---------- Helpers ----------
  window.esc = (s) => String(s ?? "").replace(/[&<>"']/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  window.vnd = (n) => (Number(n) || 0).toLocaleString("vi-VN") + "₫";
  window.fmtDate = (d) => new Date(d).toLocaleString("vi-VN", { dateStyle: "short", timeStyle: "short" });
  window.qs = (k) => new URLSearchParams(location.search).get(k);

  // ---------- Kiểm tra dữ liệu nhập ----------
  window.normPhone = (v) => String(v || "").replace(/[\s.\-()]/g, "").replace(/^\+?84/, "0");
  window.isPhone = (v) => /^0(3|5|7|8|9)\d{8}$/.test(normPhone(v));
  window.isEmail = (v) => /^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$/i.test(String(v || "").trim());
  window.MIN_AGE = 18;
  window.maxBirthYear = () => new Date().getFullYear() - MIN_AGE;
  window.yearOptions = (sel) => {
    let h = `<option value="">-- Chọn năm sinh --</option>`;
    for (let y = maxBirthYear(); y >= 1950; y--) h += `<option value="${y}" ${String(y) === String(sel) ? "selected" : ""}>${y}</option>`;
    return h;
  };
  // Gắn kiểm tra SĐT / email cho một form: báo lỗi ngay dưới ô khi rời ô và khi bấm gửi
  window.attachContactValidation = (form) => {
    const rules = [
      ["phone", (v) => isPhone(v) ? "" : "Số điện thoại cần 10 số, bắt đầu bằng 03, 05, 07, 08 hoặc 09 (VD: 0909 123 456)."],
      ["email", (v) => !v.trim() || isEmail(v) ? "" : "Email không đúng định dạng (VD: ten@gmail.com)."],
      ["birth_year", (v) => v ? "" : `Vui lòng chọn năm sinh. Gemini Dance nhận học viên từ ${MIN_AGE} tuổi (sinh năm ${maxBirthYear()} trở về trước).`]
    ];
    const check = (el, fn) => {
      const msg = fn(el.value);
      el.setCustomValidity(msg);
      let hint = el.parentElement.querySelector(".field-error");
      if (!hint) { hint = document.createElement("small"); hint.className = "field-error"; el.parentElement.appendChild(hint); }
      hint.textContent = msg;
      el.classList.toggle("invalid", !!msg);
      return !msg;
    };
    rules.forEach(([name, fn]) => { const el = form.elements[name]; if (el) { el.addEventListener("blur", () => check(el, fn)); el.addEventListener("change", () => check(el, fn)); el.addEventListener("input", () => { if (el.classList.contains("invalid")) check(el, fn); }); } });
    return () => rules.map(([name, fn]) => { const el = form.elements[name]; return !el || check(el, fn); }).every(Boolean);
  };

  window.toast = function (msg, type = "ok") {
    let box = document.getElementById("toast-box");
    if (!box) { box = document.createElement("div"); box.id = "toast-box"; document.body.appendChild(box); }
    const t = document.createElement("div");
    t.className = "toast toast-" + type;
    t.textContent = msg;
    box.appendChild(t);
    setTimeout(() => t.classList.add("hide"), 3200);
    setTimeout(() => t.remove(), 3700);
  };

  // ---------- Dữ liệu mẫu (khi chưa kết nối được Supabase) ----------
  window.FALLBACK = {
    courses: [
      { id: 1, slug: "beginner", name: "Beginner – Lớp Căn Bản", level: "beginner", schedule_days: "Chủ nhật", schedule_time: "12:00 – 14:00", duration_weeks: 8, fee: 1200000, max_students: 20,
        short_desc: "Dành cho người mới bắt đầu, chưa từng học nhảy.",
        description: "Lớp Beginner giúp bạn làm quen với nhịp điệu, isolation, cách kiểm soát cơ thể và thần thái trên sân khấu. Mỗi buổi gồm khởi động, kỹ thuật cơ bản và một đoạn choreography ngắn theo nhạc K-pop / Sexy Dance đang hot. Sau 8 tuần bạn sẽ tự tin quay video TikTok cùng lớp.",
        highlights: ["Khởi động & giãn cơ đúng cách", "Nhịp đếm, isolation, groove cơ bản", "Tư thế, thần thái, biểu cảm khuôn mặt", "1 bài choreography hoàn chỉnh mỗi 2 tuần", "Quay video cuối khoá đăng TikTok Gemini Dance"] },
      { id: 2, slug: "advanced", name: "Advanced – Lớp Nâng Cao", level: "advanced", schedule_days: "Thứ 7 & Chủ nhật", schedule_time: "14:00 – 15:00", duration_weeks: 8, fee: 1500000, max_students: 15,
        short_desc: "Dành cho bạn đã có nền tảng, muốn chinh phục Heels & Sexy Dance.",
        description: "Lớp Advanced tập trung vào kỹ thuật Heels, floor work, chuyển động liên hoàn và trình diễn theo nhóm. Học viên được luyện tập 2 buổi/tuần, dựng bài biểu diễn và tham gia quay MV, sự kiện của Gemini Dance.",
        highlights: ["Kỹ thuật Heels & floor work", "Choreography tốc độ cao, chuyển đội hình", "Freestyle & tạo dấu ấn cá nhân", "Dựng bài biểu diễn nhóm", "Ưu tiên tham gia show & MV của trung tâm"] }
    ],
    products: [
      [1, "Bodysuit Gemini Neon", "trang-phuc", 420000, null, ["S","M","L"], ["Đen","Tím neon"], "New", 30, "Bodysuit cut-out ôm dáng, thun lạnh 4 chiều co giãn, tôn đường cong khi biểu diễn."],
      [2, "Crop top lưới Starry", "trang-phuc", 220000, 179000, ["S","M","L"], ["Đen","Trắng"], "Sale", 40, "Crop top lưới phối dây, mặc ngoài sport bra cực cá tính."],
      [3, "Quần biker Twin", "trang-phuc", 260000, null, ["S","M","L","XL"], ["Đen","Hồng"], "Hot", 35, "Quần biker cạp cao, không lộ khi xoạc, thấm hút mồ hôi."],
      [4, "Legging ánh kim Galaxy", "trang-phuc", 350000, null, ["S","M","L"], ["Bạc","Tím"], "New", 20, "Legging phủ ánh kim lấp lánh dưới đèn sân khấu."],
      [5, "Sport bra Constellation", "trang-phuc", 240000, null, ["S","M","L"], ["Đen","Cyan"], null, 30, "Sport bra nâng đỡ tốt, dây đan chéo lưng."],
      [6, "Giày Heels Dance 9cm", "giay", 890000, 790000, ["35","36","37","38","39"], ["Đen","Nude"], "Sale", 15, "Giày heels đế da lộn chuyên nhảy, gót vững, có quai cổ chân."],
      [7, "Giày Jazz da mềm", "giay", 450000, null, ["35","36","37","38","39"], ["Đen","Be"], null, 20, "Giày jazz đế chia đôi, xoay trượt dễ dàng."],
      [8, "Sneaker nhảy Gemini", "giay", 990000, null, ["36","37","38","39"], ["Trắng","Đen"], "Hot", 18, "Sneaker đế xoay pivot, nhẹ, êm cho hip hop & K-pop."],
      [9, "Tất đùi Thigh-high", "phu-kien", 120000, null, ["Free size"], ["Đen"], "Hot", 60, "Tất đùi dày dặn, chống trượt, chuẩn outfit Sexy Dance."],
      [10, "Găng tay lưới Neon", "phu-kien", 90000, null, ["Free size"], ["Đen","Hồng"], null, 50, "Găng tay lưới hở ngón, điểm nhấn cho tiết mục."],
      [11, "Kneepad bảo vệ gối", "phu-kien", 180000, null, ["S","M"], ["Đen"], "New", 40, "Bảo vệ gối khi tập floor work, mỏng nhẹ mặc dưới legging."],
      [12, "Túi tập Gemini Duffle", "phu-kien", 390000, 329000, ["Free size"], ["Đen","Tím"], "Sale", 25, "Túi trống có ngăn giày riêng, in logo Gemini Dance phản quang."]
    ].map(([id, name, category, price, sale_price, sizes, colors, badge, stock, description]) =>
      ({ id, name, category, price, sale_price, sizes, colors, badge, stock, description, image_url: null, is_active: true }))
  };

  window.CATEGORY = { "trang-phuc": "Trang phục", "giay": "Giày nhảy", "phu-kien": "Phụ kiện" };

  // Lấy danh sách khoá học / sản phẩm, tự rơi về dữ liệu mẫu nếu DB lỗi
  window.getCourses = async function () {
    if (sb) {
      const { data, error } = await sb.from("courses").select("*").eq("is_active", true).order("id");
      if (!error && data && data.length) return data;
      console.warn("[Gemini] Dùng dữ liệu mẫu cho courses:", error && error.message);
    }
    return FALLBACK.courses;
  };
  window.getProducts = async function () {
    if (sb) {
      const { data, error } = await sb.from("products").select("*").eq("is_active", true).order("id");
      if (!error && data && data.length) return data;
      console.warn("[Gemini] Dùng dữ liệu mẫu cho products:", error && error.message);
    }
    return FALLBACK.products;
  };

  // ---------- Ảnh sản phẩm (nếu chưa có image_url thì vẽ minh hoạ SVG theo danh mục) ----------
  const ICONS = {
    "trang-phuc": '<path d="M70 30l-18 12 8 22 10-6v62h60V58l10 6 8-22-18-12c-4 10-16 16-30 16S74 40 70 30z"/>',
    "giay": '<path d="M28 118c26 0 50-8 70-26l26-26c10-10 26-8 32 6l10 24v24h-14l-4-12c-30 14-76 24-120 24z"/><path d="M150 120h10l-4 52h-6z"/>',
    "phu-kien": '<rect x="44" y="64" width="112" height="70" rx="16"/><path d="M76 64v-10c0-8 6-14 14-14h20c8 0 14 6 14 14v10" fill="none" stroke-width="10"/>'
  };
  const TINT = { "Đen": "#1b1830", "Trắng": "#3a3654", "Hồng": "#5a1f45", "Tím": "#3b2a6e", "Tím neon": "#3b2a6e", "Cyan": "#164a52", "Bạc": "#3c3f52", "Nude": "#4f3a35", "Be": "#4a4236" };
  window.productImage = function (p, cls = "") {
    if (p.image_url) return `<img class="${cls}" src="${esc(p.image_url)}" alt="${esc(p.name)}" loading="lazy">`;
    const tint = TINT[(p.colors || [])[0]] || "#2a2550";
    const id = "g" + p.id + Math.random().toString(36).slice(2, 6);
    return `<svg class="${cls}" viewBox="0 0 200 250" role="img" aria-label="${esc(p.name)}">
      <defs><linearGradient id="${id}" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#3ee6df"/><stop offset=".5" stop-color="#8a7cf0"/><stop offset="1" stop-color="#e8439a"/></linearGradient>
      <radialGradient id="${id}b" cx=".5" cy=".35" r=".8"><stop offset="0" stop-color="${tint}"/><stop offset="1" stop-color="#0b0a14"/></radialGradient></defs>
      <rect width="200" height="250" fill="url(#${id}b)"/>
      <g transform="translate(0,35)" fill="url(#${id})" stroke="url(#${id})">${ICONS[p.category] || ICONS["phu-kien"]}</g>
      <text x="100" y="228" text-anchor="middle" fill="#f3f0ff" opacity=".55" font-family="Poppins,sans-serif" font-size="11" letter-spacing="3">GEMINI SHOP</text></svg>`;
  };
  window.priceHtml = (p) => p.sale_price
    ? `<span class="price">${vnd(p.sale_price)}</span> <s class="price-old">${vnd(p.price)}</s>`
    : `<span class="price">${vnd(p.price)}</span>`;

  window.productCard = (p) => `
    <a class="product-card" href="${ROOT}product.html?id=${p.id}">
      ${p.badge ? `<span class="badge badge-${esc(p.badge)}">${esc(p.badge)}</span>` : ""}
      ${productImage(p, "thumb")}
      <div class="body">
        <span class="cat">${esc(CATEGORY[p.category] || p.category)}</span>
        <h3>${esc(p.name)}</h3>
        <div>${priceHtml(p)}</div>
      </div>
    </a>`;

  // ---------- Giỏ hàng (localStorage) ----------
  const CART_KEY = "gd_cart";
  window.Cart = {
    get() { try { return JSON.parse(localStorage.getItem(CART_KEY)) || []; } catch { return []; } },
    save(items) { try { localStorage.setItem(CART_KEY, JSON.stringify(items)); } catch {} Cart.badge(); },
    add(item) {
      const items = Cart.get();
      const f = items.find((i) => i.product_id === item.product_id && i.size === item.size && i.color === item.color);
      if (f) f.qty += item.qty; else items.push(item);
      Cart.save(items);
    },
    count() { return Cart.get().reduce((s, i) => s + i.qty, 0); },
    badge() { const b = document.getElementById("cart-count"); if (b) { const n = Cart.count(); b.textContent = n; b.hidden = !n; } }
  };

  // ---------- Header & Footer chung ----------
  const page = (location.pathname.split("/").pop() || "index.html").replace(".html", "") || "index";
  const NAV = [
    ["index.html", "Trang chủ", ["index"]],
    ["about.html", "Về chúng tôi", ["about"]],
    ["index.html#khoa-hoc", "Khoá học", ["course"]],
    ["register.html", "Đăng ký", ["register"]],
    ["shop.html", "Gemini Shop", ["shop", "product"]]
  ];
  const svgIcon = {
    tiktok: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M16.6 5.8A4.3 4.3 0 0 1 15.5 3h-3.1v12.4a2.6 2.6 0 1 1-2.6-2.6c.3 0 .5 0 .8.1V9.7a5.7 5.7 0 1 0 4.9 5.7V9a7.4 7.4 0 0 0 4.3 1.4V7.3a4.3 4.3 0 0 1-3.2-1.5z"/></svg>',
    facebook: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M13.5 21v-7.5H16l.4-3h-2.9V8.6c0-.9.3-1.5 1.5-1.5h1.6V4.4a21 21 0 0 0-2.3-.1c-2.3 0-3.9 1.4-3.9 4v2.2H7.8v3h2.6V21h3.1z"/></svg>',
    youtube: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M21.6 7.2a2.5 2.5 0 0 0-1.8-1.8C18.2 5 12 5 12 5s-6.2 0-7.8.4A2.5 2.5 0 0 0 2.4 7.2 26 26 0 0 0 2 12a26 26 0 0 0 .4 4.8 2.5 2.5 0 0 0 1.8 1.8C5.8 19 12 19 12 19s6.2 0 7.8-.4a2.5 2.5 0 0 0 1.8-1.8A26 26 0 0 0 22 12a26 26 0 0 0-.4-4.8zM10 15V9l5.2 3L10 15z"/></svg>',
    cart: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" d="M3 4h2l2.2 10.2a1.5 1.5 0 0 0 1.5 1.2h8.6a1.5 1.5 0 0 0 1.5-1.1L21 8H6.2M9 20a1 1 0 1 0 0-.01M17 20a1 1 0 1 0 0-.01"/></svg>',
    pin: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M12 2a7 7 0 0 0-7 7c0 5.2 7 13 7 13s7-7.8 7-13a7 7 0 0 0-7-7zm0 9.5A2.5 2.5 0 1 1 12 6.5a2.5 2.5 0 0 1 0 5z"/></svg>'
  };
  window.ICON = svgIcon;

  function renderHeader() {
    const el = document.getElementById("site-header");
    if (!el) return;
    el.innerHTML = `
      <header class="site-header">
        <div class="container nav-wrap">
          <a class="brand" href="${ROOT}index.html" aria-label="Gemini Dance – Trang chủ">
            <img src="${ROOT}assets/img/logo-lockup.svg" alt="Gemini Dance" width="170" height="42">
          </a>
          <button class="nav-toggle" aria-label="Mở menu" aria-expanded="false"><span></span><span></span><span></span></button>
          <nav class="main-nav" aria-label="Menu chính">
            ${NAV.map(([href, label, keys]) => `<a href="${ROOT}${href}" class="${keys.includes(page) ? "active" : ""}">${label}</a>`).join("")}
            <a href="${ROOT}cart.html" class="cart-link ${page === "cart" ? "active" : ""}" aria-label="Giỏ hàng">${svgIcon.cart}<span id="cart-count" hidden>0</span></a>
          </nav>
        </div>
      </header>`;
    const btn = el.querySelector(".nav-toggle"), nav = el.querySelector(".main-nav");
    btn.addEventListener("click", () => {
      const open = nav.classList.toggle("open");
      btn.setAttribute("aria-expanded", open);
    });
    Cart.badge();
  }

  function renderFooter() {
    const el = document.getElementById("site-footer");
    if (!el) return;
    el.innerHTML = `
      <footer class="site-footer">
        <div class="container footer-grid">
          <div>
            <img src="${ROOT}assets/img/logo-lockup.svg" alt="Gemini Dance" class="footer-logo">
            <p class="muted">Như Song Tử, hãy để âm nhạc và vũ đạo đánh thức một “mặt khác” rạng rỡ, bản lĩnh hơn trong bạn.</p>
            <div class="socials">
              <a href="${C.SOCIAL.tiktok}" target="_blank" rel="noopener" aria-label="TikTok">${svgIcon.tiktok}</a>
              <a href="${C.SOCIAL.facebook}" target="_blank" rel="noopener" aria-label="Facebook">${svgIcon.facebook}</a>
              <a href="${C.SOCIAL.youtube}" target="_blank" rel="noopener" aria-label="YouTube">${svgIcon.youtube}</a>
            </div>
          </div>
          <div>
            <h4>Khám phá</h4>
            <a href="${ROOT}index.html">Trang chủ</a>
            <a href="${ROOT}about.html">Về chúng tôi</a>
            <a href="${ROOT}course.html?slug=beginner">Khoá Beginner</a>
            <a href="${ROOT}course.html?slug=advanced">Khoá Advanced</a>
            <a href="${ROOT}register.html">Đăng ký / Tra cứu</a>
            <a href="${ROOT}shop.html">Gemini Shop</a>
          </div>
          <div>
            <h4>Lịch học</h4>
            <p><span class="tag tag-beginner">BEGINNER</span><br>Chủ nhật · 12:00 – 14:00</p>
            <p><span class="tag tag-advanced">ADVANCED</span><br>T7 &amp; Chủ nhật · 14:00 – 15:00</p>
          </div>
          <div>
            <h4>Liên hệ</h4>
            <p class="addr">${svgIcon.pin}<span>${esc(C.ADDRESS)}</span></p>
            <p>☎ ${esc(C.PHONE)}<br>✉ ${esc(C.EMAIL)}</p>
          </div>
        </div>
        <div class="container footer-bottom">
          <span>© ${new Date().getFullYear()} Gemini Dance · Thương hiệu hư cấu cho đồ án cuối khoá.</span>
          <a href="${ROOT}admin/login.html" class="admin-link">Admin</a>
        </div>
      </footer>`;
  }

  // ---------- Ghi lượt truy cập ----------
  async function trackView() {
    if (!sb || document.body.dataset.noTrack !== undefined) return;
    let sid;
    try { sid = sessionStorage.getItem("gd_sid"); if (!sid) { sid = Math.random().toString(36).slice(2); sessionStorage.setItem("gd_sid", sid); } } catch { sid = null; }
    const { error } = await sb.from("page_views").insert({ page, referrer: document.referrer || null, session_id: sid });
    if (error) console.warn("[Gemini] page_views:", error.message);
  }

  renderHeader();
  renderFooter();
  trackView();
})();
