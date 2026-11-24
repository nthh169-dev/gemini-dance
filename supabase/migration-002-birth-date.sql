-- =====================================================================
-- MIGRATION 002 – Đổi "Năm sinh" thành "Ngày sinh" (có lịch để chọn)
-- Supabase > SQL Editor > New query > dán file này > Run. Chạy lại vẫn an toàn.
-- =====================================================================
alter table public.registrations add column if not exists birth_date date
  check (birth_date between '1950-01-01' and current_date);

-- Giữ birth_year tự khớp với birth_date (dashboard / dữ liệu cũ vẫn dùng được)
update public.registrations set birth_year = extract(year from birth_date)::int
where birth_date is not null and birth_year is distinct from extract(year from birth_date)::int;

drop function if exists public.register_course(text, text, text, int, int, text);
drop function if exists public.update_registration(text, text, text, text, int, int, text);

create or replace function public.register_course(
  p_full_name text, p_phone text, p_email text, p_birth_date date, p_course_id int, p_note text)
returns json language plpgsql security definer set search_path = public as $$
declare r public.registrations;
begin
  if not exists (select 1 from courses where id = p_course_id and is_active) then
    raise exception 'Khoá học không tồn tại';
  end if;
  insert into registrations(full_name, phone, email, birth_date, birth_year, course_id, note)
  values (trim(p_full_name), trim(p_phone), nullif(trim(p_email),''), p_birth_date,
          extract(year from p_birth_date)::int, p_course_id, nullif(trim(p_note),''))
  returning * into r;
  return json_build_object('code', r.code, 'id', r.id);
end $$;

create or replace function public.update_registration(
  p_code text, p_phone text, p_full_name text, p_email text, p_birth_date date, p_course_id int, p_note text)
returns boolean language plpgsql security definer set search_path = public as $$
begin
  update registrations set
    full_name = trim(p_full_name), email = nullif(trim(p_email),''),
    birth_date = p_birth_date, birth_year = extract(year from p_birth_date)::int,
    course_id = p_course_id, note = nullif(trim(p_note),''), status = 'pending', updated_at = now()
  where code = upper(trim(p_code)) and phone = trim(p_phone);
  return found;
end $$;

create or replace function public.find_registration(p_code text, p_phone text)
returns json language sql stable security definer set search_path = public as $$
  select row_to_json(x) from (
    select r.code, r.full_name, r.phone, r.email, r.birth_year, r.birth_date, r.course_id, r.note, r.status,
           r.created_at, r.updated_at, c.name as course_name, c.schedule_days, c.schedule_time
    from registrations r join courses c on c.id = r.course_id
    where r.code = upper(trim(p_code)) and r.phone = trim(p_phone)
  ) x;
$$;

revoke all on function public.register_course, public.update_registration, public.find_registration from public;
grant execute on function public.register_course, public.update_registration, public.find_registration to anon, authenticated;

-- Báo PostgREST đọc lại danh sách hàm ngay
notify pgrst, 'reload schema';
