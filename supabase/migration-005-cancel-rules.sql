-- =====================================================================
-- Gemini Dance – migration 005: quy tắc huỷ đăng ký
--  1. Đăng ký "Đã xác nhận" thì học viên KHÔNG được huỷ (và không được sửa).
--  2. Học viên tự huỷ: KHÔNG xoá record, chỉ chuyển trạng thái sang "Đã huỷ".
--  3. Ghi lại ai huỷ (cột cancelled_by: 'student' = học viên, 'admin' = admin) và lúc nào (cancelled_at).
-- Chạy 1 lần trong Supabase > SQL Editor (an toàn khi chạy lại).
-- =====================================================================

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
