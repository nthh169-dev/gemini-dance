# DESIGN – Gemini Dance

> **DESIGN.md** mô tả *website trông như thế nào*: màu sắc, font, logo, bố cục, thành phần giao diện. Claude Code đọc file này để mọi trang có cùng một phong cách, đúng nhận diện thương hiệu.

## 1. Cảm hứng
Lấy từ poster và banner của Gemini Dance (`assets/img/poster.jpg`, `assets/img/hero-banner.jpg`):
nền **đêm sâu**, chòm sao **Song Tử** vàng nhạt, logo **neon gradient cyan → tím → hồng**, ánh đèn sân khấu bokeh. Cảm giác: tự tin, quyến rũ, năng lượng, trẻ trung.

## 2. Logo
- Bộ logo gốc: `image/gemini-dance-logo-pack/` → copy vào `assets/img/`.
- `logo-lockup.svg` (biểu tượng + chữ Gemini Dance) – dùng ở **header** mọi trang và trang admin.
- `logo-mark.svg` (chỉ biểu tượng ♊) – dùng ở hero, About, footer.
- `logo-icon.svg` – **favicon** mọi trang.
- Không đổi màu, không kéo méo, không thay bằng chữ thường. Luôn đặt trên nền tối.

## 3. Màu sắc (CSS variables trong `assets/css/style.css`)

| Token | Mã | Dùng cho |
|---|---|---|
| `--bg` | `#07060D` | Nền trang |
| `--bg-2` | `#0F0D1A` | Nền section xen kẽ |
| `--surface` | `#16132A` | Thẻ, form, bảng |
| `--line` | `#2A2550` | Viền mảnh |
| `--text` | `#F3F0FF` | Chữ chính |
| `--muted` | `#A9A3C9` | Chữ phụ |
| `--cyan` | `#3EE6DF` | Neon 1 (logo) |
| `--violet` | `#8A7CF0` | Neon 2 (logo) |
| `--pink` | `#E8439A` | Neon 3 (logo), nút chính |
| `--gold` | `#E8C27A` | Chòm sao, icon địa chỉ (như poster) |
| `--beginner` | `#7B3FA0` | Nhãn khoá Beginner (tím) |
| `--advanced` | `#2F5DA8` | Nhãn khoá Advanced (xanh) |

Gradient thương hiệu: `linear-gradient(90deg, #3EE6DF, #8A7CF0, #E8439A)` – dùng cho tiêu đề lớn, nút chính, viền nổi bật.

## 4. Typography
- **Một font duy nhất: Be Vietnam Pro** cho cả tiêu đề, nút, menu và nội dung. Font này hỗ trợ đầy đủ dấu tiếng Việt (ơ, ă, ả, ễ…), nên chữ có dấu không bị lệch cỡ.
  - *Không dùng Poppins*: Poppins không có bộ ký tự tiếng Việt, trình duyệt phải mượn font khác cho chữ có dấu nên chữ "lớn nhỏ" không đều.
- Độ đậm: 400 (nội dung), 500 (menu, nhãn), 600 (nút), 700 (tiêu đề), 800 (tiêu đề hero).
- Cỡ chữ: H1 `clamp(2.2rem, 5vw, 3.6rem)`, H2 `clamp(1.6rem, 3vw, 2.4rem)`, body 16px, line-height 1.65.

## 5. Thành phần giao diện
- **Header** dính trên cùng, nền đen mờ (blur), logo trái, menu phải: Trang chủ · Về chúng tôi · Khoá học · Đăng ký · Shop · 🛒 giỏ hàng (badge số lượng). Mobile: nút ☰.
- **Nút**: `.btn-primary` gradient + glow hồng; `.btn-ghost` viền neon.
- **Thẻ khoá học**: giống poster – nhãn xiên (BEGINNER tím / ADVANCED xanh) + lịch học bên phải.
- **Thẻ sản phẩm** (Shop): bo góc 18px, nền sáng hơn (`--surface`), ảnh tỉ lệ 4:5, nhãn `New` (cyan), `Hot` (hồng), `Sale` (vàng).
- **Form**: input nền tối, viền `--line`, focus viền cyan glow.
- **Toast** thông báo góc dưới phải.
- **Footer**: logo mark, địa chỉ, giờ học, icon TikTok/Facebook/YouTube, link nhỏ "Admin".

## 6. Bố cục từng trang
- **Trang chủ**: Hero (ảnh banner + slogan + 2 nút) → Khoá học (2 thẻ) → Video YouTube → Lý do chọn Gemini → Sản phẩm nổi bật → Bản đồ + liên hệ + social.
- **Về chúng tôi**: Hero nhỏ → Câu chuyện Song Tử → Ý nghĩa logo → Giá trị (3 cột) → Đội ngũ → Poster.
- **Chi tiết khoá học**: Tiêu đề + nhãn level → bảng thông tin (lịch, học phí, thời lượng, chỗ còn) → nội dung học → CTA đăng ký → chuyển sang khoá còn lại.
- **Đăng ký**: 2 tab "Đăng ký mới" / "Tra cứu – Sửa – Huỷ".
- **Shop**: thanh lọc danh mục (chip) + tìm kiếm + sắp xếp → lưới sản phẩm 4 cột (2 cột mobile).
- **Admin**: sidebar trái (Dashboard, Đăng ký, Khoá học, Sản phẩm, Đơn hàng, Đăng xuất), nội dung phải; dashboard gồm thẻ số liệu + biểu đồ Chart.js.

## 7. Phong cách Gemini Shop
Trẻ trung, trendy cho nữ 18+: giữ nền tối + neon của thương hiệu, thẻ sản phẩm sáng và mềm hơn, nhiều chip màu, giá nổi bật màu hồng, giá gốc gạch ngang khi Sale.

## 8. Responsive & trợ năng
- Breakpoints: 1024px, 768px, 480px. Không cuộn ngang trên điện thoại.
- Độ tương phản chữ ≥ 4.5:1, ảnh có `alt`, nút có nhãn rõ ràng, focus nhìn thấy được.
