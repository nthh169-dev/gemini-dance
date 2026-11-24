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
    ${links.map(([k, v]) => `<a href="${k}.html" class="${k === page ? "active" : ""}">${v}</a>`).join("")}
    <a href="../index.html" target="_blank">🌐  Xem website</a>
    <a href="reset-password.html">🔑  Đổi mật khẩu</a>
    <div class="spacer"></div>
    <div class="who">${esc(email)}</div>
    <button id="logout">↩  Đăng xuất</button>`;
  document.getElementById("logout").onclick = async () => { await sb.auth.signOut(); location.href = "login.html"; };
}

window.STATUS_REG = { pending: "Chờ xác nhận", confirmed: "Đã xác nhận", cancelled: "Đã huỷ" };
window.STATUS_ORDER = { new: "Mới", shipping: "Đang giao", done: "Hoàn thành", cancelled: "Đã huỷ" };
window.statusSelect = (map, val, attrs) =>
  `<select ${attrs}>${Object.entries(map).map(([k, v]) => `<option value="${k}" ${k === val ? "selected" : ""}>${v}</option>`).join("")}</select>`;
