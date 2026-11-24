# BÁO CÁO ĐỒ ÁN CUỐI KHOÁ – WEBSITE GEMINI DANCE

| | |
|---|---|
| Sinh viên | Nguyễn Hạnh |
| Link GitHub | https://github.com/nthh169-dev/gemini-dance |
| Link website | https://nthh169-dev.github.io/gemini-dance/ |
| Ngày nộp | 29/11/2026 |

---

## 1. Mô tả dự án

**Lĩnh vực:** giáo dục – năng khiếu (trung tâm dạy nhảy) kết hợp thương mại điện tử (bán trang phục nhảy).

**Thương hiệu:** **Gemini Dance** – thương hiệu **hư cấu**, lấy cảm hứng từ chòm sao **Song Tử (Gemini)**. Thông điệp: *"Như Song Tử, hãy để âm nhạc và vũ đạo đánh thức một 'mặt khác' rạng rỡ, bản lĩnh hơn trong bạn."* Đối tượng: nữ từ 18 tuổi, yêu thích Sexy Dance, Heels, K-pop.

**Địa chỉ:** 188/5/1 Nguyễn Suý, Q. Tân Phú, Tp.HCM · TikTok `@gemini.dance169` · Facebook `gemini.dance169` · YouTube `@GeminiDance`.

**Logo:** vì là thương hiệu hư cấu, logo được tạo **trước** (bộ `image/gemini-dance-logo-pack/`) và dùng **thống nhất** ở header, footer, favicon, trang About và trang admin.

<p><img src="assets/img/logo-lockup.svg" alt="Logo Gemini Dance" width="420"></p>

- Biểu tượng cách điệu từ ký hiệu ♊ Song Tử: hai đường cong như hai cánh tay đang múa, bên trái là dáng một vũ công.
- Gradient **cyan → tím → hồng**: hành trình từ người mới (Beginner) tới tự tin toả sáng (Advanced).

**Công nghệ:** HTML, CSS, JavaScript thuần; database **Supabase** (PostgreSQL + Auth + Row Level Security); Chart.js; deploy **GitHub Pages**.

## 2. Các trang trong dự án

| # | Trang | File | Nội dung |
|---|---|---|---|
| 1 | **Trang chủ** | `index.html` | Banner logo + slogan, 2 thẻ khoá học (lấy từ DB), **video YouTube nhúng**, lý do chọn Gemini, sản phẩm nổi bật, **Google Map nhúng**, link TikTok / Facebook / YouTube |
| 2 | **Về chúng tôi** | `about.html` | Câu chuyện Song Tử, ý nghĩa logo, giá trị cốt lõi, đội ngũ giáo viên, poster tuyển sinh |
| 3 | **Chi tiết khoá học** | `course.html?slug=beginner` / `advanced` | Lịch học, học phí, thời lượng, số chỗ còn trống (tính từ DB), nội dung học, nút đăng ký |
| 4 | **Đăng ký khoá học** | `register.html` | Đăng ký mới · Tra cứu · Sửa · Huỷ |
| 5 | **Gemini Shop** | `shop.html` | Danh sách sản phẩm, lọc danh mục, tìm kiếm, sắp xếp giá |
| 6 | **Chi tiết sản phẩm** | `product.html?id=…` | Giá, size, màu, số lượng, tồn kho, thêm vào giỏ, sản phẩm liên quan |
| 7 | **Giỏ hàng** | `cart.html` | Sửa số lượng, xoá món, đặt hàng, tra cứu đơn |
| 8 | Admin – Đăng nhập | `admin/login.html` | Supabase Auth, chỉ tài khoản trong bảng `admins` |
| 8b | Admin – Quên mật khẩu | `admin/forgot-password.html` | Gửi link đặt lại mật khẩu qua email |
| 8c | Admin – Đặt mật khẩu mới | `admin/reset-password.html` | Đặt mật khẩu mới từ link email, hoặc đổi mật khẩu khi đang đăng nhập |
| 9 | Admin – Dashboard | `admin/dashboard.html` | Số đăng ký (theo khoá), lượt truy cập, đơn hàng, doanh thu, biểu đồ theo ngày, trang xem nhiều, SP bán chạy |
| 10 | Admin – Đăng ký | `admin/registrations.html` | Tìm kiếm, lọc, đổi trạng thái, sửa, xoá |
| 11 | Admin – Khoá học | `admin/courses.html` | Thêm, sửa, xoá khoá học |
| 12 | Admin – Sản phẩm | `admin/products.html` | Thêm, sửa, xoá sản phẩm |
| 13 | Admin – Đơn hàng | `admin/orders.html` | Xem chi tiết, đổi trạng thái, xoá |

**Liên kết giữa các trang:** mọi trang công khai dùng chung một **menu** (Trang chủ · Về chúng tôi · Khoá học · Đăng ký · Gemini Shop · Giỏ hàng) và **footer** (link tới từng khoá, đăng ký, shop, admin). Trang admin có sidebar riêng và link quay về website.

*(Chèn ảnh chụp màn hình từng trang vào `docs/screenshots/` và thêm vào đây.)*

## 3. Các chức năng đã thực hiện

**Database Supabase – 7 bảng:** `courses`, `registrations`, `page_views`, `products`, `orders`, `order_items`, `admins` (xem `supabase/schema.sql`).

| # | Chức năng | Thao tác DB |
|---|---|---|
| 1 | Hiển thị khoá học, số chỗ còn trống | SELECT `courses`, RPC `course_seats` |
| 2 | **Đăng ký khoá học** → nhận mã đăng ký | **INSERT** `registrations` |
| 3 | Tra cứu đăng ký bằng mã + SĐT | SELECT (RPC `find_registration`) |
| 4 | **Sửa đăng ký** (đổi tên, email, đổi lớp, ghi chú) | **UPDATE** `registrations` |
| 5 | **Huỷ đăng ký** | **DELETE** `registrations` |
| 6 | Ghi lượt truy cập mỗi lần mở trang | INSERT `page_views` |
| 7 | Danh sách + chi tiết sản phẩm, lọc, tìm kiếm, sắp xếp | SELECT `products` |
| 8 | Giỏ hàng: thêm / đổi số lượng / xoá (lưu trên trình duyệt) | localStorage |
| 9 | **Đặt hàng** – lưu đơn, trừ tồn kho | **INSERT** `orders`, `order_items`; **UPDATE** `products.stock` |
| 10 | Tra cứu đơn hàng | SELECT (RPC `find_order`) |
| 11 | Đăng nhập / đăng xuất admin | Supabase Auth |
| 11b | **Quên mật khẩu admin**: gửi email chứa link, đặt mật khẩu mới; đổi mật khẩu từ sidebar | Supabase Auth (UPDATE mật khẩu) |
| 12 | Dashboard thống kê + biểu đồ | SELECT nhiều bảng |
| 13 | Admin quản lý đăng ký | UPDATE, DELETE |
| 14 | Admin quản lý khoá học | INSERT, UPDATE, DELETE |
| 15 | Admin quản lý sản phẩm | INSERT, UPDATE, DELETE |
| 16 | Admin quản lý đơn hàng | UPDATE, DELETE |
| 17 | Nhúng **YouTube** (kênh @GeminiDance) và **Google Map** | – |
| 18 | Giao diện responsive (máy tính + điện thoại) | – |

**Bảo mật:** bật Row Level Security trên mọi bảng. Khách chỉ thao tác dữ liệu của mình qua hàm RPC (phải đúng mã + SĐT); chỉ admin mới đọc / sửa / xoá toàn bộ. Frontend chỉ chứa publishable key; mật khẩu database nằm trong `supabase.txt` đã bị `.gitignore` chặn.

## 4. Các file .md và chức năng

| File | Chức năng |
|---|---|
| `PRD.md` | **Product Requirements Document** – mô tả *website cần làm gì*: mục tiêu, người dùng, danh sách trang, chức năng, cấu trúc dữ liệu, đối chiếu tiêu chí chấm điểm. Là "đề bài chi tiết" để Claude code đúng yêu cầu. |
| `DESIGN.md` | Mô tả *website trông như thế nào*: logo, bảng màu neon lấy từ poster, font, thành phần giao diện, bố cục từng trang, phong cách Shop. Giúp mọi trang thống nhất nhận diện thương hiệu. |
| `CLAUDE.md` | File Claude Code tự đọc khi mở dự án: công nghệ, cấu trúc thư mục, quy tắc code, quy tắc bảo mật (không commit mật khẩu). |
| `README.md` | Giới thiệu repo trên GitHub, cách cài database, chạy thử và deploy. |
| `PROMPTS.md` | Nhật ký thứ tự các prompt và kết quả từng prompt. |
| `REPORT.md` | Báo cáo đồ án này. |

## 5. Thứ tự các prompt và kết quả

Chi tiết đầy đủ trong [PROMPTS.md](PROMPTS.md). Tóm tắt:

| # | Prompt | Kết quả |
|---|---|---|
| 1 | Dán đề bài + poster, nhờ lập kế hoạch các bước (Home có YouTube, map, social; chi tiết 2 khoá; module đăng ký) | Kế hoạch 7 bước, chọn HTML/CSS/JS + Supabase, lịch làm 24 → 29/11 |
| 2 | Thêm module login chỉ dành cho admin, có dashboard (số người đăng ký, người vào trang…) | Bổ sung Supabase Auth + RLS, bảng `page_views`, dashboard biểu đồ, quản lý đăng ký / khoá học |
| 3 | Thêm trang Gemini Shop bán trang phục, giày nhảy, phong cách trẻ trung cho nữ 18+ | Bổ sung shop, chi tiết SP, giỏ hàng, đơn hàng, admin sản phẩm / đơn hàng |
| 4 | Tạo file .md và code website vào thư mục `website_dance`, ghi lại mô tả theo đề bài | Tạo đủ file .md, schema Supabase, 13 trang web, kiểm tra trên desktop & mobile |
| 5 | Làm thêm module quên password cho admin (vì đã quên mật khẩu đặt trên Supabase) | Thêm trang Quên mật khẩu + Đặt mật khẩu mới, link ở trang đăng nhập, mục Đổi mật khẩu ở sidebar admin |
| 6 | Kết nối database Supabase sau khi đã tạo bảng và thêm admin | Kiểm tra kết nối thật: đọc dữ liệu OK, RLS chặn khách đúng, thử insert/update/delete qua RPC thành công |
| 7 | Hỏi nguyên nhân lỗi 127.0.0.1 khi đặt lại mật khẩu | Giải thích Site URL / Redirect URLs của Supabase và cách cấu hình |
| 8 | Deploy lên GitHub Pages | Push code lên repo Public, bật Pages, kiểm tra web online chạy với database thật |

## 6. Hướng dẫn chạy & deploy
Xem [README.md](README.md).
