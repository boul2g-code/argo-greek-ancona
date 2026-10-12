create or replace function public.argo_enforce_pickup_only() returns trigger language plpgsql set search_path='public' as $$
begin
 if new.order_type is null or new.order_type not in ('asporto','tavolo') then raise exception 'delivery_not_supported_use_deliveroo_or_justeat'; end if;
 new.delivery_fee:=0;
 if new.order_type='asporto' then new.address:=null; else new.address:='Tavolo '||new.table_number; end if;
 return new;
end;
$$;