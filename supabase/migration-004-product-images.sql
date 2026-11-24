-- =====================================================================
-- Gemini Dance – migration 004: gắn ảnh thật cho sản phẩm Gemini Shop
-- Chạy 1 lần trong Supabase > SQL Editor (an toàn khi chạy lại).
-- {mau} được website thay bằng tên màu viết không dấu:
--   "Đen" -> den, "Đen Hồng" -> den-hong  =>  sneaker-gemini-den-hong.jpg
-- Ảnh nằm trong assets/img/products/ (đã đưa lên GitHub Pages).
-- =====================================================================
update public.products set image_url = 'assets/img/products/bodysuit-gemini-{mau}.jpg'        where name = 'Bodysuit Gemini';
update public.products set image_url = 'assets/img/products/ao-luoi-bling-bling-{mau}.jpg'    where name = 'Áo lưới bling bling';
update public.products set image_url = 'assets/img/products/quan-short-dance-{mau}.jpg'       where name = 'Quần short dance';
update public.products set image_url = 'assets/img/products/quan-short-bling-bling-{mau}.jpg' where name = 'Quần short bling bling';
update public.products set image_url = 'assets/img/products/sport-bra-{mau}.jpg'              where name = 'Sport bra';
update public.products set image_url = 'assets/img/products/sneaker-gemini-{mau}.jpg'         where name = 'Sneaker Gemini';

-- Kiểm tra:
select id, name, colors, image_url from public.products order by id;
