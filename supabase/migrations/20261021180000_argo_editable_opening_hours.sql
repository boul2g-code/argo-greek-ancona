-- Opening hours stored in argo_site_settings (key 'hours'); keys follow dow: 0=Sunday ... 6=Saturday.
insert into public.argo_site_settings(key,value)
values ('hours', '{"days":{
 "0":{"open":true,"from":"18:30","to":"23:00"},
 "1":{"open":true,"from":"18:30","to":"23:00"},
 "2":{"open":false,"from":"18:30","to":"23:00"},
 "3":{"open":true,"from":"18:30","to":"23:00"},
 "4":{"open":true,"from":"18:30","to":"23:00"},
 "5":{"open":true,"from":"18:30","to":"23:00"},
 "6":{"open":true,"from":"18:30","to":"23:00"}}}'::jsonb)
on conflict (key) do update set value=excluded.value, updated_at=now();

create or replace function public.argo_public_hours()
returns jsonb language sql stable security definer set search_path to 'public'
as $$ select coalesce((select value from public.argo_site_settings where key='hours'),
  '{"days":{"0":{"open":true,"from":"18:30","to":"23:00"},"1":{"open":true,"from":"18:30","to":"23:00"},"2":{"open":false,"from":"18:30","to":"23:00"},"3":{"open":true,"from":"18:30","to":"23:00"},"4":{"open":true,"from":"18:30","to":"23:00"},"5":{"open":true,"from":"18:30","to":"23:00"},"6":{"open":true,"from":"18:30","to":"23:00"}}}'::jsonb) $$;

create or replace function public.argo_admin_set_hours(p_token text, p_hours jsonb)
returns jsonb language plpgsql security definer set search_path to 'public'
as $$
declare k text; d jsonb; any_open boolean := false;
begin
  if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;
  if p_hours is null or jsonb_typeof(p_hours->'days') <> 'object' then raise exception 'invalid_hours'; end if;
  for k in select generate_series(0,6)::text loop
    d := p_hours->'days'->k;
    if d is null or jsonb_typeof(d->'open') <> 'boolean' then raise exception 'invalid_day_%', k; end if;
    if (d->>'from') !~ '^([01][0-9]|2[0-3]):[0-5][0-9]$' or (d->>'to') !~ '^([01][0-9]|2[0-3]):[0-5][0-9]$' then raise exception 'invalid_time_%', k; end if;
    if (d->>'open')::boolean then
      any_open := true;
      if (d->>'from') >= (d->>'to') then raise exception 'from_after_to_%', k; end if;
    end if;
  end loop;
  if not any_open then raise exception 'at_least_one_open_day'; end if;
  p_hours := jsonb_build_object('days', p_hours->'days');
  insert into public.argo_site_settings(key,value) values ('hours',p_hours)
    on conflict (key) do update set value=excluded.value, updated_at=now();
  return p_hours;
end $$;

create or replace function public.argo_enforce_pickup_hours()
returns trigger language plpgsql set search_path to 'public'
as $$
declare local_ts timestamp; local_dow int; local_t time; d jsonb;
begin
  if new.order_type = 'asporto' then
    if new.requested_at is null then raise exception 'pickup_closed'; end if;
    local_ts := new.requested_at at time zone 'Europe/Rome';
    local_dow := extract(dow from local_ts);
    local_t := local_ts::time;
    d := public.argo_public_hours()->'days'->(local_dow::text);
    if d is null or not coalesce((d->>'open')::boolean,false)
       or local_t < (d->>'from')::time or local_t > (d->>'to')::time then
      raise exception 'pickup_closed';
    end if;
  end if;
  return new;
end $$;

create or replace function public.argo_check_table_order_hours()
returns trigger language plpgsql set search_path to 'public'
as $$
declare local_now timestamp := now() at time zone 'Europe/Rome'; d jsonb;
begin
  if new.order_type='tavolo' then
    d := public.argo_public_hours()->'days'->(extract(dow from local_now)::int::text);
    if d is null or not coalesce((d->>'open')::boolean,false)
       or local_now::time < (d->>'from')::time or local_now::time >= (d->>'to')::time then
      raise exception 'table_order_closed';
    end if;
  end if;
  return new;
end $$;

revoke all on function public.argo_public_hours() from public;
revoke all on function public.argo_admin_set_hours(text,jsonb) from public;
grant execute on function public.argo_public_hours() to anon, authenticated;
grant execute on function public.argo_admin_set_hours(text,jsonb) to anon, authenticated;
