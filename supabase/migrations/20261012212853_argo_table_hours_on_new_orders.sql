alter table public.argo_orders drop constraint if exists argo_orders_table_hours_check;
create or replace function public.argo_check_table_order_hours() returns trigger language plpgsql set search_path='public' as $$
declare local_now timestamp:=now() at time zone 'Europe/Rome';
begin
 if new.order_type='tavolo' and (extract(dow from local_now)=3 or local_now::time < time '18:30' or local_now::time >= time '23:00') then
  raise exception 'table_order_closed';
 end if;
 return new;
end; $$;
create trigger argo_table_order_hours before insert on public.argo_orders for each row execute function public.argo_check_table_order_hours();