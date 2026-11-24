# CLAUDE.md – Hướng dẫn cho Claude Code

> **CLAUDE.md** là file Claude Code tự đọc mỗi khi mở dự án. Nó chứa quy tắc code, cấu trúc thư mục và lưu ý bảo mật để Claude làm đúng ngay mà không phải hỏi lại.

## Dự án
Website **Gemini Dance** (trung tâm dạy nhảy hư cấu + Gemini Shop). Đọc `PRD.md` (yêu cầu) và `DESIGN.md` (giao diện) trước khi sửa code.

## Công nghệ
- HTML + CSS + JavaScript thuần (không framework, không build step) → deploy thẳng lên GitHub Pages.
- Database & đăng nhập: **Supabase** qua CDN `@supabase/supabase-js@2.58.0`.
- Biểu đồ: **Chart.js 4.4.1** (CDN) – chỉ ở trang admin.
- Font: Google Fonts – chỉ dùng **Be Vietnam Pro** (hỗ trợ đầy đủ dấu tiếng Việt).

## Cấu trúc thư mục
```
index.html, about.html, courses.html (danh sách khoá), course.html (chi tiết), register.html, shop.html, product.html, cart.html
admin/        login, dashboard, registrations, courses, products, orders (.html)
assets/css/   style.css (site), admin.css (admin)
assets/js/    config.js (URL + publishable key), app.js (dùng chung), admin.js (dùng chung admin)
assets/img/   logo (từ image/gemini-dance-logo-pack), banner, poster
supabase/     schema.sql (bảng + RLS + hàm RPC + dữ liệu mẫu)
image/        ảnh gốc của Hạnh (không sửa)
```

## Quy tắc
1. Mọi trang dùng chung header/footer do `app.js` render (`<div id="site-header">`, `<div id="site-footer">`). Trang trong `admin/` đặt `data-root="../"` trên `<body>`.
2. Màu, font lấy từ biến CSS trong `style.css`, không hard-code màu mới.
3. Dùng đúng logo trong `assets/img/` – không tự vẽ logo khác.
4. Mọi chuỗi hiển thị bằng tiếng Việt có dấu. Viết đúng "BEGINNER" (poster gốc ghi sai "BEGINER").
5. Khi chèn dữ liệu người dùng vào HTML phải qua hàm `esc()` để tránh XSS.
6. Khách **không** truy cập bảng `registrations`/`orders` trực tiếp, chỉ qua hàm RPC trong `schema.sql`.
7. Nếu Supabase chưa sẵn sàng, trang công khai vẫn hiển thị dữ liệu mẫu (`FALLBACK` trong `app.js`).
8. Sau mỗi prompt, ghi prompt + kết quả vào `PROMPTS.md`.

## Bảo mật
- Chỉ đặt **publishable/anon key** trong `assets/js/config.js`.
- **Không bao giờ** commit `supabase.txt`, mật khẩu database hay `service_role` key (đã có trong `.gitignore`).

## Chạy thử
```bash
python3 -m http.server 8000   # rồi mở http://localhost:8000
```
