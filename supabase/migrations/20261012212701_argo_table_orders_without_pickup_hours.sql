-- Guests already seated can send table orders after the takeaway closing time.
alter table public.argo_orders drop constraint if exists argo_orders_table_hours_check;
