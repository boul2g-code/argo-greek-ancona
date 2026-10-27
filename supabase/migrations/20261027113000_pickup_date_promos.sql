-- Daily offers follow the scheduled pickup date, not the order creation date.
create or replace function public.argo_public_promo_for_pickup(p_requested_at timestamptz)
returns table(day_no integer, day_name text, code text, title text, discount_type text, discount_value numeric, min_order numeric)
language sql stable security definer set search_path to 'public'
as $$
  with requested_day as (
    select extract(isodow from (p_requested_at at time zone 'Europe/Rome'))::integer as day_no
  ), days(day_no,day_name) as (values
    (1,'Lunedì'),(2,'Martedì'),(3,'Mercoledì'),(4,'Giovedì'),(5,'Venerdì'),(6,'Sabato'),(7,'Domenica')
  )
  select d.day_no,d.day_name,o.code,o.title,o.discount_type,o.discount_value,o.min_order
  from requested_day r
  join days d on d.day_no=r.day_no
  left join lateral (
    select x.code,x.title,x.discount_type,x.discount_value,x.min_order
    from public.argo_offers x
    where x.active=true
      and x.recurring_weekdays @> array[d.day_no]::smallint[]
      and (x.starts_at is null or x.starts_at<=p_requested_at)
      and (x.ends_at is null or x.ends_at>p_requested_at)
      and (x.max_uses is null or x.uses_count<x.max_uses)
    order by x.priority desc,x.created_at desc
    limit 1
  ) o on true
  where p_requested_at is not null;
$$;

create or replace function public.argo_validate_promo_for_pickup(
  p_code text,
  p_subtotal numeric,
  p_phone text default null,
  p_email text default null,
  p_requested_at timestamptz default null
)
returns jsonb language plpgsql security definer set search_path to 'public'
as $$
declare
  o public.argo_offers%rowtype;
  d numeric(10,2):=0;
  ck text;
  used int:=0;
  prior_orders int:=0;
  iso_day int;
  pickup_date date;
begin
  if p_requested_at is null then return jsonb_build_object('valid',false,'reason','pickup_required'); end if;
  if coalesce(trim(p_code),'')='' then return jsonb_build_object('valid',false,'reason','empty_code'); end if;

  select * into o
  from public.argo_offers
  where active=true
    and upper(trim(code))=upper(trim(p_code))
    and (starts_at is null or starts_at<=p_requested_at)
    and (ends_at is null or ends_at>=p_requested_at)
  order by priority desc,created_at desc
  limit 1;

  if o.id is null then return jsonb_build_object('valid',false,'reason','invalid_or_expired'); end if;
  if o.max_uses is not null and o.uses_count>=o.max_uses then return jsonb_build_object('valid',false,'reason','max_uses_reached'); end if;

  iso_day:=extract(isodow from (p_requested_at at time zone 'Europe/Rome'))::int;
  pickup_date:=(p_requested_at at time zone 'Europe/Rome')::date;
  if o.recurring_weekdays is not null and cardinality(o.recurring_weekdays)>0 and not (iso_day=any(o.recurring_weekdays)) then
    return jsonb_build_object('valid',false,'reason','wrong_day');
  end if;
  if p_subtotal<coalesce(o.min_order,0) then
    return jsonb_build_object('valid',false,'reason','min_order','min_order',o.min_order);
  end if;

  ck:=public.argo_customer_key(p_phone,p_email);
  if o.first_order_only then
    if ck='' then return jsonb_build_object('valid',false,'reason','phone_required_first_order'); end if;
    select count(*) into prior_orders
    from public.argo_orders x
    where x.source='argo_web'
      and x.status not in ('cancelled')
      and public.argo_customer_key(x.phone,x.email)=ck;
    if prior_orders>0 then return jsonb_build_object('valid',false,'reason','first_order_only'); end if;
  end if;

  if ck<>'' and coalesce(o.per_customer_limit,0)>0 then
    if o.recurring_weekdays is not null and cardinality(o.recurring_weekdays)>0 then
      select count(*) into used
      from public.argo_promo_redemptions r
      join public.argo_orders x on x.id=r.order_id
      where r.offer_id=o.id
        and r.customer_key=ck
        and (x.requested_at at time zone 'Europe/Rome')::date=pickup_date
        and x.status<>'cancelled';
    else
      select count(*) into used
      from public.argo_promo_redemptions r
      join public.argo_orders x on x.id=r.order_id
      where r.offer_id=o.id and r.customer_key=ck and x.status<>'cancelled';
    end if;
    if used>=o.per_customer_limit then
      return jsonb_build_object('valid',false,'reason',case when o.recurring_weekdays is not null and cardinality(o.recurring_weekdays)>0 then 'daily_customer_limit' else 'customer_limit' end);
    end if;
  end if;

  if o.discount_type='percent' then d:=round(p_subtotal*(o.discount_value/100.0),2);
  elsif o.discount_type='fixed' then d:=least(p_subtotal,o.discount_value);
  else return jsonb_build_object('valid',false,'reason','offer_not_configured'); end if;
  d:=greatest(0,least(p_subtotal,d));

  return jsonb_build_object(
    'valid',true,'offer_id',o.id,'code',o.code,'title',o.title,
    'discount_type',o.discount_type,'discount_value',o.discount_value,
    'discount_amount',d,'total',p_subtotal-d,'first_order_only',o.first_order_only,
    'recurring_weekdays',o.recurring_weekdays,'pickup_date',pickup_date
  );
end;
$$;

create or replace function public.argo_place_order(p_customer_name text, p_phone text, p_email text, p_order_type text, p_requested_at timestamp with time zone, p_address text, p_notes text, p_payment_method text, p_items jsonb, p_promo_code text default null::text)
returns jsonb language plpgsql security definer set search_path to 'public'
as $$
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
 if p_order_type='asporto' and p_requested_at is null then raise exception 'pickup_required'; end if;
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
   v_promo:=public.argo_validate_promo_for_pickup(p_promo_code,v_subtotal,p_phone,p_email,p_requested_at);
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
end;
$$;

revoke all on function public.argo_public_promo_for_pickup(timestamptz) from public;
revoke all on function public.argo_validate_promo_for_pickup(text,numeric,text,text,timestamptz) from public;
grant execute on function public.argo_public_promo_for_pickup(timestamptz) to anon, authenticated;
grant execute on function public.argo_validate_promo_for_pickup(text,numeric,text,text,timestamptz) to anon, authenticated;

notify pgrst, 'reload schema';
