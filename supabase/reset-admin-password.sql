-- =====================================================================
-- ĐẶT LẠI MẬT KHẨU ADMIN KHÔNG CẦN EMAIL
-- Dùng khi chức năng "Quên mật khẩu" bị giới hạn số email của Supabase.
-- Supabase > SQL Editor > New query > sửa EMAIL và MẬT KHẨU MỚI > Run.
-- KHÔNG lưu mật khẩu thật vào file này rồi push lên GitHub.
-- =====================================================================
update auth.users
set encrypted_password = extensions.crypt('MAT-KHAU-MOI-CUA-BAN', extensions.gen_salt('bf')),
    updated_at = now()
where email = 'email-admin-cua-ban@gmail.com';
-- Kết quả "Success. 1 row affected" là đã đổi xong. "0 rows" nghĩa là email sai.
