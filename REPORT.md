# BÁO CÁO ĐỒ ÁN CUỐI KHOÁ – WEBSITE GEMINI DANCE

> **REPORT.md** là báo cáo tổng hợp của đồ án: mô tả dự án, các trang, các chức năng, vai trò của các file `.md` và thứ tự các prompt đã làm việc với Claude Code.

| | |
|---|---|
| **Sinh viên** | Nguyễn Hạnh |
| **Ngày nộp** | 29/11/2026 |
| **Mã nguồn (GitHub)** | https://github.com/nthh169-dev/gemini-dance |
| **Website (GitHub Pages)** | https://nthh169-dev.github.io/gemini-dance/ |
| **Website (Cloudflare Workers)** | https://gemini-dance.nthh169.workers.dev |
| **Công cụ AI** | Claude Code |

---

## 1. Mô tả dự án

### 1.1 Lĩnh vực
Website cho một **trung tâm dạy nhảy** (Sexy Dance, Heels, K-pop dành cho nữ từ 18 tuổi), kết hợp **cửa hàng online** bán trang phục, giày và phụ kiện nhảy. Website vừa giới thiệu thương hiệu, vừa cho học viên đăng ký khoá học, vừa bán hàng, và có khu quản trị riêng cho admin.

### 1.2 Thương hiệu
- **Tên:** Gemini Dance (Song Tử) – thương hiệu hư cấu dùng cho đồ án.
- **Ý nghĩa:** Song Tử là hai nửa song hành, tượng trưng cho hai mặt của người phụ nữ khi nhảy: dịu dàng và mạnh mẽ, tự tin và quyến rũ.
- **Phong cách:** trẻ trung, trendy, năng lượng sân khấu. Nền đêm sâu, chòm sao Song Tử màu vàng nhạt, ánh đèn bokeh (lấy cảm hứng từ poster gốc).
- **Màu chủ đạo:** gradient neon **cyan `#3EE6DF` → tím `#8A7CF0` → hồng `#E8439A`** trên nền tối `#07060D`, điểm nhấn vàng `#E8C27A`.
- **Font:** chỉ dùng **Be Vietnam Pro** (Google Fonts) để hiển thị đủ dấu tiếng Việt và đồng đều trên mọi trang.
- **Địa chỉ:** 188/5/1 Nguyễn Suý (hư cấu). **Liên hệ:** 0900000000 · geminidance@example.com.vn. Có link TikTok, Facebook, YouTube.

### 1.3 Logo
Bộ logo gốc nằm trong `image/gemini-dance-logo-pack/`, được copy sang `assets/img/` và dùng nguyên bản (không vẽ lại):

| File | Nội dung | Dùng ở |
|---|---|---|
| `logo-lockup.svg` | Biểu tượng ♊ + chữ "Gemini Dance" | Header mọi trang và trang admin |
| `logo-mark.svg` | Chỉ biểu tượng Song Tử | Hero, phần Về chúng tôi, footer |
| `logo-icon.svg` | Icon vuông | Favicon |

Biểu tượng là hai nét cong đối xứng tạo thành chữ ♊ (Song Tử), tô gradient neon cyan → tím → hồng như ánh đèn sân khấu.

### 1.4 Khoá học
| Khoá | Lịch | Thời lượng | Học phí | Sĩ số |
|---|---|---|---|---|
| **Beginner – Lớp Căn Bản** | Chủ nhật 12:00 – 14:00 | 8 tuần | 1.200.000đ | 20 |
| **Advanced – Lớp Nâng Cao** | Thứ 7 & Chủ nhật 14:00 – 15:00 | 8 tuần | 1.500.000đ | 15 |

Admin có thể thêm khoá mới (hoặc copy khoá cũ), nên danh sách trên web luôn lấy từ database.

### 1.5 Công nghệ
| Thành phần | Lựa chọn | Lý do |
|---|---|---|
| Giao diện | HTML + CSS + JavaScript thuần | Không cần build, deploy thẳng lên GitHub Pages |
| Database + đăng nhập | **Supabase** (PostgreSQL, Auth, RLS, hàm RPC) | GitHub Pages là web tĩnh, không ghi được file; Supabase miễn phí và bảo mật bằng RLS |
| Biểu đồ | Chart.js 4.4.1 | Dashboard admin |
| Video, bản đồ | YouTube embed, Google Maps embed | Trang chủ |
| Hosting | **GitHub Pages** và **Cloudflare Workers** (tự build khi push lên GitHub) | Miễn phí, có HTTPS |

---

## 2. Các trang trong dự án

Menu chính: **Trang chủ · Khoá học · Đăng ký · Gemini Shop · Giỏ hàng**. Header và footer dùng chung, do `assets/js/app.js` tạo ra.

### 2.1 Trang công khai
| Trang | File | Nội dung |
|---|---|---|
| **Trang chủ** | `index.html` | Banner hero + nút đăng ký; video YouTube dạng trượt (carousel); "Vì sao chọn Gemini Dance"; sản phẩm nổi bật của Shop; liên hệ + bản đồ Google Maps + mạng xã hội |
| **Về chúng tôi** | `index.html#ve-chung-toi` | Nằm ngay trong Trang chủ: câu chuyện Song Tử, ý nghĩa logo, giá trị cốt lõi, đội ngũ giảng viên. `about.html` giữ lại chỉ để chuyển hướng link cũ về đây |
| **Khoá học** | `courses.html` | Danh sách mọi khoá học từ database, lọc theo cấp độ |
| **Chi tiết khoá học** | `course.html?slug=…` | Mô tả, lịch học, học phí, nội dung học, số chỗ còn lại, nút đăng ký |
| **Đăng ký khoá học** | `register.html` | Form đăng ký; tra cứu đăng ký bằng SĐT + email; sửa hoặc huỷ đăng ký |
| **Gemini Shop** | `shop.html` | Lưới sản phẩm, lọc theo danh mục, sắp xếp theo giá |
| **Chi tiết sản phẩm** | `product.html?id=…` | Ảnh theo màu, chọn size/màu/số lượng, thêm vào giỏ |
| **Giỏ hàng & đặt hàng** | `cart.html` | Sửa số lượng, xoá món, nhập thông tin giao hàng, đặt hàng, tra cứu đơn |

### 2.2 Trang admin (thư mục `admin/`, chỉ có link nhỏ ở footer)
| Trang | File | Nội dung |
|---|---|---|
| Đăng nhập | `login.html` | Email + mật khẩu (Supabase Auth), chỉ tài khoản trong bảng `admins` mới vào được |
| Quên mật khẩu | `forgot-password.html` | Gửi email chứa link đặt lại mật khẩu |
| Đặt lại mật khẩu | `reset-password.html` | Nhập mật khẩu mới từ link trong email |
| Dashboard | `dashboard.html` | Thẻ thống kê (đăng ký, lượt truy cập, đơn hàng, doanh thu học phí, doanh thu Shop) và biểu đồ |
| Quản lý đăng ký | `registrations.html` | Xem, lọc, đổi trạng thái, sửa, huỷ; cột "Huỷ bởi" |
| Quản lý khoá học | `courses.html` | Thêm, sửa, xoá, **copy** khoá học |
| Quản lý sản phẩm | `products.html` | Thêm, sửa, xoá, ẩn sản phẩm; ảnh theo màu |
| Quản lý đơn hàng | `orders.html` | Xem chi tiết đơn, đổi trạng thái |

---

## 3. Các chức năng đã thực hiện

### 3.1 Khách / học viên
1. **Xem thông tin**: Trang chủ có video, bản đồ, mạng xã hội; phần Về chúng tôi; danh sách và chi tiết khoá học (dữ liệu từ database).
2. **Đăng ký khoá học** (INSERT): chọn **Cấp độ** và **Lịch học** ở 2 ô riêng, nhập họ tên, SĐT, email, năm sinh, ghi chú.
3. **Kiểm tra dữ liệu** ở cả giao diện lẫn database:
   - Chỉ nhận học viên **từ 18 tuổi** (ô năm sinh có nút mở bảng chọn năm, hoặc gõ trực tiếp).
   - SĐT Việt Nam 10 số (03/05/07/08/09, chấp nhận +84, dấu cách, dấu chấm).
   - Email đúng định dạng.
   - Không đăng ký trùng; không đăng ký khi khoá đã hết chỗ.
4. **Tra cứu đăng ký** (SELECT) bằng SĐT + email.
5. **Sửa đăng ký** (UPDATE) khi còn "Chờ xác nhận".
6. **Huỷ đăng ký**: chỉ huỷ được khi còn "Chờ xác nhận". Khi huỷ, bản ghi **không bị xoá** mà chuyển sang "Đã huỷ" và ghi lại người huỷ (học viên/admin) cùng thời gian. Đăng ký đã được admin xác nhận thì bị khoá, chỉ xem được.
7. **Mua hàng**: lọc, sắp xếp sản phẩm; đổi màu thì ảnh đổi theo; giỏ hàng lưu trong trình duyệt; đặt hàng (giá tính lại ở database, không tin giá gửi từ trình duyệt); tra cứu đơn hàng.
8. **Video YouTube dạng trượt**: hiển thị nhiều video, vuốt hoặc bấm mũi tên để chuyển; xem ngay trên web cả trên điện thoại và tablet.
9. **Đếm lượt truy cập**: mỗi lần mở trang được ghi vào bảng `page_views`.
10. **Chạy được khi chưa có database**: nếu Supabase chưa sẵn sàng, trang công khai hiển thị dữ liệu mẫu.

### 3.2 Admin
1. Đăng nhập, đăng xuất, quên và đặt lại mật khẩu.
2. **Dashboard**:
   - Tổng đăng ký, lượt truy cập, đơn hàng.
   - **Doanh thu học phí**: chỉ cộng các đăng ký đã xác nhận, kèm số tiền đang chờ xác nhận.
   - Doanh thu Shop.
   - Biểu đồ đăng ký theo khoá, lượt truy cập theo ngày.
3. **Quản lý đăng ký**: lọc theo khoá và trạng thái, đổi trạng thái, sửa, huỷ, xem cột "Huỷ bởi".
4. **Quản lý khoá học**: thêm, sửa, xoá, **nút Copy** để tạo khoá mới nhanh.
5. **Quản lý sản phẩm**: CRUD, ẩn/hiện, ảnh theo từng màu (đường dẫn có `{mau}`).
6. **Quản lý đơn hàng**: xem chi tiết, đổi trạng thái (Mới → Đang giao → Hoàn thành, hoặc Đã huỷ).
7. **Badge trên sidebar**: số đăng ký và đơn hàng mới hiện trên menu "Đăng ký" và "Đơn hàng", tự cập nhật mỗi 30 giây, mất đi khi admin mở trang.

### 3.3 Bảo mật
- **Row Level Security** trên mọi bảng: khách chỉ đọc được khoá học và sản phẩm. Khách không đọc được đăng ký hay đơn hàng của người khác; chỉ thao tác qua hàm RPC.
- Các hàm RPC trong `supabase/schema.sql`:
  - Đăng ký: `register_course`, `find_registration`, `update_registration`, `cancel_registration`, `course_seats`.
  - Đơn hàng: `place_order`, `find_order`.
  - Admin: `is_admin`.
- Mọi dữ liệu người dùng chèn vào HTML đều qua hàm `esc()` để chống XSS.
- Chỉ đặt publishable key trên web. `supabase.txt` (mật khẩu database) nằm trong `.gitignore`, không bao giờ lên GitHub.

---

## 4. Các file .md và chức năng

| File | Chức năng |
|---|---|
| **PRD.md** | *Product Requirements Document* – tài liệu **yêu cầu sản phẩm**: website làm cho ai, mục tiêu, danh sách trang, chức năng từng trang, thao tác database (thêm/sửa/xoá/tra cứu), cấu trúc dữ liệu, đối chiếu tiêu chí chấm điểm và những gì nằm ngoài phạm vi. Trả lời câu hỏi **"web phải làm được gì?"**. Claude đọc file này trước khi viết code để làm đúng và đủ chức năng. |
| **DESIGN.md** | Tài liệu **thiết kế giao diện**: cảm hứng từ poster, cách dùng logo, bảng màu (biến CSS), font, bố cục từng trang, nút, thẻ, form, responsive. Trả lời câu hỏi **"web trông như thế nào?"**. Claude dựa vào đây để mọi trang cùng một phong cách, đúng nhận diện thương hiệu. |
| **CLAUDE.md** | File **hướng dẫn cho Claude Code**, được Claude tự đọc mỗi khi mở dự án: công nghệ, cấu trúc thư mục, quy tắc code (header/footer dùng chung, không hard-code màu, dùng `esc()`, khách chỉ gọi RPC…), lưu ý bảo mật, cách chạy thử. Giúp Claude làm đúng ngay mà không phải hỏi lại. |
| **README.md** | Hướng dẫn cho **người dùng/giảng viên**: giới thiệu dự án, link website, cách tạo database Supabase, chạy các file migration, cấu hình đăng nhập admin, chạy thử ở máy, deploy GitHub Pages và Cloudflare. |
| **PROMPTS.md** | **Nhật ký prompt**: ghi lần lượt từng prompt đã gửi cho Claude và kết quả của prompt đó (Prompt 1 → 33). |
| **REPORT.md** | **Báo cáo tổng hợp** (file này). |

Các file SQL trong `supabase/`:

| File | Nội dung |
|---|---|
| `schema.sql` | Tạo toàn bộ bảng, RLS, hàm RPC và dữ liệu mẫu (dùng cho database mới) |
| `migration-002-birth-date.sql` | Thêm cột ngày sinh |
| `migration-003-validate.sql` | Kiểm tra 18 tuổi, SĐT, email ở database |
| `migration-004-product-images.sql` | Ảnh sản phẩm theo màu (6 sản phẩm đầu) |
| `migration-005-cancel-rules.sql` | Quy tắc huỷ đăng ký, cột "Huỷ bởi" (đã gộp sẵn nội dung 003) |
| `migration-006-more-product-images.sql` | Ảnh cho 6 sản phẩm còn lại |
| `reset-admin-password.sql` | Hỗ trợ đặt lại mật khẩu admin |

---

## 5. Thứ tự các prompt và kết quả

Toàn văn từng prompt và kết quả chi tiết nằm trong [`PROMPTS.md`](PROMPTS.md). Tóm tắt theo thứ tự:

| # | Prompt (yêu cầu) | Kết quả |
|---|---|---|
| 1 | Đưa đề bài + poster, nhờ lập kế hoạch: Homepage có video YouTube, bản đồ, mạng xã hội; chi tiết 2 khoá học; module đăng ký | Kế hoạch 7 bước, chọn HTML/CSS/JS + Supabase vì GitHub Pages không ghi được dữ liệu |
| 2 | Thêm module login chỉ cho admin, có dashboard | Bổ sung đăng nhập admin (Supabase Auth + RLS), dashboard, bảng `page_views`, trang quản lý đăng ký và khoá học |
| 3 | Thêm trang Gemini Shop bán trang phục, giày nhảy cho nữ trên 18 tuổi | Bổ sung shop, chi tiết sản phẩm, giỏ hàng, bảng `products`/`orders`/`order_items`, trang admin sản phẩm và đơn hàng |
| 4 | Tạo các file .md và code website trong thư mục `website_dance` | Tạo PRD, DESIGN, CLAUDE, README, PROMPTS, REPORT; `schema.sql` (7 bảng, RLS, RPC, dữ liệu mẫu); 7 trang công khai + 6 trang admin; chặn `supabase.txt` |
| 5 | Làm module quên mật khẩu admin | Thêm trang quên mật khẩu và đặt lại mật khẩu, link "Quên mật khẩu?", mục đổi mật khẩu |
| 6 | Kết nối database Supabase | Cấu hình URL + publishable key; kiểm tra thật: đọc khoá học/sản phẩm, RLS chặn khách, đăng ký–tra cứu–sửa–huỷ đều chạy |
| 7 | Lỗi 127.0.0.1 khi đặt lại mật khẩu | Giải thích do Site URL/Redirect URLs của Supabase, hướng dẫn cấu hình lại |
| 8 | Deploy lên GitHub Pages | Push code lên repo `nthh169-dev/gemini-dance`, website chạy tại GitHub Pages |
| 9 | Quên mật khẩu luôn báo "đợi 1 phút" | Phân biệt lỗi giới hạn email của Supabase, hiện thông báo đúng nguyên nhân |
| 10 | Ô năm sinh sai component, không có lịch, có icon hình người | Đổi sang ô chọn ngày, ẩn icon Safari, thêm cột `birth_date` (migration-002) |
| 11 | Chỉ cần điền năm sinh, chặn dưới 18 tuổi, kiểm tra email và SĐT | Danh sách năm sinh, kiểm tra 18+, SĐT, email ở giao diện và database (migration-003) |
| 12 | Ô năm sinh cần nút mở popup chọn năm, vẫn gõ trực tiếp được | Ô nhập 4 chữ số + nút lịch mở bảng 12 năm, chuyển trang ‹ › |
| 13 | Ô Khoá học cao bằng ô Năm sinh, đổi placeholder Ghi chú | Mọi ô cao 52px, placeholder "Bạn đã từng học nhảy chưa? Muốn học thể loại nào" |
| 14 | Bỏ 2 dòng lịch Beginner/Advanced trong thẻ liên hệ | Thẻ liên hệ chỉ còn địa chỉ và mạng xã hội |
| 15 | Font chữ lớn nhỏ không đều, sửa cho thống nhất | Chỉ dùng Be Vietnam Pro, thống nhất cỡ chữ tiêu đề và nội dung |
| 16 | Chữ "Gemini Dance" trong logo nhỏ hơn chữ thường | Phóng to logo ở header và footer |
| 17 | Thêm nút Copy ở mỗi dòng khoá học trong admin | Nút Copy mở form với dữ liệu khoá cũ và mã khoá mới không trùng |
| 18 | Video YouTube báo "unavailable" trên Android | Đổi playlist embed sang nhúng từng video |
| 19 | Bỏ lịch học ở cuối Trang chủ và phần "Chọn lớp phù hợp"; nút "Xem lịch học" chuyển sang trang Khoá học | Tạo trang `courses.html` lấy từ database, gọn Trang chủ và footer |
| 20 | Bỏ phần lịch khai giảng ở trang Giới thiệu | Bỏ thông tin lớp, ngày giờ ở trang Giới thiệu |
| 21 | Gộp "Trang chủ" và "Về chúng tôi" thành 1 trang | Chọn gộp hẳn: nội dung Về chúng tôi vào Trang chủ, `about.html` chỉ còn chuyển hướng |
| 22 | Cập nhật ảnh sản phẩm theo tên và màu từ thư mục Shop | Ảnh riêng cho từng màu, đổi màu thì đổi ảnh (migration-004) |
| 23 | Badge số đăng ký/đơn hàng mới trên sidebar admin, mất khi đã xem | Badge trên menu Đăng ký và Đơn hàng, cập nhật mỗi 30 giây |
| 24 | Mua hàng nhưng badge Đơn hàng không hiện | Sửa cách đếm lần đầu: đếm bản ghi chưa xử lý |
| 25 | Sửa form đăng ký: placeholder "Nguyễn Thị A", "2008", tách Khoá học thành Cấp độ và Thời gian | Placeholder mới, 2 ô Cấp độ và Lịch học riêng |
| 26 | Dashboard hiện doanh thu học phí, chỉ tính đăng ký đã xác nhận | Thẻ "Doanh thu học phí" + số tiền đang chờ xác nhận |
| 27 | Đã xác nhận thì không cho huỷ; học viên huỷ thì đổi trạng thái chứ không xoá; thêm cột "Huỷ bởi" | Quy tắc huỷ ở database, cột `cancelled_by`/`cancelled_at`, cột "Huỷ bởi" trong admin (migration-005); sửa lỗi khi chạy trên database chưa có migration-003 |
| 28 | Bỏ nút "Tham gia lớp học" dưới Câu chuyện Song Tử | Đã bỏ (phía trên đã có nút) |
| 29 | Đổi SĐT thành 0900000000, email thành geminidance@example.com.vn | Cập nhật ở mọi trang |
| 30 | Hiển thị các video gần nhất dạng trượt để xem trên điện thoại/tablet | Carousel video vuốt được, có ảnh thu nhỏ, bấm là phát ngay trên web |
| 31 | Đưa website lên Cloudflare | Thêm `wrangler.jsonc`, `.assetsignore`; website chạy tại `gemini-dance.nthh169.workers.dev` |
| 32 | Đưa ảnh cho các sản phẩm còn lại, tên hiển thị theo tên ảnh | Ảnh cho 6 sản phẩm còn lại, đổi tên sản phẩm theo tên ảnh (migration-006) |
| 33 | Link Cloudflare không cập nhật ảnh mới trong khi GitHub Pages đã cập nhật | Tìm ra nguyên nhân: Cloudflare mất quyền truy cập repo GitHub nên không tự build; hướng dẫn kết nối lại và đẩy commit mới để build |

---

## 6. Chạy thử và triển khai
- Chạy ở máy: `python3 -m http.server 8000` rồi mở http://localhost:8000 (chi tiết trong `README.md`).
- Database mới: chạy `supabase/schema.sql`. Database đã có: chạy lần lượt các file migration còn thiếu.
- Triển khai: push lên nhánh `main` thì GitHub Pages và Cloudflare Workers tự cập nhật.
