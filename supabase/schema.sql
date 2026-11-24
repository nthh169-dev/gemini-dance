-- =====================================================================
-- GEMINI DANCE – Supabase schema
-- Cách dùng: Supabase Dashboard > SQL Editor > New query > dán toàn bộ
-- file này > Run. Chạy lại nhiều lần vẫn an toàn (idempotent).
-- =====================================================================

-- (gen_random_uuid() có sẵn trong PostgreSQL 13+, không cần extension)

-- ---------------------------------------------------------------------
-- 1. BẢNG
-- ---------------------------------------------------------------------
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email   text,
  created_at timestamptz not null default now()
);

create table if not exists public.courses (
  id             serial primary key,
  slug           text unique not null,
  name           text not null,
  level          text not null check (level in ('beginner','advanced')),
  schedule_days  text not null,
  schedule_time  text not null,
  duration_weeks int  not null default 8,
  fee            int  not null default 0,          -- VNĐ / khoá
  max_students   int  not null default 20,
  short_desc     text,
  description    text,
  highlights     text[] default '{}',
  is_active      boolean not null default true,
  created_at     timestamptz not null default now()
);

create table if not exists public.registrations (
  id         bigserial primary key,
  code       text unique not null default upper(substr(md5(gen_random_uuid()::text),1,6)),
  full_name  text not null check (char_length(full_name) between 2 and 80),
  phone      text not null check (phone ~ '^[0-9+ ]{9,15}$'),
  email      text,
  birth_year int  check (birth_year between 1950 and 2010),
  birth_date date check (birth_date between '1950-01-01' and current_date),
  course_id  int  not null references public.courses(id) on delete cascade,
  note       text,
  status     text not null default 'pending' check (status in ('pending','confirmed','cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.page_views (
  id         bigserial primary key,
  page       text not null,
  referrer   text,
  session_id text,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id          serial primary key,
  name        text not null,
  category    text not null check (category in ('trang-phuc','giay','phu-kien')),
  price       int  not null check (price >= 0),
  sale_price  int  check (sale_price >= 0),
  sizes       text[] default '{}',
  colors      text[] default '{}',
  badge       text check (badge in ('New','Hot','Sale')),
  stock       int  not null default 0 check (stock >= 0),
  image_url   text,
  description text,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

create table if not exists public.orders (
  id            bigserial primary key,
  code          text unique not null default 'GD' || upper(substr(md5(gen_random_uuid()::text),1,6)),
  customer_name text not null,
  phone         text not null,
  email         text,
  address       text not null,
  note          text,
  total         int  not null default 0,
  status        text not null default 'new' check (status in ('new','shipping','done','cancelled')),
  created_at    timestamptz not null default now()
);

create table if not exists public.order_items (
  id           bigserial primary key,
  order_id     bigint not null references public.orders(id) on delete cascade,
  product_id   int references public.products(id) on delete set null,
  product_name text not null,
  size         text,
  color        text,
  qty          int not null check (qty > 0),
  unit_price   int not null
);

-- ---------------------------------------------------------------------
-- 2. HÀM KIỂM TRA ADMIN
-- ---------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

-- ---------------------------------------------------------------------
-- 3. ROW LEVEL SECURITY
-- ---------------------------------------------------------------------
alter table public.registrations add column if not exists birth_date date;

alter table public.admins        enable row level security;
alter table public.courses       enable row level security;
alter table public.registrations enable row level security;
alter table public.page_views    enable row level security;
alter table public.products      enable row level security;
alter table public.orders        enable row level security;
alter table public.order_items   enable row level security;

drop policy if exists "admins self read"   on public.admins;
create policy "admins self read" on public.admins for select using (user_id = auth.uid());

drop policy if exists "courses public read" on public.courses;
create policy "courses public read" on public.courses for select using (is_active or public.is_admin());
drop policy if exists "courses admin write" on public.courses;
create policy "courses admin write" on public.courses for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "registrations admin" on public.registrations;
create policy "registrations admin" on public.registrations for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "page_views insert" on public.page_views;
create policy "page_views insert" on public.page_views for insert with check (char_length(page) < 200);
drop policy if exists "page_views admin" on public.page_views;
create policy "page_views admin" on public.page_views for select using (public.is_admin());
drop policy if exists "page_views admin delete" on public.page_views;
create policy "page_views admin delete" on public.page_views for delete using (public.is_admin());

drop policy if exists "products public read" on public.products;
create policy "products public read" on public.products for select using (is_active or public.is_admin());
drop policy if exists "products admin write" on public.products;
create policy "products admin write" on public.products for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "orders admin" on public.orders;
create policy "orders admin" on public.orders for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "order_items admin" on public.order_items;
create policy "order_items admin" on public.order_items for all using (public.is_admin()) with check (public.is_admin());

grant select on public.courses, public.products to anon, authenticated;
grant insert on public.page_views to anon, authenticated;
grant usage, select on sequence public.page_views_id_seq to anon, authenticated;
grant all on public.courses, public.registrations, public.page_views, public.products,
             public.orders, public.order_items, public.admins to authenticated;
grant usage, select on all sequences in schema public to authenticated;

-- ---------------------------------------------------------------------
-- 4. HÀM RPC CHO KHÁCH (chỉ thao tác được khi biết đúng mã + SĐT)
-- ---------------------------------------------------------------------
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


-- 4.5 Số chỗ đã đăng ký mỗi khoá (để hiện "còn x chỗ")
create or replace function public.course_seats()
returns table(course_id int, taken bigint) language sql stable security definer set search_path = public as $$
  select course_id, count(*) from registrations where status <> 'cancelled' group by course_id;
$$;

grant execute on function public.course_seats, public.is_admin to anon, authenticated;


-- ---------------------------------------------------------------------
-- 5. DỮ LIỆU MẪU
-- ---------------------------------------------------------------------
insert into public.courses (slug, name, level, schedule_days, schedule_time, duration_weeks, fee, max_students, short_desc, description, highlights)
values
('beginner', 'Beginner – Lớp Căn Bản', 'beginner', 'Chủ nhật', '12:00 – 14:00', 8, 1200000, 20,
 'Dành cho người mới bắt đầu, chưa từng học nhảy.',
 'Lớp Beginner giúp bạn làm quen với nhịp điệu, isolation, cách kiểm soát cơ thể và thần thái trên sân khấu. Mỗi buổi gồm khởi động, kỹ thuật cơ bản và một đoạn choreography ngắn theo nhạc K-pop / Sexy Dance đang hot. Sau 8 tuần bạn sẽ tự tin quay video TikTok cùng lớp.',
 array['Khởi động & giãn cơ đúng cách','Nhịp đếm, isolation, groove cơ bản','Tư thế, thần thái, biểu cảm khuôn mặt','1 bài choreography hoàn chỉnh mỗi 2 tuần','Quay video cuối khoá đăng TikTok Gemini Dance']),
('advanced', 'Advanced – Lớp Nâng Cao', 'advanced', 'Thứ 7 & Chủ nhật', '14:00 – 15:00', 8, 1500000, 15,
 'Dành cho bạn đã có nền tảng, muốn chinh phục Heels & Sexy Dance.',
 'Lớp Advanced tập trung vào kỹ thuật Heels, floor work, chuyển động liên hoàn và trình diễn theo nhóm. Học viên được luyện tập 2 buổi/tuần, dựng bài biểu diễn và tham gia quay MV, sự kiện của Gemini Dance.',
 array['Kỹ thuật Heels & floor work','Choreography tốc độ cao, chuyển đội hình','Freestyle & tạo dấu ấn cá nhân','Dựng bài biểu diễn nhóm','Ưu tiên tham gia show & MV của trung tâm'])
on conflict (slug) do nothing;

insert into public.products (name, category, price, sale_price, sizes, colors, badge, stock, description)
select * from (values
 ('Bodysuit Gemini Neon',  'trang-phuc', 420000, null::int, array['S','M','L'],       array['Đen','Tím neon'],   'New',  30, 'Bodysuit cut-out ôm dáng, thun lạnh 4 chiều co giãn, tôn đường cong khi biểu diễn.'),
 ('Crop top lưới Starry',  'trang-phuc', 220000, 179000,    array['S','M','L'],       array['Đen','Trắng'],      'Sale', 40, 'Crop top lưới phối dây, mặc ngoài sport bra cực cá tính.'),
 ('Quần biker Twin',       'trang-phuc', 260000, null,      array['S','M','L','XL'],  array['Đen','Hồng'],       'Hot',  35, 'Quần biker cạp cao, không lộ khi xoạc, thấm hút mồ hôi.'),
 ('Legging ánh kim Galaxy','trang-phuc', 350000, null,      array['S','M','L'],       array['Bạc','Tím'],        'New',  20, 'Legging phủ ánh kim lấp lánh dưới đèn sân khấu.'),
 ('Sport bra Constellation','trang-phuc',240000, null,      array['S','M','L'],       array['Đen','Cyan'],       null,   30, 'Sport bra nâng đỡ tốt, dây đan chéo lưng.'),
 ('Giày Heels Dance 9cm',  'giay',       890000, 790000,    array['35','36','37','38','39'], array['Đen','Nude'], 'Sale', 15, 'Giày heels đế da lộn chuyên nhảy, gót vững, có quai cổ chân.'),
 ('Giày Jazz da mềm',      'giay',       450000, null,      array['35','36','37','38','39'], array['Đen','Be'],   null,   20, 'Giày jazz đế chia đôi, xoay trượt dễ dàng.'),
 ('Sneaker nhảy Gemini',   'giay',       990000, null,      array['36','37','38','39'],      array['Trắng','Đen'],'Hot',  18, 'Sneaker đế xoay pivot, nhẹ, êm cho hip hop & K-pop.'),
 ('Tất đùi Thigh-high',    'phu-kien',   120000, null,      array['Free size'],      array['Đen'],              'Hot',  60, 'Tất đùi dày dặn, chống trượt, chuẩn outfit Sexy Dance.'),
 ('Găng tay lưới Neon',    'phu-kien',    90000, null,      array['Free size'],      array['Đen','Hồng'],       null,   50, 'Găng tay lưới hở ngón, điểm nhấn cho tiết mục.'),
 ('Kneepad bảo vệ gối',    'phu-kien',   180000, null,      array['S','M'],          array['Đen'],              'New',  40, 'Bảo vệ gối khi tập floor work, mỏng nhẹ mặc dưới legging.'),
 ('Túi tập Gemini Duffle', 'phu-kien',   390000, 329000,    array['Free size'],      array['Đen','Tím'],        'Sale', 25, 'Túi trống có ngăn giày riêng, in logo Gemini Dance phản quang.')
) as v(name, category, price, sale_price, sizes, colors, badge, stock, description)
where not exists (select 1 from public.products);

-- ---------------------------------------------------------------------
-- 6. TẠO ADMIN (chạy SAU khi đã tạo user trong Authentication > Users)
-- Thay email bên dưới bằng email admin của bạn rồi chạy riêng câu lệnh:
-- insert into public.admins(user_id, email)
--   select id, email from auth.users where email = 'admin@example.com'
--   on conflict do nothing;
-- ---------------------------------------------------------------------
