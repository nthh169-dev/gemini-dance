# PROMPTS – Nhật ký prompt với Claude

> **PROMPTS.md** ghi lại *thứ tự các prompt* đã gửi cho Claude và *kết quả* của từng prompt (yêu cầu bắt buộc trong báo cáo). Mỗi lần gửi prompt mới, thêm một mục vào cuối file. Gợi ý: chụp màn hình kết quả, lưu vào `docs/screenshots/` và chèn link vào mục tương ứng.

---

## Prompt 1 – Lập kế hoạch (24/11/2026)
**Prompt:**
> *(dán đề bài đồ án)* … Mình đang học claudecode và mình cần làm bài cuối khoá. Đề bài mình như trên. Bạn hãy giúp mình lập kế hoạch các bước làm để mình đọc trước.
> Website mình gồm:
> + Homepage: Có nhúng video trên youtube, nhúng bản đồ (Design như hình đính kèm), thông tin tiktok, facebook, youtube
> + chi tiết các khoá học. Gồm 2 lớp căn bản nâng cao (thông tin như hình đính kèm)
> + Module đăng ký khoá học
>
> *(đính kèm poster Gemini Dance)*

**Kết quả:** Claude đưa ra kế hoạch 7 bước: (1) chuẩn bị repo + logo, (2) viết PRD.md, DESIGN.md, README.md, CLAUDE.md, (3) chọn công nghệ HTML/CSS/JS + Supabase (vì GitHub Pages không ghi được CSV/SQLite), (4) làm 4 trang Home / About / Chi tiết khoá học / Đăng ký (insert + update + delete), (5) kiểm tra, (6) deploy GitHub Pages, (7) viết báo cáo. Kèm lịch làm từ 24 → 29/11 và lưu ý sửa chữ "BEGINER" → "BEGINNER".

---

## Prompt 2 – Thêm module admin (24/11/2026)
**Prompt:**
> Hãy tạo thêm một module login chỉ dành cho admin, có những trang thêm như dashboard (số lượng người đăng ký, người vào trang...)

**Kết quả:** Claude bổ sung Bước 4b vào kế hoạch: đăng nhập admin bằng Supabase Auth, bảo mật bằng RLS, Dashboard (tổng đăng ký theo khoá, lượt truy cập ghi vào bảng `page_views`, biểu đồ Chart.js), trang quản lý đăng ký và quản lý khoá học. Link "Admin" chỉ đặt nhỏ ở footer.

---

## Prompt 3 – Thêm Gemini Shop (24/11/2026)
**Prompt:**
> À thêm cho mình trang gemini shop nữa. Đó sẽ là nơi chứa các sản phẩm trang phục, giày dép nhảy múa. Phong cách trẻ trung trendy dành cho nữ trên 18 tuổi

**Kết quả:** Claude bổ sung Bước 4c: trang `shop.html` (lọc danh mục, sắp xếp giá), `product.html` (chọn size/màu/số lượng), `cart.html` (giỏ hàng + đặt hàng), bảng `products`, `orders`, `order_items`, trang admin quản lý sản phẩm & đơn hàng, dashboard thêm doanh thu / sản phẩm bán chạy; định hướng phong cách trẻ trung (nhãn New / Hot / Sale) và gợi ý 10–12 sản phẩm mẫu.

---

## Prompt 4 – Viết file .md và code website (24/11/2026)
**Prompt:**
> /Users/gemini_hanh/Documents/website_dance
> Mình đã tạo repo GitHub và để thông tin access vào folder trên file supabase.txt
> Mình cũng đã copy link của các trang social vào link.txt
> Bạn hãy tạo file md vào folder trên. Sau đó thực hiện tạo trang web file lưu trên folder đó trước và ghi lại những file những mô tả theo như đề bài đã ghi

**Kết quả:** Claude đọc `link.txt`, `supabase.txt`, poster và bộ logo trong `image/`, rồi tạo toàn bộ dự án trong thư mục `website_dance`:
- File .md: `PRD.md`, `DESIGN.md`, `CLAUDE.md`, `README.md`, `PROMPTS.md`, `REPORT.md`.
- `supabase/schema.sql`: 7 bảng, RLS, 7 hàm RPC, dữ liệu mẫu 2 khoá học + 12 sản phẩm (đã chạy thử trên PostgreSQL: khách không đọc được dữ liệu người khác, admin xem/sửa/xoá được).
- 7 trang công khai: `index`, `about`, `course`, `register`, `shop`, `product`, `cart`.
- 6 trang admin: `login`, `dashboard`, `registrations`, `courses`, `products`, `orders`.
- `assets/`: CSS theo DESIGN.md, JS dùng chung (header/footer, đếm lượt xem, giỏ hàng), logo copy từ logo pack.
- `.gitignore` chặn `supabase.txt` để mật khẩu database không bị đưa lên GitHub.
- Kiểm tra bằng trình duyệt tự động ở khổ desktop và điện thoại: không lỗi JavaScript, không cuộn ngang.

---

## Prompt 5 – Module quên mật khẩu admin (24/11/2026)
**Prompt:**
> Bạn hãy làm thêm module quên password dành cho admin. Vì mình đã quên password mình đặt trên supabase rồi

**Kết quả:** Claude thêm 2 trang:
- `admin/forgot-password.html`: nhập email admin → Supabase gửi thư chứa link đặt lại mật khẩu (không tiết lộ email có tồn tại hay không).
- `admin/reset-password.html`: mở từ link trong email → nhập mật khẩu mới 2 lần → lưu → quay về trang đăng nhập. Báo lỗi rõ khi link hết hạn.
- Trang đăng nhập có link "Quên mật khẩu?", sidebar admin có mục "🔑 Đổi mật khẩu".
- README thêm bước cấu hình *Authentication → URL Configuration* trên Supabase. Đã chạy thử luồng gửi link và đổi mật khẩu bằng trình duyệt tự động.

---

## Prompt 6 – Kết nối database Supabase (24/11/2026)
**Prompt:**
> Mình đã tạo database trên supabase và đã insert admin vào bảng admin bạn hãy kết nối với database trên subabase giúp mình

**Kết quả:** Website đã được cấu hình sẵn URL + publishable key trong `assets/js/config.js`. Claude kiểm tra kết nối thật tới Supabase:
- Đọc được 2 khoá học và 12 sản phẩm.
- Khách **không** đọc được `registrations`, `orders`, `page_views`, `admins` (RLS hoạt động).
- Chạy thử đăng ký → tra cứu → sửa → huỷ qua RPC: tất cả thành công, bản ghi thử đã được xoá.

---

## Prompt 7 – Lỗi 127.0.0.1 khi đặt lại mật khẩu (24/11/2026)
**Prompt:**
> khi mình thử đặt lại mật khẩu thì bị lỗi không thể truy cập trang web này 127.0.0.1. Lý do vì sao bị lỗi này và cách fix là gì

**Kết quả:** Claude giải thích: link trong email quay về *Site URL* mặc định của Supabase (`127.0.0.1:3000`) vì địa chỉ web chưa nằm trong danh sách Redirect URLs. Cách sửa: cấu hình *Authentication → URL Configuration* (Site URL + Redirect URLs), chạy web bằng `python3 -m http.server 8000`, gửi lại link quên mật khẩu.

---

## Prompt 8 – Deploy lên GitHub Pages (24/11/2026)
**Prompt:**
> Vậy bạn hãy deploy lên github page dùm mình
> https://github.com/nthh169-dev/gemini-dance.git

**Kết quả:** Claude push toàn bộ code lên repo Public `nthh169-dev/gemini-dance` (không kèm `supabase.txt`), điền link vào README/REPORT. Hạnh bật *Settings → Pages* (branch `main`, root). Claude mở thử website https://nthh169-dev.github.io/gemini-dance/ : 9 trang đều tải được, không lỗi JavaScript, dữ liệu lấy từ Supabase thật.

---

## Prompt 9 – *(thêm tiếp ở đây)*
**Prompt:**
> …

**Kết quả:** …
