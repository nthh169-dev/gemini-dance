# Gemini Dance 💃 – Website trung tâm dạy nhảy & Gemini Shop

<p align="center"><img src="assets/img/logo-lockup.svg" alt="Gemini Dance" width="360"></p>

> **README.md** là "cửa chính" của repo trên GitHub: giới thiệu dự án, cách chạy, cách cài database và cách deploy.

Website cho thương hiệu hư cấu **Gemini Dance (Song Tử)** – trung tâm dạy nhảy cho nữ tại 188/5/1 Nguyễn Suý, Q. Tân Phú, Tp.HCM – kèm cửa hàng trang phục nhảy **Gemini Shop** và khu **quản trị admin**.

- 🌐 Demo: https://nthh169-dev.github.io/gemini-dance/
- 💻 Source: https://github.com/nthh169-dev/gemini-dance
- 📄 Báo cáo đồ án: [REPORT.md](REPORT.md)

## Công nghệ
HTML · CSS · JavaScript thuần · [Supabase](https://supabase.com) (PostgreSQL + Auth + RLS) · Chart.js · GitHub Pages

## Cấu trúc
```
├── index.html            Trang chủ (YouTube + Google Map + mạng xã hội)
├── about.html            Chuyển hướng về phần "Về chúng tôi" trên Trang chủ
├── courses.html          Danh sách khoá học
├── course.html           Chi tiết khoá học (?slug=beginner | advanced)
├── register.html         Đăng ký / tra cứu / sửa / huỷ đăng ký
├── shop.html             Gemini Shop
├── product.html          Chi tiết sản phẩm (?id=…)
├── cart.html             Giỏ hàng + đặt hàng + tra cứu đơn
├── admin/                login, dashboard, registrations, courses, products, orders
├── assets/css|js|img     Giao diện, script dùng chung, logo & ảnh
├── supabase/schema.sql   Bảng, bảo mật RLS, hàm RPC, dữ liệu mẫu
├── PRD.md  DESIGN.md  CLAUDE.md  PROMPTS.md  REPORT.md
└── image/                Ảnh gốc (poster, logo pack)
```

## Cài đặt database (làm 1 lần)
1. Mở Supabase project → **SQL Editor** → New query → dán toàn bộ `supabase/schema.sql` → **Run**.
2. **Authentication → Users → Add user**: tạo tài khoản admin (email + mật khẩu), tick *Auto Confirm*.
3. Quay lại SQL Editor, chạy (thay email):
   ```sql
   insert into public.admins(user_id, email)
   select id, email from auth.users where email = 'email-admin-cua-ban@gmail.com';
   ```
3b. Nếu database được tạo **trước ngày 24/11/2026**: chạy thêm `supabase/migration-003-validate.sql` trong SQL Editor (kiểm tra 18 tuổi, email, SĐT). File `migration-002-birth-date.sql` không cần chạy nữa.
4. **Authentication → Sign In / Providers → Email**: tắt *Allow new users to sign up* để người lạ không tự tạo tài khoản.
5. **Authentication → URL Configuration** (để chức năng *Quên mật khẩu* hoạt động):
   - *Site URL*: link website sau khi deploy, ví dụ `https://nthh169-dev.github.io/gemini-dance/`
   - *Redirect URLs* → Add URL: `http://localhost:8000/**` và `https://nthh169-dev.github.io/gemini-dance/**`

### Quên mật khẩu admin
Vào `admin/login.html` → **Quên mật khẩu?** → nhập email admin → mở thư *Reset Your Password* → link đưa về `admin/reset-password.html` để đặt mật khẩu mới. Admin đang đăng nhập cũng đổi được mật khẩu qua mục **🔑 Đổi mật khẩu** ở sidebar.
> Email mặc định của Supabase chỉ gửi được vài thư mỗi giờ và chỉ tới email thành viên của project. Nếu không nhận được thư: Supabase → Authentication → Users → bấm vào user → *Send password recovery*, hoặc xoá user rồi tạo lại.
> Nếu báo **"Supabase đã gửi quá số email cho phép trong 1 giờ"**: đợi khoảng 1 giờ, hoặc đặt mật khẩu mới trực tiếp bằng SQL: mở `supabase/reset-admin-password.sql`, sửa email + mật khẩu mới, dán vào SQL Editor rồi Run.

URL và *publishable key* đã có trong `assets/js/config.js` (key này được phép công khai; dữ liệu được bảo vệ bằng RLS).

## Chạy trên máy
```bash
cd website_dance
python3 -m http.server 8000
# mở http://localhost:8000
```
(Mở trực tiếp file .html bằng double-click cũng xem được, nhưng nên chạy server để giống khi deploy.)

## Push lên GitHub & deploy GitHub Pages
```bash
git init
git add .
git commit -m "Gemini Dance website"
git branch -M main
git remote add origin https://github.com/nthh169-dev/gemini-dance.git
git push -u origin main
```
Trên GitHub: **Settings → General** để repo ở chế độ **Public** → **Settings → Pages** → Source: *Deploy from a branch* → Branch `main` / `(root)` → Save. Sau 1–2 phút web chạy tại `https://nthh169-dev.github.io/gemini-dance/`.

> ⚠️ `supabase.txt` (chứa mật khẩu database) đã nằm trong `.gitignore` – không bao giờ được push lên GitHub.

## Tác giả
Nguyễn Hạnh – đồ án cuối khoá Claude Code, 11/2026.
