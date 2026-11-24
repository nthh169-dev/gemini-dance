# PRD – Gemini Dance Website

> **PRD (Product Requirements Document)** mô tả *website cần làm gì*: mục tiêu, người dùng, danh sách trang, chức năng và dữ liệu. Đây là "bản đề bài chi tiết" để Claude Code và người làm dự án bám theo khi code.

## 1. Tổng quan

| Mục | Nội dung |
|---|---|
| Thương hiệu | **Gemini Dance** (Song Tử) – thương hiệu **hư cấu** |
| Lĩnh vực | Trung tâm dạy nhảy (Sexy Dance / Heels / K-pop / Jazz) cho nữ, kèm cửa hàng trang phục nhảy **Gemini Shop** |
| Slogan | *"Như Song Tử, hãy để âm nhạc và vũ đạo đánh thức một 'mặt khác' rạng rỡ, bản lĩnh hơn trong bạn."* |
| Địa chỉ | 188/5/1 Nguyễn Suý, Q. Tân Phú, Tp.HCM |
| Logo | Bộ logo tự thiết kế trong `image/gemini-dance-logo-pack/` (dùng thống nhất ở mọi trang qua `assets/img/`) |
| Mạng xã hội | TikTok `@gemini.dance169`, Facebook `gemini.dance169`, YouTube `@GeminiDance` |
| Hạn nộp | 29/11/2026 |

## 2. Mục tiêu

1. Giới thiệu thương hiệu và 2 khoá học (Beginner, Advanced).
2. Cho học viên **đăng ký / sửa / huỷ** đăng ký khoá học online.
3. Bán trang phục, giày nhảy qua **Gemini Shop** (giỏ hàng + đặt hàng).
4. Cho **admin** theo dõi số đăng ký, lượt truy cập, đơn hàng và quản lý dữ liệu.
5. Đáp ứng đủ tiêu chí chấm điểm của đồ án (xem mục 7).

## 3. Người dùng

| Vai trò | Mô tả | Quyền |
|---|---|---|
| Khách / học viên | Nữ 18+, thích nhảy, theo dõi TikTok/Facebook | Xem trang, đăng ký khoá học, tra cứu/sửa/huỷ đăng ký bằng *mã đăng ký + SĐT*, mua hàng |
| Admin | Chủ trung tâm | Đăng nhập, xem dashboard, quản lý đăng ký, khoá học, sản phẩm, đơn hàng |

## 4. Danh sách trang

### Trang công khai
| File | Trang | Nội dung chính |
|---|---|---|
| `index.html` | **Trang chủ** | Banner + logo + slogan, 2 thẻ khoá học (lấy từ DB), **video YouTube nhúng**, sản phẩm nổi bật, **Google Map nhúng**, link TikTok/Facebook/YouTube |
| `about.html` | **Về chúng tôi** | Câu chuyện thương hiệu Song Tử, ý nghĩa logo, giá trị, đội ngũ, poster |
| `course.html?slug=beginner` / `?slug=advanced` | **Chi tiết khoá học** | Lịch học, học phí, thời lượng, nội dung, số chỗ còn lại, nút "Đăng ký ngay" |
| `register.html` | **Đăng ký khoá học** | Form đăng ký (INSERT) · Tra cứu đăng ký · Sửa (UPDATE) · Huỷ (DELETE) |
| `shop.html` | **Gemini Shop** | Danh sách sản phẩm, lọc danh mục, sắp xếp giá, tìm kiếm |
| `product.html?id=…` | **Chi tiết sản phẩm** | Ảnh, giá, chọn size/màu/số lượng, thêm vào giỏ |
| `cart.html` | **Giỏ hàng & Đặt hàng** | Đổi số lượng, xoá món, form đặt hàng (INSERT đơn hàng), tra cứu đơn |

### Trang admin (`admin/`, không có trên menu chính – chỉ có link nhỏ ở footer)
| File | Trang | Chức năng |
|---|---|---|
| `admin/login.html` | Đăng nhập | Supabase Auth (email + mật khẩu), link "Quên mật khẩu?" |
| `admin/forgot-password.html` | Quên mật khẩu | Nhập email admin → Supabase gửi link đặt lại mật khẩu |
| `admin/reset-password.html` | Đặt mật khẩu mới | Mở từ link trong email (hoặc từ sidebar khi đang đăng nhập) → nhập mật khẩu mới |
| `admin/dashboard.html` | Dashboard | Tổng đăng ký (theo khoá), lượt truy cập, đơn hàng, doanh thu; biểu đồ theo ngày; trang được xem nhiều; sản phẩm bán chạy |
| `admin/registrations.html` | Quản lý đăng ký | Tìm kiếm, lọc, đổi trạng thái, sửa ghi chú, xoá |
| `admin/courses.html` | Quản lý khoá học | Sửa lịch, học phí, mô tả; thêm / xoá khoá |
| `admin/products.html` | Quản lý sản phẩm | Thêm / sửa / xoá sản phẩm, tồn kho |
| `admin/orders.html` | Quản lý đơn hàng | Xem chi tiết, đổi trạng thái (Mới / Đang giao / Hoàn thành / Huỷ), xoá |

Tất cả trang dùng chung **header menu + footer**, nên mọi trang đều liên kết với nhau.

## 5. Chức năng & thao tác database

| # | Chức năng | Bảng | Thao tác |
|---|---|---|---|
| F1 | Hiển thị khoá học từ DB | `courses` | SELECT |
| F2 | Đăng ký khoá học | `registrations` | **INSERT** |
| F3 | Tra cứu đăng ký bằng mã + SĐT | `registrations` | SELECT (RPC) |
| F4 | Sửa thông tin / đổi khoá | `registrations` | **UPDATE** |
| F5 | Huỷ đăng ký | `registrations` | **DELETE** |
| F6 | Ghi lượt truy cập mỗi trang | `page_views` | INSERT |
| F7 | Danh sách / chi tiết sản phẩm | `products` | SELECT |
| F8 | Giỏ hàng (thêm / đổi SL / xoá) | localStorage | – |
| F9 | Đặt hàng (trừ tồn kho) | `orders`, `order_items`, `products` | **INSERT** + UPDATE |
| F10 | Tra cứu đơn hàng | `orders` | SELECT (RPC) |
| F11 | Admin đăng nhập / đăng xuất | Supabase Auth | – |
| F11b | Admin quên mật khẩu / đổi mật khẩu | Supabase Auth (`resetPasswordForEmail`, `updateUser`) | UPDATE (auth.users) |
| F12 | Dashboard thống kê + biểu đồ | tất cả | SELECT |
| F13 | Admin quản lý đăng ký | `registrations` | UPDATE, DELETE |
| F14 | Admin quản lý khoá học | `courses` | INSERT, UPDATE, DELETE |
| F15 | Admin quản lý sản phẩm | `products` | INSERT, UPDATE, DELETE |
| F16 | Admin quản lý đơn hàng | `orders` | UPDATE, DELETE |

## 6. Dữ liệu (Supabase / PostgreSQL)

Chi tiết trong `supabase/schema.sql`.

- `courses` (slug, name, level, schedule_days, schedule_time, fee, duration_weeks, max_students, short_desc, description, highlights, is_active)
- `registrations` (code, full_name, phone, email, birth_year, course_id, note, status, created_at, updated_at)
- `page_views` (page, referrer, session_id, created_at)
- `products` (name, category, price, sale_price, sizes, colors, badge, stock, image_url, description, is_active)
- `orders` (code, customer_name, phone, email, address, note, total, status) + `order_items`
- `admins` (user_id, email) – danh sách tài khoản có quyền admin

**Bảo mật:** bật RLS trên mọi bảng. Khách chỉ thao tác qua các hàm RPC (cần đúng *mã + SĐT*), không đọc được dữ liệu người khác. Chỉ tài khoản có trong bảng `admins` mới xem/sửa/xoá toàn bộ. Frontend chỉ chứa *publishable (anon) key*; mật khẩu DB không bao giờ đưa lên GitHub.

## 7. Đối chiếu tiêu chí chấm điểm

| Tiêu chí | Điểm | Đáp ứng bằng |
|---|---|---|
| ≥ 3 trang: Home, About, Detail | 3 | `index.html`, `about.html`, `course.html`, `product.html` (+ nhiều trang khác) |
| Có database | 3 | Supabase (6 bảng) |
| ≥ 2 chức năng chỉnh sửa DB | 2 | Đăng ký/sửa/huỷ khoá học, đặt hàng, toàn bộ admin CRUD |
| Nhúng Google Map / YouTube | 0,5 | Trang chủ có cả hai |
| Dùng file .md | 0,5 | PRD, DESIGN, README, CLAUDE, PROMPTS, REPORT |
| Push GitHub (Public) | 0,5 | Xem README |
| Deploy | 0,5 | GitHub Pages |
| Trang liên kết với nhau | (tránh −0,5) | Header/footer chung |
| Thương hiệu hư cấu có logo riêng, dùng đúng logo | (tránh −0,5) | Logo pack dùng ở header, footer, favicon, admin |

## 8. Ngoài phạm vi
- Thanh toán online (chỉ COD / chuyển khoản thủ công).
- Tài khoản học viên (học viên tra cứu bằng mã + SĐT thay vì đăng nhập).
