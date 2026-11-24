-- =====================================================================
-- Gemini Dance – migration 006: ảnh cho 6 sản phẩm còn lại (1 ảnh dùng chung mọi màu)
-- Chạy trong Supabase > SQL Editor (an toàn khi chạy lại).
-- =====================================================================
update public.products set image_url = 'assets/img/products/giay-heels-dance-9cm.jpg'      where name = 'Giày Heels Dance 9cm';
update public.products set image_url = 'assets/img/products/giay-jazz-da-mem.jpg'          where name = 'Giày Jazz da mềm';
update public.products set image_url = 'assets/img/products/tat-dui-thigh-high.jpg'        where name = 'Tất đùi Thigh-high';
update public.products set image_url = 'assets/img/products/gang-tay-luoi-bling-bling.jpg' where name = 'Găng tay lưới bling bling';
update public.products set image_url = 'assets/img/products/kneepad-bao-ve-goi.jpg'        where name = 'Kneepad bảo vệ gối';
update public.products set image_url = 'assets/img/products/tui-tap-gemini-duffle.jpg'     where name = 'Túi tập Gemini Duffle';

-- Kiểm tra:
select id, name, image_url from public.products order by id;
