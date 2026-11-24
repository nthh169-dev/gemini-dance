-- =====================================================================
-- Gemini Dance – migration 005: quy tắc huỷ đăng ký
--  1. Đăng ký "Đã xác nhận" thì học viên KHÔNG được huỷ (và không được sửa).
--  2. Học viên tự huỷ: KHÔNG xoá record, chỉ chuyển trạng thái sang "Đã huỷ".
--  3. Ghi lại ai huỷ (cột cancelled_by: 'student' = học viên, 'admin' = admin) và lúc nào (cancelled_at).
-- Chạy 1 lần trong Supabase > SQL Editor (an toàn khi chạy lại).
-- File này ĐÃ GỒM LUÔN nội dung migration-003 (norm_phone, check_contact, check_age...),
-- nên không cần chạy migration-003 trước.
-- =====================================================================
-- ---------- Phần A: bảo đảm có cột birth_year (DB cũ có thể đang dùng birth_date) ----------
alter table public.registrations add column if not exists birth_year int;
do $$
begin
  if exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'registrations' and column_name = 'birth_date') then
    execute 'update public.registrations set birth_year = extract(year from birth_date)::int
             where birth_year is null and birth_date is not null';
  end if;
end $$;

-- ---------- Phần B: nội dung migration-003 (hàm kiểm tra + RPC) ----------

-- Chuẩn hoá SĐT: bỏ khoảng trắng/dấu chấm/gạch, +84 -> 0
create or replace function public.norm_phone(p text)
returns text language sql immutable as $$
  select regexp_replace(regexp_replace(coalesce(p,''), '[\s.\-()]', '', 'g'), '^\+?84', '0');
$$;

-- Kiểm tra dữ liệu đăng ký, báo lỗi tiếng Việt
create or replace function public.check_contact(p_phone text, p_email text)
returns void language plpgsql immutable as $$
begin
  if public.norm_phone(p_phone) !~ '^0(3|5|7|8|9)[0-9]{8}$' then
    raise exception 'Số điện thoại không hợp lệ (cần 10 số, bắt đầu bằng 03, 05, 07, 08 hoặc 09)';
  end if;
  if nullif(trim(p_email),'') is not null
     and trim(p_email) !~* '^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$' then
    raise exception 'Email không đúng định dạng (ví dụ: ten@gmail.com)';
  end if;
end $$;

create or replace function public.check_age(p_birth_year int)
returns void language plpgsql stable as $$
begin
  if p_birth_year is null then raise exception 'Vui lòng chọn năm sinh'; end if;
  if extract(year from current_date)::int - p_birth_year < 18 then
    raise exception 'Gemini Dance chỉ nhận học viên từ 18 tuổi trở lên';
  end if;
  if p_birth_year < 1950 then raise exception 'Năm sinh không hợp lệ'; end if;
end $$;

-- Xoá mọi phiên bản cũ của các hàm (năm sinh dạng số / ngày sinh dạng date)
drop function if exists public.register_course(text, text, text, int, int, text);
drop function if exists public.register_course(text, text, text, date, int, text);
drop function if exists public.update_registration(text, text, text, text, int, int, text);
drop function if exists public.update_registration(text, text, text, text, date, int, text);

-- Đăng ký khoá học (INSERT)
create or replace function public.register_course(
  p_full_name text, p_phone text, p_email text, p_birth_year int, p_course_id int, p_note text)
returns json language plpgsql security definer set search_path = public as $$
declare r public.registrations;
begin
  perform check_contact(p_phone, p_email);
  perform check_age(p_birth_year);
  if not exists (select 1 from courses where id = p_course_id and is_active) then
    raise exception 'Khoá học không tồn tại';
  end if;
  insert into registrations(full_name, phone, email, birth_year, course_id, note)
  values (trim(p_full_name), norm_phone(p_phone), nullif(lower(trim(p_email)),''), p_birth_year, p_course_id, nullif(trim(p_note),''))
  returning * into r;
  return json_build_object('code', r.code, 'id', r.id);
end $$;

-- Tra cứu (SELECT)
create or replace function public.find_registration(p_code text, p_phone text)
returns json language sql stable security definer set search_path = public as $$
  select row_to_json(x) from (
    select r.code, r.full_name, r.phone, r.email, r.birth_year, r.course_id, r.note, r.status,
           r.created_at, r.updated_at, c.name as course_name, c.schedule_days, c.schedule_time
    from registrations r join courses c on c.id = r.course_id
    where r.code = upper(trim(p_code)) and norm_phone(r.phone) = norm_phone(p_phone)
  ) x;
$$;

-- Sửa (UPDATE)
create or replace function public.update_registration(
  p_code text, p_phone text, p_full_name text, p_email text, p_birth_year int, p_course_id int, p_note text)
returns boolean language plpgsql security definer set search_path = public as $$
begin
  perform check_contact(p_phone, p_email);
  perform check_age(p_birth_year);
  update registrations set
    full_name = trim(p_full_name), email = nullif(lower(trim(p_email)),''), birth_year = p_birth_year,
    course_id = p_course_id, note = nullif(trim(p_note),''), status = 'pending', updated_at = now()
  where code = upper(trim(p_code)) and norm_phone(phone) = norm_phone(p_phone);
  return found;
end $$;

-- Huỷ (DELETE)
create or replace function public.cancel_registration(p_code text, p_phone text)
returns boolean language plpgsql security definer set search_path = public as $$
begin
  delete from registrations where code = upper(trim(p_code)) and norm_phone(phone) = norm_phone(p_phone);
  return found;
end $$;

-- Đặt hàng (INSERT orders + order_items, UPDATE tồn kho)
-- p_items: [{"product_id":1,"size":"S","color":"Đen","qty":2}, ...]
create or replace function public.place_order(
  p_name text, p_phone text, p_email text, p_address text, p_note text, p_items jsonb)
returns json language plpgsql security definer set search_path = public as $$
declare
  o public.orders; it jsonb; p public.products; v_qty int; v_price int; v_total int := 0;
begin
  perform check_contact(p_phone, p_email);
  if jsonb_array_length(coalesce(p_items,'[]'::jsonb)) = 0 then raise exception 'Giỏ hàng trống'; end if;
  insert into orders(customer_name, phone, email, address, note)
  values (trim(p_name), norm_phone(p_phone), nullif(lower(trim(p_email)),''), trim(p_address), nullif(trim(p_note),''))
  returning * into o;
  for it in select * from jsonb_array_elements(p_items) loop
    v_qty := greatest(1, (it->>'qty')::int);
    select * into p from products where id = (it->>'product_id')::int and is_active for update;
    if not found then raise exception 'Sản phẩm không tồn tại'; end if;
    if p.stock < v_qty then raise exception 'Sản phẩm "%" chỉ còn % cái', p.name, p.stock; end if;
    v_price := coalesce(p.sale_price, p.price);
    insert into order_items(order_id, product_id, product_name, size, color, qty, unit_price)
    values (o.id, p.id, p.name, it->>'size', it->>'color', v_qty, v_price);
    update products set stock = stock - v_qty where id = p.id;
    v_total := v_total + v_price * v_qty;
  end loop;
  update orders set total = v_total where id = o.id;
  return json_build_object('code', o.code, 'total', v_total);
end $$;

-- Tra cứu đơn hàng
create or replace function public.find_order(p_code text, p_phone text)
returns json language sql stable security definer set search_path = public as $$
  select row_to_json(x) from (
    select o.code, o.customer_name, o.address, o.total, o.status, o.created_at,
      (select json_agg(json_build_object('name',i.product_name,'size',i.size,'color',i.color,'qty',i.qty,'price',i.unit_price))
         from order_items i where i.order_id = o.id) as items
    from orders o where o.code = upper(trim(p_code)) and norm_phone(o.phone) = norm_phone(p_phone)
  ) x;
$$;

revoke all on function public.register_course, public.find_registration, public.update_registration,
  public.cancel_registration, public.place_order, public.find_order from public;
grant execute on function public.register_course, public.find_registration, public.update_registration,
  public.cancel_registration, public.place_order, public.find_order, public.norm_phone,
  public.check_contact, public.check_age to anon, authenticated;

-- ---------- Phần C: quy tắc huỷ đăng ký ----------

alter table public.registrations add column if not exists cancelled_by text;
alter table public.registrations add column if not exists cancelled_at timestamptz;
alter table public.registrations drop constraint if exists registrations_cancelled_by_check;
alter table public.registrations add constraint registrations_cancelled_by_check
  check (cancelled_by is null or cancelled_by in ('student', 'admin'));

-- Tự điền ai huỷ khi trạng thái chuyển sang 'cancelled'
-- (admin đổi trạng thái trong trang quản trị => 'admin'; hàm cancel_registration của học viên => 'student')
create or replace function public.registrations_cancel_audit()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.status = 'cancelled' and (tg_op = 'INSERT' or old.status is distinct from 'cancelled') then
    new.cancelled_by := coalesce(new.cancelled_by, case when public.is_admin() then 'admin' else 'student' end);
    new.cancelled_at := coalesce(new.cancelled_at, now());
  elsif new.status <> 'cancelled' then
    new.cancelled_by := null;
    new.cancelled_at := null;
  end if;
  return new;
end $$;
drop trigger if exists trg_registrations_cancel_audit on public.registrations;
create trigger trg_registrations_cancel_audit before insert or update of status on public.registrations
  for each row execute function public.registrations_cancel_audit();

-- Tra cứu: trả thêm cancelled_by / cancelled_at
create or replace function public.find_registration(p_code text, p_phone text)
returns json language sql stable security definer set search_path = public as $$
  select row_to_json(x) from (
    select r.code, r.full_name, r.phone, r.email, r.birth_year, r.course_id, r.note, r.status,
           r.cancelled_by, r.cancelled_at,
           r.created_at, r.updated_at, c.name as course_name, c.schedule_days, c.schedule_time
    from registrations r join courses c on c.id = r.course_id
    where r.code = upper(trim(p_code)) and norm_phone(r.phone) = norm_phone(p_phone)
  ) x;
$$;

-- Sửa: chỉ khi còn "Chờ xác nhận"
create or replace function public.update_registration(
  p_code text, p_phone text, p_full_name text, p_email text, p_birth_year int, p_course_id int, p_note text)
returns boolean language plpgsql security definer set search_path = public as $$
declare v_status text;
begin
  select status into v_status from registrations
   where code = upper(trim(p_code)) and norm_phone(phone) = norm_phone(p_phone);
  if not found then return false; end if;
  if v_status = 'confirmed' then raise exception 'Đăng ký đã được xác nhận nên không thể sửa. Vui lòng liên hệ Gemini Dance.'; end if;
  if v_status = 'cancelled' then raise exception 'Đăng ký đã bị huỷ nên không thể sửa.'; end if;
  perform check_contact(p_phone, p_email);
  perform check_age(p_birth_year);
  update registrations set
    full_name = trim(p_full_name), email = nullif(lower(trim(p_email)),''), birth_year = p_birth_year,
    course_id = p_course_id, note = nullif(trim(p_note),''), updated_at = now()
  where code = upper(trim(p_code)) and norm_phone(phone) = norm_phone(p_phone);
  return found;
end $$;

-- Huỷ: không xoá, chuyển sang 'cancelled'; không cho huỷ khi đã xác nhận
create or replace function public.cancel_registration(p_code text, p_phone text)
returns boolean language plpgsql security definer set search_path = public as $$
declare v_status text;
begin
  select status into v_status from registrations
   where code = upper(trim(p_code)) and norm_phone(phone) = norm_phone(p_phone);
  if not found then return false; end if;
  if v_status = 'confirmed' then raise exception 'Đăng ký đã được xác nhận nên không thể huỷ. Vui lòng liên hệ Gemini Dance.'; end if;
  if v_status = 'cancelled' then raise exception 'Đăng ký này đã được huỷ trước đó.'; end if;
  update registrations set status = 'cancelled', cancelled_by = 'student', cancelled_at = now(), updated_at = now()
  where code = upper(trim(p_code)) and norm_phone(phone) = norm_phone(p_phone);
  return found;
end $$;

grant execute on function public.find_registration, public.update_registration, public.cancel_registration to anon, authenticated;

notify pgrst, 'reload schema';
