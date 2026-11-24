/* =====================================================================
   Gemini Dance – JS dùng chung cho trang admin
   - Kiểm tra đăng nhập + quyền admin (bảng admins)
   - Render sidebar
   ===================================================================== */
window.requireAdmin = async function () {
  if (!sb) { location.href = "login.html"; throw new Error("no db"); }
  const { data: { session } } = await sb.auth.getSession();
  if (!session) { location.href = "login.html"; throw new Error("not logged in"); }
  const { data: ok } = await sb.rpc("is_admin");
  if (!ok) {
    await sb.auth.signOut();
    location.href = "login.html?denied=1";
    throw new Error("not admin");
  }
  renderSide(session.user.email);
  return session.user;
};

function renderSide(email) {
  const page = location.pathname.split("/").pop().replace(".html", "");
  const links = [
    ["dashboard", "📊  Dashboard"], ["registrations", "📝  Đăng ký"], ["courses", "💃  Khoá học"],
    ["products", "👗  Sản phẩm"], ["orders", "🛍  Đơn hàng"]
  ];
  document.getElementById("admin-side").innerHTML = `
    <a href="dashboard.html" style="padding:0;background:none"><img src="../assets/img/logo-lockup.svg" alt="Gemini Dance Admin"></a>
    ${links.map(([k, v]) => `<a href="${k}.html" class="${k === page ? "active" : ""}">${v}${NEW_BADGE[k] ? `<span class="nav-badge" id="badge-${k}" hidden></span>` : ""}</a>`).join("")}
    <a href="../index.html" target="_blank">🌐  Xem website</a>
    <a href="reset-password.html">🔑  Đổi mật khẩu</a>
    <div class="spacer"></div>
    <div class="who">${esc(email)}</div>
    <button id="logout">↩  Đăng xuất</button>`;
  document.getElementById("logout").onclick = async () => { await sb.auth.signOut(); location.href = "login.html"; };
  initNewBadges(email, page);
}

// ---------- Badge "mới" trên menu Đăng ký / Đơn hàng ----------
// Ghi nhớ (trong trình duyệt của admin) thời điểm record mới nhất đã xem.
// Badge = số record có created_at sau mốc đó. Mở trang tương ứng => badge mất.
const NEW_BADGE = { registrations: "registrations", orders: "orders" };
async function latestCreated(table) {
  const { data } = await sb.from(table).select("created_at").order("created_at", { ascending: false }).limit(1);
  return data && data[0] ? data[0].created_at : new Date(0).toISOString();
}
async function initNewBadges(email, page) {
  const key = (k) => `gd_seen_${k}_${email}`;
  const get = (k) => { try { return localStorage.getItem(key(k)); } catch { return null; } };
  const set = (k, v) => { try { localStorage.setItem(key(k), v); } catch {} };
  async function refresh() {
    for (const k of Object.keys(NEW_BADGE)) {
      const el = document.getElementById("badge-" + k);
      if (!el) continue;
      let seen = get(k);
      // Đang mở trang này, hoặc lần đầu dùng: coi như đã xem hết
      if (k === page || !seen) { set(k, await latestCreated(NEW_BADGE[k])); el.hidden = true; continue; }
      const { count } = await sb.from(NEW_BADGE[k]).select("id", { count: "exact", head: true }).gt("created_at", seen);
      el.textContent = count > 99 ? "99+" : count;
      el.hidden = !count;
    }
  }
  await refresh();
  setInterval(refresh, 30000); // tự cập nhật mỗi 30 giây
}

window.STATUS_REG = { pending: "Chờ xác nhận", confirmed: "Đã xác nhận", cancelled: "Đã huỷ" };
window.STATUS_ORDER = { new: "Mới", shipping: "Đang giao", done: "Hoàn thành", cancelled: "Đã huỷ" };
window.statusSelect = (map, val, attrs) =>
  `<select ${attrs}>${Object.entries(map).map(([k, v]) => `<option value="${k}" ${k === val ? "selected" : ""}>${v}</option>`).join("")}</select>`;
