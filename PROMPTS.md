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

## Prompt 9 – Sửa lỗi "Quên mật khẩu" luôn báo đợi 1 phút (24/11/2026)
**Prompt:**
> Phần quên mật khẩu không work. Khi nhập mail và bấm nút "gửi link đặt lại mật khẩu" thì lúc nào cũng ra message "bạn vừa yêu cầu rồi. Vui lòng đợi khoảng 1 phút rồi thử lại"

**Kết quả:** Nguyên nhân: email miễn phí của Supabase chỉ gửi được vài thư mỗi giờ cho cả project. Khi vượt giới hạn, Supabase trả lỗi *email rate limit exceeded*, nhưng code cũ gộp mọi lỗi có chữ "rate" thành thông báo "đợi 1 phút" nên hiểu sai. Claude sửa `admin/forgot-password.html` để phân biệt giới hạn theo giờ và giới hạn 1 phút, hiện đúng lỗi khác, ghi lỗi vào console. Thêm file `supabase/reset-admin-password.sql` để đặt mật khẩu admin trực tiếp bằng SQL khi không gửi được email.

---

## Prompt 10 – Sửa ô năm sinh ở trang Đăng ký (24/11/2026)
**Prompt:**
> https://nthh169-dev.github.io/gemini-dance/register.html — Màn hình trên chỗ năm sinh component sai. Ko có calendar để chọn ngoài ra có icon hình người hiển thị ko hợp lý

**Kết quả:**
- Đổi ô "Năm sinh" (ô số) thành **"Ngày sinh"** dùng `input type="date"` có lịch để chọn, giới hạn từ 1950 đến đủ 16 tuổi, giao diện lịch tối hợp màu web.
- Ẩn icon danh bạ hình người mà Safari tự chèn vào ô nhập; thêm `autocomplete` đúng cho họ tên, SĐT, email, ngày sinh.
- Database: thêm cột `birth_date` và cập nhật hàm RPC (`supabase/migration-002-birth-date.sql`). Trước khi chạy migration, web tự gửi năm sinh như cũ nên đăng ký vẫn hoạt động.
- Trang admin Quản lý đăng ký hiển thị và sửa được ngày sinh.
- Đã chạy thử SQL trên PostgreSQL và thử form bằng trình duyệt tự động (cả khi DB đã/ chưa chạy migration).

---

## Prompt 11 – Chỉ chọn năm sinh, chặn dưới 18 tuổi, kiểm tra email & SĐT (24/11/2026)
**Prompt:**
> component chọn ngày tháng năm sinh vẫn chưa work đúng. User đánh số năm vẫn bất tiện bạn hãy thay đổi lại để chỉ cần điền năm sinh. Và check dưới 18 tuổi thì ko cho đăng ký. Ngoài ra check format e mail và format số đien thoại luôn

**Kết quả:**
- Ô ngày sinh đổi thành **danh sách chọn năm sinh** (không phải gõ), chỉ có các năm đủ 18 tuổi, kèm dòng nhắc "Chỉ nhận học viên từ 18 tuổi".
- **Kiểm tra định dạng**: SĐT Việt Nam 10 số bắt đầu 03/05/07/08/09 (chấp nhận gõ có khoảng trắng, dấu chấm hoặc +84); email dạng `ten@domain.xx`. Báo lỗi màu hồng ngay dưới ô khi rời ô hoặc bấm gửi. Áp dụng cho form đăng ký, form sửa đăng ký, form đặt hàng và trang admin.
- **Database cũng kiểm tra** (`supabase/migration-003-validate.sql`): hàm RPC từ chối dưới 18 tuổi, SĐT/email sai định dạng và báo lỗi tiếng Việt; SĐT được chuẩn hoá trước khi lưu và khi tra cứu.
- Đã chạy thử SQL trên PostgreSQL (DB gốc, DB đã chạy migration-002, DB mới) và thử form bằng trình duyệt tự động.

---

## Prompt 12 – Ô năm sinh có nút mở bảng chọn năm (24/11/2026)
**Prompt:**
> Năm sinh hiện thế này là sai UI rồi. Bạn hãy sửa lại để kế bên ô năm sinh có nút cho chọn năm sinh. Nếu user bấm nút thì hiện popup cho user chọn năm sinh. Nếu ko bấm nút thì user có thể nhập trực tiếp vào ô *(kèm ảnh chụp danh sách năm dài trên Safari)*

**Kết quả:** Thay danh sách thả xuống bằng ô nhập năm sinh (chỉ nhận 4 chữ số) + nút lịch bên cạnh. Bấm nút hiện popup bảng 12 năm (3 cột) theo màu thương hiệu, có nút ‹ › để chuyển trang năm, chỉ hiện năm đủ 18 tuổi; chọn năm thì điền vào ô và đóng popup (bấm ra ngoài hoặc Esc cũng đóng). Gõ năm dưới 18 tuổi hoặc sai định dạng thì báo lỗi ngay. Áp dụng cho form đăng ký, form sửa đăng ký và trang admin. Đã thử bằng trình duyệt tự động ở khổ máy tính và điện thoại.

---

## Prompt 13 – Chỉnh chiều cao ô Khoá học và placeholder Ghi chú (24/11/2026)
**Prompt:**
> Field khoá học cho chiều cao cao hơn 1 chút để cho tương xứng với field năm sinh. Place holder của phần ghi chú sửa lại là "Bạn đã từng học nhảy chưa? Muốn học thể loại nào"

**Kết quả:** Mọi ô nhập và ô chọn dùng chung chiều cao 52px nên Khoá học thẳng hàng với Năm sinh (kể cả trên Safari, nhờ bỏ giao diện select mặc định và thêm mũi tên màu cyan). Placeholder Ghi chú đổi thành "Bạn đã từng học nhảy chưa? Muốn học thể loại nào?".

---

## Prompt 14 – Bỏ lịch học trong thẻ liên hệ (24/11/2026)
**Prompt:**
> Bỏ 2 dòng beginer và advance ở đây đi *(kèm ảnh thẻ "Gemini Dance Studio" ở Trang chủ)*

**Kết quả:** Xoá 2 dòng lịch Beginner / Advanced trong thẻ "Gemini Dance Studio" ở phần Liên hệ của Trang chủ; thẻ chỉ còn địa chỉ và các mạng xã hội.

---

## Prompt 15 – Thống nhất font chữ (24/11/2026)
**Prompt:**
> UI ko tốt chữ lớn chữ nhỏ hãy sửa lại font chữ lại cho đồng đều và thống nhất *(kèm ảnh tiêu đề "Beginner – Lớp Căn Bản")*

**Kết quả:** Nguyên nhân: tiêu đề dùng font Poppins, font này không có đủ dấu tiếng Việt nên các chữ như "ơ", "ă", "ả" bị trình duyệt lấy từ font khác, nhìn lúc to lúc nhỏ. Đã bỏ Poppins, toàn bộ website (trang khách + admin, cả logo chữ SVG) chỉ dùng một font **Be Vietnam Pro** (400–800), cập nhật CLAUDE.md và DESIGN.md theo.

---

## Prompt 16 – Phóng to logo chữ "Gemini Dance" (24/11/2026)
**Prompt:**
> Chữ Gemini Dance chỗ này là tên thương hiệu mà nhỏ hơn các chữ bình thường nên rất kỳ. Hãy sửa lại cho thương thích *(kèm ảnh logo ở footer)*

**Kết quả:** Logo ở footer tăng từ 38px lên 64px, logo ở header tăng từ 40px lên 48px, nên chữ "Gemini Dance" trong logo giờ lớn hơn chữ nội dung và nổi bật đúng vai trò tên thương hiệu. Vẫn dùng đúng file logo gốc trong `assets/img/`.

---

## Prompt 17 – Nút Copy khoá học ở trang admin (24/11/2026)
**Prompt:**
> Trang course dành cho admin này hãy thêm ở mỗi dòng của khoá học một nút copy nữa, để khi tạo khoá mới mình copy đỡ phải sửa

**Kết quả:** Mỗi dòng trong `admin/courses.html` có thêm nút **Copy** (giữa Sửa và Xoá). Bấm Copy sẽ mở form "Thêm khoá học" đã điền sẵn toàn bộ thông tin của khoá đó (lịch, học phí, mô tả, nội dung học…). Tên khoá thêm chữ "(bản sao)", slug tự đổi thành `<slug>-copy` (hoặc `-copy-2`, `-copy-3`… nếu đã có) để không trùng. Bấm Lưu sẽ tạo khoá **mới**, khoá gốc không bị thay đổi.

---

## Prompt 18 – Sửa video YouTube "unavailable" trên Android (24/11/2026)
**Prompt:**
> Phần hiển thị video youtube trên trang home, tại sao trên android lại hien this video is unavailabel *(kèm ảnh chụp trên Android)*

**Kết quả:** Nguyên nhân: video đang nhúng dạng playlist "Uploads" của kênh (`embed/videoseries?list=UU…`). Trình phát YouTube trên điện thoại (nhất là Android) thường không mở được kiểu playlist này nên báo "This video is unavailable", dù trên máy tính vẫn chạy. Đã đổi sang nhúng trực tiếp video mới nhất của kênh (`embed/MbON2SK5HSQ`) trong `assets/js/config.js`, kèm ghi chú cách đổi sang video khác.

---

## Prompt 19 – Tách trang Khoá học, gọn Trang chủ và footer (24/11/2026)
**Prompt:**
> 1. Phần lịch học hiển thị ở cuối màn hình home sẽ không còn đúng nữa nếu admin thêm khoá học mới hoặc thay đổi nội dung nên bạn hãy xoá phần lịch học ở đây đi
> 2. Phần "Chọn lớp phù hợp với bạn" nếu hiển thị ở đây, khi admin add thêm nhiều lớp sẽ tràn lan và làm dài trang web ra nên hãy bỏ phần này ra khỏi trang chủ
> Thêm vào đó khi nhấn nút "xem lịch học" ở dưới chữ Gemini Dance ở đầu trang, hãy điều hướng qua Trang khoá học

**Kết quả:**
- Footer: bỏ cột "Lịch học" viết cứng; link "Khoá Beginner / Khoá Advanced" gộp thành "Khoá học & lịch học".
- Trang chủ: bỏ phần "Chọn lớp phù hợp với bạn"; nút "Xem lịch học" chuyển sang trang mới `courses.html`.
- Trang mới `courses.html`: liệt kê mọi khoá đang hiển thị lấy từ database, có nút lọc Tất cả / Beginner / Advanced. Menu "Khoá học", nút ở trang Giới thiệu và nút "Về danh sách khoá học" ở trang chi tiết đều trỏ về trang này.

---

## Prompt 20 – Bỏ "Lịch khai giảng" ở trang Giới thiệu (24/11/2026)
**Prompt:**
> Khu vực này ở trang phía trên nếu để cố định lịch khai giảng như thế này thì khi admin add thêm khoá mới sẽ ko đúng nữa. Bỏ nguyên phần này đi hoặc bỏ thông tin lớp, thời gian và ngày đi *(kèm ảnh phần "Poster tuyển sinh" ở about.html)*

**Kết quả:** Bỏ nguyên phần "Poster tuyển sinh / Lịch khai giảng" khỏi `about.html`, vì ảnh poster cũng in sẵn lịch học nên chỉ bỏ chữ thì vẫn sai khi đổi khoá. Lịch học giờ chỉ hiển thị ở trang Khoá học (lấy từ database). Ảnh `assets/img/poster.jpg` vẫn giữ trong thư mục để dùng cho báo cáo.

---

## Prompt 21 – Gộp "Trang chủ" và "Về chúng tôi" (24/11/2026)
**Prompt:**
> Do nội dung "Trang chủ" và "Về chúng tôi" cũng ngắn nên bạn có thể gom chung thành 1 trang dùm mình đc ko

**Kết quả:** Claude nhắc rằng đề bài chấm riêng tiêu chí "≥ 3 trang: Home, About, Detail" và đề xuất giữ about.html. Hạnh chọn **gộp hẳn**. Toàn bộ nội dung About (câu chuyện Song Tử, ý nghĩa logo, giá trị cốt lõi, đội ngũ) chuyển vào Trang chủ, ngay dưới banner, tại mục `#ve-chung-toi`. Menu bỏ mục "Về chúng tôi"; link ở footer trỏ về `index.html#ve-chung-toi`; `about.html` chỉ còn tự chuyển hướng về đó để link cũ không bị hỏng. Cập nhật PRD, REPORT, README, CLAUDE.md.

---

## Prompt 22 – Gắn ảnh thật cho sản phẩm theo từng màu (24/11/2026)
**Prompt:**
> Mình có upload một số hình dành cho sản phẩm trong folder shop, tên sản phẩm ứng với sản phẩm trong shop mà màu tương ứng với màu từng sản phẩm. Bạn hãy update hình ảnh vào đúng tên sản phẩm và tên màu giúp mình

**Kết quả:**
- 12 ảnh PNG (~7MB/ảnh) trong `Shop/` được nén thành JPG 900×1200 (~60–130KB) tại `assets/img/products/<tên-sản-phẩm>-<màu>.jpg`, tên file viết không dấu (VD: `sneaker-gemini-den-hong.jpg`).
- `image_url` của sản phẩm hỗ trợ ký hiệu `{mau}`, VD `assets/img/products/sport-bra-{mau}.jpg`: trang Shop hiện ảnh màu đầu tiên; trang chi tiết đổi ảnh khi bấm chọn màu; giỏ hàng hiện ảnh đúng màu đã chọn. Màu nào chưa có ảnh sẽ dùng ảnh của màu đầu tiên.
- `supabase/migration-004-product-images.sql`: gắn ảnh cho 6 sản phẩm (Bodysuit Gemini, Áo lưới bling bling, Quần short dance, Quần short bling bling, Sport bra, Sneaker Gemini). Dữ liệu mẫu trong `schema.sql` và `app.js` cũng đổi theo tên/màu mới.
- Form admin Sản phẩm có hướng dẫn cách dùng `{mau}`.

---

## Prompt 23 – Badge số record mới trên sidebar admin (24/11/2026)
**Prompt:**
> Đối với sidebar của trang admin. Khi có đơn hàng mới hoặc có người đăng ký khoá học mới thì ở menu Đăng ký và Đơn hàng, hãy hiện badge count số record mới. Nếu admin đã click vào menu để xem thì badge sẽ mất

**Kết quả:** Sidebar admin (`assets/js/admin.js`) hiện badge hồng đếm số đăng ký / đơn hàng mới bên cạnh menu **Đăng ký** và **Đơn hàng**. "Mới" = tạo sau lần cuối admin mở trang đó (mốc lưu trong trình duyệt theo email admin). Mở trang Đăng ký hoặc Đơn hàng thì badge của menu đó mất. Badge tự cập nhật mỗi 30 giây. Lần đầu đăng nhập trên một trình duyệt, mọi record cũ được coi là đã xem.

---

## Prompt 24 – Sửa badge Đơn hàng không hiện (24/11/2026)
**Prompt:**
> Mình mua sản phẩm nhưng ko thấy badge hiển thị ở đơn hàng *(kèm ảnh Dashboard)*

**Kết quả:** Nguyên nhân: ở lần đầu mở admin trên một trình duyệt, code coi mọi record đã có là "đã xem", nên đơn đặt trước lần mở đó bị bỏ qua. Sửa lại: khi chưa có mốc "đã xem", badge đếm các record **chưa xử lý** (đăng ký "Chờ xác nhận", đơn "Mới"). Từ lần mở trang Đăng ký / Đơn hàng trở đi mới tính theo thời điểm. Đổi tên khoá lưu trong trình duyệt để mọi máy admin tính lại theo cách mới.

---

## Prompt 25 – Sửa form đăng ký: placeholder và tách ô Khoá học (24/11/2026)
**Prompt:**
> Chỗ form đăng ký lớp học này hãy sửa lại 3 chỗ: Placeholder ở chỗ Họ và tên hãy sửa lại là Nguyễn Thị A. Placeholder ở chỗ năm sinh hãy đổi lại thành 2008. Trường khoá học chữ bị khuất rồi cho nên khoá học hãy tách thành 2 field: field cấp độ và field thời gian

**Kết quả:** Placeholder Họ và tên → "Nguyễn Thị A"; Năm sinh → "2008". Ô "Khoá học" tách thành **Cấp độ** (Beginner / Advanced, lấy từ các khoá đang mở) và **Lịch học** (ngày · giờ của các lớp thuộc cấp độ đã chọn, ô rộng hết dòng nên không bị khuất chữ). Đổi cấp độ thì danh sách lịch học đổi theo. Form sửa đăng ký ở tab "Tra cứu · Sửa · Huỷ" cũng dùng 2 ô này. Link `register.html?course=<id>` vẫn tự chọn đúng cấp độ và lịch.

---

## Prompt 26 – *(thêm tiếp ở đây)*
**Prompt:**
> …

**Kết quả:** …
