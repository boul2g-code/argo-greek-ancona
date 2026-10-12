alter table public.argo_orders add column if not exists table_number integer;
alter table public.argo_orders drop constraint argo_orders_order_type_check;
alter table public.argo_orders add constraint argo_orders_order_type_check check (order_type in ('asporto','tavolo'));
alter table public.argo_orders drop constraint argo_orders_pickup_only_check;
alter table public.argo_orders add constraint argo_orders_pickup_only_check check (order_type in ('asporto','tavolo') and coalesce(delivery_fee,0)=0);
alter table public.argo_orders add constraint argo_orders_table_number_check check ((order_type='tavolo' and table_number between 1 and 10 and table_number is not null) or (order_type='asporto' and table_number is null));
alter table public.argo_orders add constraint argo_orders_table_hours_check check (order_type<>'tavolo' or (requested_at is not null and extract(dow from requested_at at time zone 'Europe/Rome')<>3 and (requested_at at time zone 'Europe/Rome')::time between time '18:30' and time '23:00'));
CREATE OR REPLACE FUNCTION public.argo_place_order(p_customer_name text, p_phone text, p_email text, p_order_type text, p_requested_at timestamp with time zone, p_address text, p_notes text, p_payment_method text, p_items jsonb, p_promo_code text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
 v_table integer; v_order uuid; v_no bigint; v_subtotal numeric(10,2):=0; v_total numeric(10,2); v_discount numeric(10,2):=0;
 v_offer uuid; v_promo jsonb; v_ck text; x jsonb; mi argo_menu_items%rowtype; q int; base_line numeric(10,2);
 mods jsonb; mod_ids uuid[]; mod_extra numeric(10,2); mod_notes text; invalid_count int; grp_bad int;
begin
 if p_order_type='tavolo' then
   if coalesce(p_address,'') !~ '^([1-9]|10)$' then raise exception 'invalid_table_number'; end if;
   v_table:=p_address::integer;
   p_customer_name:=coalesce(nullif(trim(p_customer_name),''),'Tavolo '||v_table);
   p_phone:=coalesce(p_phone,'');
   p_requested_at:=now();
   p_payment_method:='pay_at_store';
   p_address:='Tavolo '||v_table;
   if coalesce(trim(p_promo_code),'')<>'' then raise exception 'table_promo_not_available'; end if;
 elsif coalesce(trim(p_customer_name),'')='' or coalesce(trim(p_phone),'')='' then raise exception 'name_and_phone_required'; end if;
 if p_order_type not in ('asporto','tavolo') then raise exception 'invalid_order_type'; end if;
 if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items)=0 then raise exception 'empty_order'; end if;

 for x in select value from jsonb_array_elements(p_items) loop
   select * into mi from argo_menu_items where id=(x->>'menu_item_id')::uuid and active=true;
   if mi.id is null then raise exception 'invalid_menu_item'; end if;
   q:=greatest(1,least(50,coalesce((x->>'quantity')::int,1)));
   mods:=coalesce(x->'modifiers','[]'::jsonb);
   if jsonb_typeof(mods)<>'array' then raise exception 'invalid_modifiers'; end if;
   select coalesce(array_agg((m.value #>> '{}')::uuid),'{}'::uuid[]) into mod_ids from jsonb_array_elements(mods) m(value);

   select count(*) into invalid_count
   from unnest(mod_ids) oid
   left join argo_modifier_options mo on mo.id=oid and mo.active=true
   left join argo_menu_item_modifier_groups mig on mig.menu_item_id=mi.id and mig.group_id=mo.group_id
   where mo.id is null or mig.menu_item_id is null;
   if invalid_count>0 then raise exception 'invalid_modifier'; end if;

   select count(*) into grp_bad from (
     select mg.id
     from argo_menu_item_modifier_groups mig
     join argo_modifier_groups mg on mg.id=mig.group_id and mg.active=true
     left join argo_modifier_options mo on mo.group_id=mg.id and mo.id=any(mod_ids)
     where mig.menu_item_id=mi.id
     group by mg.id,mg.min_select,mg.max_select
     having count(mo.id)<mg.min_select or count(mo.id)>mg.max_select
   ) z;
   if grp_bad>0 then raise exception 'modifier_selection_limit'; end if;

   select coalesce(sum(mo.price_delta),0),coalesce(string_agg(mo.name || case when mo.price_delta>0 then ' (+' || to_char(mo.price_delta,'FM999990.00') || '€)' else '' end,E'\n' order by mg.sort_order,mo.sort_order),'')
   into mod_extra,mod_notes
   from argo_modifier_options mo join argo_modifier_groups mg on mg.id=mo.group_id
   where mo.id=any(mod_ids);
   base_line:=(mi.price+mod_extra)*q;
   v_subtotal:=v_subtotal+base_line;
 end loop;

 v_total:=v_subtotal;
 if coalesce(trim(p_promo_code),'')<>'' then
   v_promo:=argo_validate_promo(p_promo_code,v_subtotal,p_phone,p_email);
   if coalesce((v_promo->>'valid')::boolean,false)=false then raise exception 'invalid_promo:%',coalesce(v_promo->>'reason','invalid'); end if;
   v_discount:=coalesce((v_promo->>'discount_amount')::numeric,0); v_total:=coalesce((v_promo->>'total')::numeric,v_subtotal); v_offer:=(v_promo->>'offer_id')::uuid;
 end if;

 insert into argo_orders(table_number,customer_name,phone,email,order_type,requested_at,address,notes,payment_method,subtotal,discount_amount,total,promo_code,offer_id)
 values(v_table,trim(p_customer_name),trim(p_phone),nullif(trim(p_email),''),p_order_type,p_requested_at,nullif(trim(p_address),''),nullif(trim(p_notes),''),coalesce(nullif(p_payment_method,''),'pay_at_store'),v_subtotal,v_discount,v_total,upper(nullif(trim(p_promo_code),'')),v_offer)
 returning id,order_number into v_order,v_no;

 for x in select value from jsonb_array_elements(p_items) loop
   select * into mi from argo_menu_items where id=(x->>'menu_item_id')::uuid and active=true;
   q:=greatest(1,least(50,coalesce((x->>'quantity')::int,1))); mods:=coalesce(x->'modifiers','[]'::jsonb);
   select coalesce(array_agg((m.value #>> '{}')::uuid),'{}'::uuid[]) into mod_ids from jsonb_array_elements(mods) m(value);
   select coalesce(sum(mo.price_delta),0),coalesce(string_agg(mo.name || case when mo.price_delta>0 then ' (+' || to_char(mo.price_delta,'FM999990.00') || '€)' else '' end,E'\n' order by mg.sort_order,mo.sort_order),'')
   into mod_extra,mod_notes from argo_modifier_options mo join argo_modifier_groups mg on mg.id=mo.group_id where mo.id=any(mod_ids);
   insert into argo_order_items(order_id,menu_item_id,name,quantity,unit_price,notes,modifiers)
   values(v_order,mi.id,mi.name,q,mi.price+mod_extra,nullif(concat_ws(E'\n',nullif(mod_notes,''),nullif(trim(x->>'notes'),'')),''),
     coalesce((select jsonb_agg(jsonb_build_object('id',mo.id,'group',mg.name,'name',mo.name,'price_delta',mo.price_delta) order by mg.sort_order,mo.sort_order) from argo_modifier_options mo join argo_modifier_groups mg on mg.id=mo.group_id where mo.id=any(mod_ids)),'[]'::jsonb));
 end loop;

 if v_offer is not null then
   v_ck:=argo_customer_key(p_phone,p_email);
   insert into argo_promo_redemptions(offer_id,order_id,customer_key) values(v_offer,v_order,v_ck);
   update argo_offers set uses_count=uses_count+1 where id=v_offer;
 end if;
 return jsonb_build_object('id',v_order,'order_number',v_no,'subtotal',v_subtotal,'discount_amount',v_discount,'promo_code',upper(nullif(trim(p_promo_code),'')),'total',v_total,'status','new');
end $function$;

CREATE OR REPLACE FUNCTION public.argo_admin_orders(p_token text)
 RETURNS TABLE(id uuid, order_number bigint, customer_name text, phone text, email text, order_type text, requested_at timestamp with time zone, address text, notes text, payment_method text, payment_status text, status text, subtotal numeric, delivery_fee numeric, discount_amount numeric, promo_code text, total numeric, accepted_at timestamp with time zone, printed_at timestamp with time zone, print_count integer, created_at timestamp with time zone, items jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
 if not argo_admin_valid(p_token) then raise exception 'unauthorized'; end if;
 return query
 select o.id,o.order_number,o.customer_name,o.phone,o.email,o.order_type,o.requested_at,case when o.order_type='tavolo' then 'Tavolo '||o.table_number else null::text end as address,o.notes,o.payment_method,o.payment_status,o.status,o.subtotal,o.delivery_fee,o.discount_amount,o.promo_code,o.total,o.accepted_at,o.printed_at,o.print_count,o.created_at,
 coalesce((select jsonb_agg(jsonb_build_object('id',i.id,'name',i.name,'quantity',i.quantity,'unit_price',i.unit_price,'line_total',i.line_total,'notes',i.notes,'modifiers',i.modifiers) order by i.created_at) from argo_order_items i where i.order_id=o.id),'[]'::jsonb)
 from argo_orders o
 where o.order_type in ('asporto','tavolo')
 order by case when o.status='new' then 0 else 1 end,o.created_at desc
 limit 200;
end
$function$;

notify pgrst, 'reload schema';