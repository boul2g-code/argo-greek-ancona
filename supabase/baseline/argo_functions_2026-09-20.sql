-- ARGO live function baseline snapshot
-- Captured 2026-09-20 from Supabase project zibubwrntdmdxyimqddo.
-- Scope: public.argo_* functions only. Non-ARGO/KIROX functions are excluded.
-- Snapshot only: do NOT treat this file as an automatically replayed migration.
-- Function count at capture: 50.

-- argo_admin_booking_history(text,uuid)
CREATE OR REPLACE FUNCTION public.argo_admin_booking_history(p_token text, p_booking_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(id bigint, booking_id uuid, booking_name text, booking_date date, booking_time time without time zone, guests integer, admin_email text, action text, old_status text, new_status text, created_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
 if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;
 return query
 select e.id,e.booking_id,b.name,b.booking_date,b.booking_time,b.guests,e.admin_email,e.action,e.old_status,e.new_status,e.created_at
 from public.argo_booking_events e
 left join public.argo_bookings b on b.id=e.booking_id
 where p_booking_id is null or e.booking_id=p_booking_id
 order by e.created_at desc
 limit 500;
end;
$function$


-- argo_admin_booking_status(text,uuid,text)
CREATE OR REPLACE FUNCTION public.argo_admin_booking_status(p_token text, p_id uuid, p_status text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v_old text;
  v_email text;
begin
  if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;
  if p_status not in ('confirmed','cancelled','completed') then raise exception 'Stato non valido'; end if;
  select status into v_old from public.argo_bookings where id=p_id for update;
  if not found then return false; end if;
  if v_old in ('cancelled','completed') then raise exception 'Prenotazione già chiusa'; end if;
  if v_old='new' and p_status not in ('confirmed','cancelled') then raise exception 'Transizione non valida'; end if;
  if v_old='confirmed' and p_status not in ('completed','cancelled') then raise exception 'Transizione non valida'; end if;
  if v_old=p_status then return true; end if;
  select s.email into v_email from public.argo_admin_sessions s
   where s.token_hash=encode(digest(convert_to(p_token,'UTF8'),'sha256'),'hex') and s.expires_at>now() limit 1;
  update public.argo_bookings set status=p_status where id=p_id;
  insert into public.argo_booking_events(booking_id,admin_email,action,old_status,new_status)
  values(p_id,v_email,'status_change',v_old,p_status);
  return true;
end;
$function$


-- argo_admin_bookings(text)
CREATE OR REPLACE FUNCTION public.argo_admin_bookings(p_token text)
 RETURNS SETOF argo_bookings
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if; return query select * from public.argo_bookings order by created_at desc limit 200; end;$function$


-- argo_admin_categories(text)
CREATE OR REPLACE FUNCTION public.argo_admin_categories(p_token text)
 RETURNS SETOF argo_menu_categories
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if; return query select * from public.argo_menu_categories order by sort_order, name; end;$function$


-- argo_admin_change_password(text,text)
CREATE OR REPLACE FUNCTION public.argo_admin_change_password(p_token text, p_new_password text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare v_email text;
begin
  if length(p_new_password) < 10 then raise exception 'Password troppo corta'; end if;
  select s.email into v_email from public.argo_admin_sessions s
  where s.token_hash=encode(digest(convert_to(p_token,'UTF8'),'sha256'),'hex') and s.expires_at>now();
  if v_email is null then raise exception 'Sessione non valida'; end if;
  update public.argo_admin_users set password_hash=crypt(p_new_password,gen_salt('bf',12)),updated_at=now() where email=v_email;
  return true;
end;
$function$


-- argo_admin_create_item(text,text,numeric,uuid,text,text,text,boolean,boolean)
CREATE OR REPLACE FUNCTION public.argo_admin_create_item(p_token text, p_name text, p_price numeric, p_category_id uuid, p_description text, p_image_url text, p_badge text, p_featured boolean, p_vegetarian boolean)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare v_id uuid; begin if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if; insert into public.argo_menu_items(name,price,category_id,description,image_url,badge,featured,vegetarian,active) values(p_name,p_price,p_category_id,nullif(p_description,''),nullif(p_image_url,''),nullif(p_badge,''),coalesce(p_featured,false),coalesce(p_vegetarian,false),true) returning id into v_id; return v_id; end;$function$


-- argo_admin_create_offer(text,text,text,text,integer,text)
CREATE OR REPLACE FUNCTION public.argo_admin_create_offer(p_token text, p_title text, p_body text, p_code text, p_priority integer, p_cta_url text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare v_id uuid; begin if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if; insert into public.argo_offers(title,body,code,priority,cta_url,active) values(p_title,p_body,nullif(p_code,''),coalesce(p_priority,0),nullif(p_cta_url,''),true) returning id into v_id; return v_id; end;$function$


-- argo_admin_create_offer(text,text,text,text,text,text,timestamp with time zone,timestamp with time zone,integer,text,numeric,numeric,integer,integer)
CREATE OR REPLACE FUNCTION public.argo_admin_create_offer(p_token text, p_title text, p_body text, p_code text, p_cta_label text, p_cta_url text, p_starts_at timestamp with time zone, p_ends_at timestamp with time zone, p_priority integer, p_discount_type text DEFAULT NULL::text, p_discount_value numeric DEFAULT NULL::numeric, p_min_order numeric DEFAULT 0, p_max_uses integer DEFAULT NULL::integer, p_per_customer_limit integer DEFAULT 1)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare v_id uuid;
begin
 if not argo_admin_valid(p_token) then raise exception 'unauthorized'; end if;
 if p_discount_type is not null and p_discount_type not in ('percent','fixed') then raise exception 'invalid_discount_type'; end if;
 insert into argo_offers(title,body,code,cta_label,cta_url,starts_at,ends_at,active,priority,discount_type,discount_value,min_order,max_uses,per_customer_limit)
 values(p_title,coalesce(p_body,''),nullif(upper(trim(p_code)),''),p_cta_label,p_cta_url,p_starts_at,p_ends_at,true,coalesce(p_priority,0),p_discount_type,p_discount_value,coalesce(p_min_order,0),p_max_uses,coalesce(p_per_customer_limit,1)) returning id into v_id;
 return v_id;
end $function$


-- argo_admin_disable_offer(text,uuid)
CREATE OR REPLACE FUNCTION public.argo_admin_disable_offer(p_token text, p_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if; update public.argo_offers set active=false where id=p_id; return found; end;$function$


-- argo_admin_events(text)
CREATE OR REPLACE FUNCTION public.argo_admin_events(p_token text)
 RETURNS SETOF argo_events
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if; return query select * from public.argo_events order by created_at desc limit 100; end;$function$


-- argo_admin_leads(text)
CREATE OR REPLACE FUNCTION public.argo_admin_leads(p_token text)
 RETURNS SETOF argo_leads
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if; return query select * from public.argo_leads order by created_at desc limit 500; end;$function$


-- argo_admin_login(text,text)
CREATE OR REPLACE FUNCTION public.argo_admin_login(p_email text, p_password text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v_hash text;
  v_token text;
begin
  select password_hash into v_hash from public.argo_admin_users
  where lower(email)=lower(p_email) and active=true;
  if v_hash is null or crypt(p_password, v_hash) <> v_hash then
    perform pg_sleep(0.25);
    raise exception 'Credenziali non valide';
  end if;
  delete from public.argo_admin_sessions where expires_at < now();
  v_token := encode(gen_random_bytes(32),'hex');
  insert into public.argo_admin_sessions(token_hash,email,expires_at)
  values (encode(digest(convert_to(v_token,'UTF8'),'sha256'),'hex'), lower(p_email), now()+interval '7 days');
  return v_token;
end;
$function$


-- argo_admin_marketing_action(text,uuid,text)
CREATE OR REPLACE FUNCTION public.argo_admin_marketing_action(p_token text, p_id uuid, p_action text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v_email text; v_old text; v_new text; v_sched timestamptz; v_kind text; v_budget numeric; v_channels text[];
  v_menu_id uuid; v_menu_active boolean; v_media_id uuid; v_media_status text; v_media_link uuid;
  v_meta_ok boolean; v_google_ok boolean; v_tiktok_ok boolean;
begin
  if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;
  select s.email into v_email from public.argo_admin_sessions s
   where s.token_hash=encode(digest(convert_to(p_token,'UTF8'),'sha256'),'hex') and s.expires_at>now() limit 1;

  select p.status,p.scheduled_at,p.kind,p.total_budget,p.channels,p.menu_item_id,p.media_id
    into v_old,v_sched,v_kind,v_budget,v_channels,v_menu_id,v_media_id
  from public.argo_marketing_posts p where p.id=p_id for update;
  if v_old is null then raise exception 'Post non trovato'; end if;

  if v_menu_id is not null and p_action in ('approve','schedule','ready') then
    select mi.active into v_menu_active from public.argo_menu_items mi where mi.id=v_menu_id;
    if coalesce(v_menu_active,false)=false then raise exception 'Il prodotto collegato non è più attivo nel menu'; end if;
  end if;

  if v_media_id is not null and p_action in ('approve','schedule','ready') then
    select m.status,m.linked_menu_item_id into v_media_status,v_media_link
      from public.argo_media_library m where m.id=v_media_id and m.active=true;
    if not found then raise exception 'La foto collegata non è più disponibile'; end if;
    if v_media_status='menu' and v_menu_id is not null and v_media_link is distinct from v_menu_id then
      raise exception 'La foto menu collegata appartiene a un altro prodotto';
    end if;
  end if;

  case p_action
    when 'approve' then
      if v_old not in ('draft','failed') then raise exception 'Stato non approvabile'; end if;
      v_new:='approved';
      update public.argo_marketing_posts set status=v_new,approved_at=now(),last_error=null,updated_by=v_email,updated_at=now() where id=p_id;
    when 'schedule' then
      if v_old not in ('approved','scheduled') then raise exception 'Prima approva il contenuto'; end if;
      if v_sched is null or v_sched <= now() then raise exception 'Imposta una data futura'; end if;
      v_new:='scheduled';
      update public.argo_marketing_posts set status=v_new,updated_by=v_email,updated_at=now() where id=p_id;
    when 'ready' then
      if v_old not in ('approved','scheduled') then raise exception 'Post non pronto'; end if;
      if v_kind='ad' and coalesce(v_budget,0)<=0 then raise exception 'Budget ads mancante'; end if;
      select exists(select 1 from public.argo_marketing_connections where provider='meta' and enabled and connected and autopublish_enabled) into v_meta_ok;
      select exists(select 1 from public.argo_marketing_connections where provider='google_business' and enabled and connected and autopublish_enabled) into v_google_ok;
      select exists(select 1 from public.argo_marketing_connections where provider='tiktok' and enabled and connected and autopublish_enabled) into v_tiktok_ok;
      if (('instagram'=any(v_channels)) or ('facebook'=any(v_channels))) and not v_meta_ok then raise exception 'Meta non collegato o autopublish disattivato'; end if;
      if 'google_business'=any(v_channels) and not v_google_ok then raise exception 'Google Business non collegato o autopublish disattivato'; end if;
      if 'tiktok'=any(v_channels) and not v_tiktok_ok then raise exception 'TikTok non collegato o autopublish disattivato'; end if;
      v_new:='ready_to_publish';
      update public.argo_marketing_posts set status=v_new,last_error=null,updated_by=v_email,updated_at=now() where id=p_id;
    when 'mark_published' then
      if v_old not in ('approved','scheduled','ready_to_publish') then raise exception 'Stato non pubblicabile'; end if;
      v_new:='published';
      update public.argo_marketing_posts set status=v_new,published_at=now(),last_error=null,updated_by=v_email,updated_at=now() where id=p_id;
    when 'cancel' then
      if v_old='published' then raise exception 'Un post pubblicato non può essere annullato qui'; end if;
      v_new:='cancelled';
      update public.argo_marketing_posts set status=v_new,updated_by=v_email,updated_at=now() where id=p_id;
    when 'reopen' then
      if v_old not in ('cancelled','failed') then raise exception 'Stato non riapribile'; end if;
      v_new:='draft';
      update public.argo_marketing_posts set status=v_new,approved_at=null,last_error=null,updated_by=v_email,updated_at=now() where id=p_id;
    else raise exception 'Azione non valida';
  end case;

  insert into public.argo_marketing_events(post_id,admin_email,action,old_status,new_status,detail)
  values(p_id,v_email,p_action,v_old,v_new,jsonb_build_object('menu_item_id',v_menu_id,'media_id',v_media_id));
  return true;
end;
$function$


-- argo_admin_marketing_connections(text)
CREATE OR REPLACE FUNCTION public.argo_admin_marketing_connections(p_token text)
 RETURNS SETOF argo_marketing_connections
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;
  return query select * from public.argo_marketing_connections order by provider;
end;$function$


-- argo_admin_marketing_history(text,uuid)
CREATE OR REPLACE FUNCTION public.argo_admin_marketing_history(p_token text, p_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(id bigint, post_id uuid, title text, admin_email text, action text, old_status text, new_status text, detail jsonb, created_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
 if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;
 return query select e.id,e.post_id,p.title,e.admin_email,e.action,e.old_status,e.new_status,e.detail,e.created_at
 from public.argo_marketing_events e join public.argo_marketing_posts p on p.id=e.post_id
 where p_id is null or e.post_id=p_id order by e.created_at desc limit 500;
end;$function$


-- argo_admin_marketing_posts(text)
CREATE OR REPLACE FUNCTION public.argo_admin_marketing_posts(p_token text)
 RETURNS TABLE(id uuid, title text, caption text, hashtags text, media_id uuid, media_title text, media_thumb_url text, media_source_url text, media_category text, media_status text, menu_item_id uuid, menu_item_name text, menu_item_price numeric, menu_item_active boolean, channels text[], kind text, objective text, target_area text, daily_budget numeric, total_budget numeric, status text, scheduled_at timestamp with time zone, approved_at timestamp with time zone, published_at timestamp with time zone, external_ids jsonb, last_error text, created_by text, updated_by text, created_at timestamp with time zone, updated_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;
  return query
  select p.id,p.title,p.caption,p.hashtags,p.media_id,m.title,m.thumb_url,m.source_url,m.category,m.status,
         p.menu_item_id,mi.name,mi.price,mi.active,
         p.channels,p.kind,p.objective,p.target_area,p.daily_budget,p.total_budget,p.status,p.scheduled_at,p.approved_at,p.published_at,
         p.external_ids,p.last_error,p.created_by,p.updated_by,p.created_at,p.updated_at
  from public.argo_marketing_posts p
  left join public.argo_media_library m on m.id=p.media_id
  left join public.argo_menu_items mi on mi.id=p.menu_item_id
  order by coalesce(p.scheduled_at,p.created_at) desc;
end;
$function$


-- argo_admin_marketing_save(text,uuid,text,text,text,uuid,uuid,text[],text,text,text,numeric,numeric,timestamp with time zone)
CREATE OR REPLACE FUNCTION public.argo_admin_marketing_save(p_token text, p_id uuid, p_title text, p_caption text, p_hashtags text, p_media_id uuid, p_menu_item_id uuid, p_channels text[], p_kind text, p_objective text, p_target_area text, p_daily_budget numeric, p_total_budget numeric, p_scheduled_at timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v_email text;
  v_id uuid;
  v_media public.argo_media_library%rowtype;
  v_menu public.argo_menu_items%rowtype;
begin
  if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;
  select s.email into v_email
  from public.argo_admin_sessions s
  where s.token_hash=encode(digest(convert_to(p_token,'UTF8'),'sha256'),'hex') and s.expires_at>now()
  limit 1;

  if coalesce(btrim(p_title),'')='' then raise exception 'Titolo obbligatorio'; end if;
  if p_kind not in ('organic','ad') then raise exception 'Tipo non valido'; end if;
  if coalesce(array_length(p_channels,1),0)=0
     or exists(select 1 from unnest(p_channels) c where c not in ('instagram','facebook','google_business','tiktok'))
  then raise exception 'Canale non valido'; end if;
  if p_daily_budget is not null and p_daily_budget < 0 then raise exception 'Budget giornaliero non valido'; end if;
  if p_total_budget is not null and p_total_budget < 0 then raise exception 'Budget totale non valido'; end if;
  if p_kind='ad' and coalesce(p_total_budget,0)<=0 then raise exception 'Budget totale obbligatorio per ads'; end if;

  if p_media_id is not null then
    select * into v_media from public.argo_media_library where id=p_media_id and active=true;
    if not found then raise exception 'Media non valido'; end if;
    if not (v_media.status='menu' or v_media.category in ('hero','heritage','social','social_verified')) then
      raise exception 'La foto non è approvata per pubblicazione social';
    end if;
  end if;

  if p_menu_item_id is not null then
    select * into v_menu from public.argo_menu_items where id=p_menu_item_id;
    if not found then raise exception 'Prodotto menu non valido'; end if;
    if not v_menu.active then raise exception 'Il prodotto selezionato non è attivo nel menu'; end if;
  end if;

  if p_media_id is not null and p_menu_item_id is not null
     and v_media.status='menu'
     and v_media.linked_menu_item_id is distinct from p_menu_item_id then
    raise exception 'La foto menu selezionata è verificata per un altro prodotto';
  end if;

  if p_id is null then
    insert into public.argo_marketing_posts(title,caption,hashtags,media_id,menu_item_id,channels,kind,objective,target_area,daily_budget,total_budget,scheduled_at,created_by,updated_by)
    values (btrim(p_title),coalesce(p_caption,''),coalesce(p_hashtags,''),p_media_id,p_menu_item_id,p_channels,p_kind,nullif(btrim(coalesce(p_objective,'')),''),nullif(btrim(coalesce(p_target_area,'')),''),p_daily_budget,p_total_budget,p_scheduled_at,v_email,v_email)
    returning id into v_id;
    insert into public.argo_marketing_events(post_id,admin_email,action,new_status,detail)
    values(v_id,v_email,'create','draft',jsonb_build_object('menu_item_id',p_menu_item_id,'media_id',p_media_id));
  else
    update public.argo_marketing_posts
       set title=btrim(p_title),caption=coalesce(p_caption,''),hashtags=coalesce(p_hashtags,''),media_id=p_media_id,menu_item_id=p_menu_item_id,
           channels=p_channels,kind=p_kind,objective=nullif(btrim(coalesce(p_objective,'')),''),target_area=nullif(btrim(coalesce(p_target_area,'')),''),
           daily_budget=p_daily_budget,total_budget=p_total_budget,scheduled_at=p_scheduled_at,status='draft',approved_at=null,last_error=null,updated_by=v_email,updated_at=now()
     where id=p_id and status in ('draft','approved','scheduled','failed')
     returning id into v_id;
    if v_id is null then raise exception 'Post non modificabile nello stato corrente'; end if;
    insert into public.argo_marketing_events(post_id,admin_email,action,new_status,detail)
    values(v_id,v_email,'edit','draft',jsonb_build_object('scheduled_at',p_scheduled_at,'approval_reset',true,'menu_item_id',p_menu_item_id,'media_id',p_media_id));
  end if;
  return v_id;
end;
$function$


-- argo_admin_media(text)
CREATE OR REPLACE FUNCTION public.argo_admin_media(p_token text)
 RETURNS TABLE(id uuid, title text, source_filename text, source_drive_id text, source_url text, thumb_url text, category text, recommended_for text, linked_menu_item_id uuid, linked_menu_item_name text, status text, notes text, sort_order integer, preview_storage_path text, menu_derivative_ready boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not public.argo_admin_valid(p_token) then raise exception 'unauthorized'; end if;
  return query
  select
    m.id,
    m.title,
    m.source_filename,
    null::text as source_drive_id,
    m.source_url,
    ('https://zibubwrntdmdxyimqddo.supabase.co/functions/v1/argo-photo-thumb?media=' || m.id::text)::text as thumb_url,
    m.category,
    m.recommended_for,
    m.linked_menu_item_id,
    i.name,
    m.status,
    m.notes,
    m.sort_order,
    m.preview_storage_path,
    m.menu_derivative_ready
  from public.argo_media_library m
  left join public.argo_menu_items i on i.id=m.linked_menu_item_id
  where m.active=true
  order by case m.status when 'menu' then 0 when 'future' then 1 else 2 end,m.sort_order,m.created_at desc;
end
$function$


-- argo_admin_media_import_status(text)
CREATE OR REPLACE FUNCTION public.argo_admin_media_import_status(p_token text)
 RETURNS TABLE(id uuid, source_filename text, preview_storage_path text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not public.argo_admin_valid(p_token) then raise exception 'unauthorized'; end if;
  return query
  select m.id,m.source_filename,m.preview_storage_path
  from public.argo_media_library m
  where m.active=true
  order by m.source_filename;
end $function$


-- argo_admin_media_review(text,uuid,text,text,text,text,uuid,boolean)
CREATE OR REPLACE FUNCTION public.argo_admin_media_review(p_token text, p_media_id uuid, p_category text, p_status text, p_recommended_for text, p_notes text, p_linked_menu_item_id uuid DEFAULT NULL::uuid, p_sync_menu_image boolean DEFAULT false)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v_old_category text;
  v_old_status text;
  v_old_link uuid;
  v_admin_email text;
  v_public_url text;
  v_derivative_ready boolean;
  v_previous record;
  v_version text;
begin
  if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;

  select category,status,linked_menu_item_id,menu_derivative_ready
  into v_old_category,v_old_status,v_old_link,v_derivative_ready
  from public.argo_media_library
  where id=p_media_id and active=true
  for update;

  if not found then raise exception 'Media item not found'; end if;
  if p_status not in ('menu','future','archive') then raise exception 'Invalid media status'; end if;
  if p_category is null or btrim(p_category)='' then raise exception 'Category required'; end if;
  if p_category='menu_verified' and (p_status<>'menu' or p_linked_menu_item_id is null) then raise exception 'menu_verified requires menu status and an exact active menu item'; end if;
  if p_category='menu_verified_unlinked' and (p_status<>'future' or p_linked_menu_item_id is not null) then raise exception 'menu_verified_unlinked requires future status and no menu link'; end if;
  if p_status='menu' and p_category<>'menu_verified' then raise exception 'Menu status requires menu_verified category'; end if;
  if p_status='menu' and p_linked_menu_item_id is null then raise exception 'Menu status requires an exact linked menu item'; end if;
  if (p_status='menu' or p_sync_menu_image) and not v_derivative_ready then raise exception 'Crop and mobile QA required before menu publication'; end if;
  if p_status='archive' and p_linked_menu_item_id is not null then raise exception 'Archived media cannot stay linked to a menu item'; end if;
  if p_sync_menu_image and (p_status<>'menu' or p_category<>'menu_verified' or p_linked_menu_item_id is null) then raise exception 'Image sync requires menu_verified + menu status + exact menu item'; end if;
  if p_linked_menu_item_id is not null and not exists(select 1 from public.argo_menu_items where id=p_linked_menu_item_id and active=true) then raise exception 'Active menu item not found'; end if;

  select s.email into v_admin_email
  from public.argo_admin_sessions s
  join public.argo_admin_users u on u.email=s.email and u.active=true
  where s.token_hash=encode(digest(convert_to(p_token,'UTF8'),'sha256'),'hex')
    and s.expires_at>now()
  limit 1;

  if p_status='menu' and p_category='menu_verified' then
    for v_previous in
      select id,category,status,linked_menu_item_id
      from public.argo_media_library
      where active=true
        and id<>p_media_id
        and linked_menu_item_id=p_linked_menu_item_id
        and category='menu_verified'
        and status='menu'
      for update
    loop
      update public.argo_media_library
      set category='menu_candidate',status='future'
      where id=v_previous.id;

      insert into public.argo_media_review_events(
        media_id,admin_email,old_category,new_category,old_status,new_status,
        old_linked_menu_item_id,new_linked_menu_item_id,sync_menu_image,notes
      ) values(
        v_previous.id,v_admin_email,v_previous.category,'menu_candidate',
        v_previous.status,'future',v_previous.linked_menu_item_id,
        v_previous.linked_menu_item_id,false,
        'Sostituita da una nuova foto verificata; file e crop conservati.'
      );
    end loop;
  end if;

  update public.argo_media_library
  set category=btrim(p_category),
      status=p_status,
      recommended_for=nullif(btrim(coalesce(p_recommended_for,'')),''),
      notes=nullif(btrim(coalesce(p_notes,'')),''),
      linked_menu_item_id=case when p_status='archive' then null else p_linked_menu_item_id end
  where id=p_media_id;

  if p_sync_menu_image then
    delete from public.argo_public_menu_photo_cache
    where item_id=p_linked_menu_item_id;

    v_version := to_char(clock_timestamp(),'YYYYMMDDHH24MISSMS');
    v_public_url := 'https://zibubwrntdmdxyimqddo.supabase.co/functions/v1/argo-public-menu-photo?item=' || p_linked_menu_item_id::text || '&v=' || v_version;

    update public.argo_menu_items
    set image_url=v_public_url,updated_at=now()
    where id=p_linked_menu_item_id and active=true;
  end if;

  insert into public.argo_media_review_events(
    media_id,admin_email,old_category,new_category,old_status,new_status,
    old_linked_menu_item_id,new_linked_menu_item_id,sync_menu_image,notes
  ) values(
    p_media_id,v_admin_email,v_old_category,btrim(p_category),v_old_status,p_status,
    v_old_link,case when p_status='archive' then null else p_linked_menu_item_id end,
    p_sync_menu_image,nullif(btrim(coalesce(p_notes,'')),'')
  );

  return true;
end
$function$


-- argo_admin_media_review_history(text,uuid)
CREATE OR REPLACE FUNCTION public.argo_admin_media_review_history(p_token text, p_media_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(id uuid, media_id uuid, source_filename text, admin_email text, old_category text, new_category text, old_status text, new_status text, old_linked_menu_item_id uuid, new_linked_menu_item_id uuid, sync_menu_image boolean, notes text, created_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;
  return query
  select e.id,e.media_id,m.source_filename,e.admin_email,e.old_category,e.new_category,
         e.old_status,e.new_status,e.old_linked_menu_item_id,e.new_linked_menu_item_id,
         e.sync_menu_image,e.notes,e.created_at
  from public.argo_media_review_events e
  join public.argo_media_library m on m.id=e.media_id
  where p_media_id is null or e.media_id=p_media_id
  order by e.created_at desc
  limit 500;
end;
$function$


-- argo_admin_menu(text)
CREATE OR REPLACE FUNCTION public.argo_admin_menu(p_token text)
 RETURNS SETOF argo_menu_items
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if; return query select * from public.argo_menu_items order by sort_order, name; end;$function$


-- argo_admin_offers(text)
CREATE OR REPLACE FUNCTION public.argo_admin_offers(p_token text)
 RETURNS SETOF argo_offers
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if; return query select * from public.argo_offers order by priority desc,created_at desc; end;$function$


-- argo_admin_order_action(text,uuid,text)
CREATE OR REPLACE FUNCTION public.argo_admin_order_action(p_token text, p_order_id uuid, p_action text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v public.argo_orders%rowtype;
  v_old text;
  v_email text;
begin
  if not public.argo_admin_valid(p_token) then raise exception 'unauthorized'; end if;
  select s.email into v_email from public.argo_admin_sessions s
   where s.token_hash=encode(digest(convert_to(p_token,'UTF8'),'sha256'),'hex') and s.expires_at>now() limit 1;

  select * into v from public.argo_orders where id=p_order_id for update;
  if v.id is null then raise exception 'order_not_found'; end if;
  v_old := v.status;

  if p_action='accept_print' then
    if v.status <> 'new' then raise exception 'invalid_transition_%_to_accepted',v.status; end if;
    update public.argo_orders set status='accepted',accepted_at=coalesce(accepted_at,now()),printed_at=now(),print_count=coalesce(print_count,0)+1,updated_at=now() where id=p_order_id returning * into v;
  elsif p_action='reprint' then
    if v.status='cancelled' then raise exception 'cannot_reprint_cancelled_order'; end if;
    update public.argo_orders set printed_at=now(),print_count=coalesce(print_count,0)+1,updated_at=now() where id=p_order_id returning * into v;
  elsif p_action='preparing' then
    if v.status <> 'accepted' then raise exception 'invalid_transition_%_to_preparing',v.status; end if;
    update public.argo_orders set status='preparing',updated_at=now() where id=p_order_id returning * into v;
  elsif p_action='ready' then
    if v.status not in ('accepted','preparing') then raise exception 'invalid_transition_%_to_ready',v.status; end if;
    update public.argo_orders set status='ready',updated_at=now() where id=p_order_id returning * into v;
  elsif p_action='completed' then
    if v.status <> 'ready' then raise exception 'invalid_transition_%_to_completed',v.status; end if;
    update public.argo_orders set status='completed',updated_at=now() where id=p_order_id returning * into v;
  elsif p_action='cancelled' then
    if v.status in ('completed','cancelled') then raise exception 'invalid_transition_%_to_cancelled',v.status; end if;
    update public.argo_orders set status='cancelled',updated_at=now() where id=p_order_id returning * into v;
  else
    raise exception 'invalid_action';
  end if;

  insert into public.argo_order_events(order_id,admin_email,action,old_status,new_status,detail)
  values(v.id,v_email,p_action,v_old,v.status,jsonb_build_object('print_count',v.print_count,'printed_at',v.printed_at));

  return jsonb_build_object('id',v.id,'order_number',v.order_number,'old_status',v_old,'status',v.status,'print_count',v.print_count);
end;
$function$


-- argo_admin_order_history(text,uuid)
CREATE OR REPLACE FUNCTION public.argo_admin_order_history(p_token text, p_order_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(id bigint, order_id uuid, order_number bigint, admin_email text, action text, old_status text, new_status text, detail jsonb, created_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not public.argo_admin_valid(p_token) then raise exception 'unauthorized'; end if;
  return query
  select e.id,e.order_id,o.order_number,e.admin_email,e.action,e.old_status,e.new_status,e.detail,e.created_at
  from public.argo_order_events e join public.argo_orders o on o.id=e.order_id
  where p_order_id is null or e.order_id=p_order_id
  order by e.created_at desc
  limit 500;
end;
$function$


-- argo_admin_orders(text)
CREATE OR REPLACE FUNCTION public.argo_admin_orders(p_token text)
 RETURNS TABLE(id uuid, order_number bigint, customer_name text, phone text, email text, order_type text, requested_at timestamp with time zone, address text, notes text, payment_method text, payment_status text, status text, subtotal numeric, delivery_fee numeric, discount_amount numeric, promo_code text, total numeric, accepted_at timestamp with time zone, printed_at timestamp with time zone, print_count integer, created_at timestamp with time zone, items jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
 if not argo_admin_valid(p_token) then raise exception 'unauthorized'; end if;
 return query
 select o.id,o.order_number,o.customer_name,o.phone,o.email,o.order_type,o.requested_at,null::text as address,o.notes,o.payment_method,o.payment_status,o.status,o.subtotal,o.delivery_fee,o.discount_amount,o.promo_code,o.total,o.accepted_at,o.printed_at,o.print_count,o.created_at,
 coalesce((select jsonb_agg(jsonb_build_object('id',i.id,'name',i.name,'quantity',i.quantity,'unit_price',i.unit_price,'line_total',i.line_total,'notes',i.notes,'modifiers',i.modifiers) order by i.created_at) from argo_order_items i where i.order_id=o.id),'[]'::jsonb)
 from argo_orders o
 where o.order_type='asporto'
 order by case when o.status='new' then 0 else 1 end,o.created_at desc
 limit 200;
end
$function$


-- argo_admin_promos(text)
CREATE OR REPLACE FUNCTION public.argo_admin_promos(p_token text)
 RETURNS TABLE(id uuid, title text, code text, discount_type text, discount_value numeric, min_order numeric, max_uses integer, uses_count integer, per_customer_limit integer, starts_at timestamp with time zone, ends_at timestamp with time zone, active boolean, priority integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
 if not argo_admin_valid(p_token) then raise exception 'unauthorized'; end if;
 return query select o.id,o.title,o.code,o.discount_type,o.discount_value,o.min_order,o.max_uses,o.uses_count,o.per_customer_limit,o.starts_at,o.ends_at,o.active,o.priority from argo_offers o where o.code is not null and trim(o.code)<>'' order by o.active desc,o.priority desc,o.created_at desc;
end $function$


-- argo_admin_push_set_active(text,uuid,boolean)
CREATE OR REPLACE FUNCTION public.argo_admin_push_set_active(p_token text, p_subscription_id uuid, p_active boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not public.argo_admin_valid(p_token) then
    raise exception 'Unauthorized';
  end if;

  update public.argo_push_subscriptions
  set active = p_active,
      updated_at = now()
  where id = p_subscription_id;

  if not found then
    raise exception 'subscription_not_found';
  end if;

  return true;
end;
$function$


-- argo_admin_push_status(text)
CREATE OR REPLACE FUNCTION public.argo_admin_push_status(p_token text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v_active int;
  v_total int;
  v_stale int;
  v_last_test jsonb;
  v_last_dispatch jsonb;
  v_devices jsonb;
begin
  if not public.argo_admin_valid(p_token) then
    raise exception 'Unauthorized';
  end if;

  select count(*) filter (where active),
         count(*),
         count(*) filter (where active and updated_at < now() - interval '30 days')
  into v_active, v_total, v_stale
  from public.argo_push_subscriptions;

  select to_jsonb(x) into v_last_test
  from (
    select requested_at, scheduled_for, completed_at, sent_count, failed_count, removed_count
    from public.argo_push_test_runs
    order by requested_at desc
    limit 1
  ) x;

  select to_jsonb(x) into v_last_dispatch
  from (
    select d.created_at, d.completed_at, d.sent_count, d.failed_count, o.order_number
    from public.argo_push_dispatches d
    join public.argo_orders o on o.id = d.order_id
    order by d.created_at desc
    limit 1
  ) x;

  select coalesce(jsonb_agg(to_jsonb(x) order by x.active desc, x.stale desc, x.updated_at desc), '[]'::jsonb)
  into v_devices
  from (
    select
      id,
      active,
      created_at,
      updated_at,
      (active and updated_at < now() - interval '30 days') as stale,
      greatest(0, floor(extract(epoch from (now()-updated_at))/86400))::int as days_since_update,
      case
        when lower(coalesce(user_agent,'')) like '%android%' then 'Android'
        when lower(coalesce(user_agent,'')) like '%iphone%' or lower(coalesce(user_agent,'')) like '%ipad%' then 'iPhone/iPad'
        when lower(coalesce(user_agent,'')) like '%windows%' then 'Windows'
        when lower(coalesce(user_agent,'')) like '%macintosh%' then 'Mac'
        else 'Altro'
      end as platform,
      case
        when lower(coalesce(user_agent,'')) like '%edg/%' then 'Edge'
        when lower(coalesce(user_agent,'')) like '%chrome/%' and lower(coalesce(user_agent,'')) not like '%edg/%' then 'Chrome'
        when lower(coalesce(user_agent,'')) like '%safari/%' and lower(coalesce(user_agent,'')) not like '%chrome/%' then 'Safari'
        else 'Browser'
      end as browser
    from public.argo_push_subscriptions
  ) x;

  return jsonb_build_object(
    'active_subscriptions', v_active,
    'total_subscriptions', v_total,
    'stale_active_subscriptions', v_stale,
    'last_test', v_last_test,
    'last_dispatch', v_last_dispatch,
    'health', case
      when v_active = 0 then 'no_active_devices'
      when v_stale > 0 then 'stale_devices'
      when v_last_dispatch is not null and coalesce((v_last_dispatch->>'failed_count')::int,0) > 0 then 'dispatch_failed'
      when v_last_dispatch is not null then 'ok'
      else 'ready_no_dispatch'
    end,
    'devices', v_devices
  );
end;
$function$


-- argo_admin_push_subscribe(text,text,text,text,text)
CREATE OR REPLACE FUNCTION public.argo_admin_push_subscribe(p_token text, p_endpoint text, p_p256dh text, p_auth text, p_user_agent text DEFAULT NULL::text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not public.argo_admin_valid(p_token) then
    raise exception 'unauthorized';
  end if;
  if coalesce(trim(p_endpoint),'')='' or coalesce(trim(p_p256dh),'')='' or coalesce(trim(p_auth),'')='' then
    raise exception 'invalid_subscription';
  end if;
  insert into public.argo_push_subscriptions(endpoint,p256dh,auth,user_agent,active,updated_at)
  values(trim(p_endpoint),trim(p_p256dh),trim(p_auth),p_user_agent,true,now())
  on conflict (endpoint) do update set
    p256dh=excluded.p256dh,
    auth=excluded.auth,
    user_agent=excluded.user_agent,
    active=true,
    updated_at=now();
  return true;
end;
$function$


-- argo_admin_save_push_subscription(text,text,text,text,text)
CREATE OR REPLACE FUNCTION public.argo_admin_save_push_subscription(p_token text, p_endpoint text, p_p256dh text, p_auth text, p_user_agent text DEFAULT NULL::text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$ begin if not argo_admin_valid(p_token) then raise exception 'unauthorized'; end if; insert into argo_push_subscriptions(endpoint,p256dh,auth,user_agent,active,updated_at) values(p_endpoint,p_p256dh,p_auth,p_user_agent,true,now()) on conflict(endpoint) do update set p256dh=excluded.p256dh,auth=excluded.auth,user_agent=excluded.user_agent,active=true,updated_at=now(); return true; end $function$


-- argo_admin_stats(text)
CREATE OR REPLACE FUNCTION public.argo_admin_stats(p_token text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v_tz text := 'Europe/Rome';
  v_today date := (now() at time zone v_tz)::date;
  v_result jsonb;
begin
  if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;

  select jsonb_build_object(
    'today', jsonb_build_object(
      'orders', count(*) filter (where (o.created_at at time zone v_tz)::date=v_today and o.status<>'cancelled'),
      'sales', coalesce(sum(o.total) filter (where (o.created_at at time zone v_tz)::date=v_today and o.status<>'cancelled'),0),
      'avg', coalesce(avg(o.total) filter (where (o.created_at at time zone v_tz)::date=v_today and o.status<>'cancelled'),0)
    ),
    'last7', jsonb_build_object(
      'orders', count(*) filter (where o.created_at >= now()-interval '7 days' and o.status<>'cancelled'),
      'sales', coalesce(sum(o.total) filter (where o.created_at >= now()-interval '7 days' and o.status<>'cancelled'),0),
      'avg', coalesce(avg(o.total) filter (where o.created_at >= now()-interval '7 days' and o.status<>'cancelled'),0)
    ),
    'last30', jsonb_build_object(
      'orders', count(*) filter (where o.created_at >= now()-interval '30 days' and o.status<>'cancelled'),
      'sales', coalesce(sum(o.total) filter (where o.created_at >= now()-interval '30 days' and o.status<>'cancelled'),0),
      'avg', coalesce(avg(o.total) filter (where o.created_at >= now()-interval '30 days' and o.status<>'cancelled'),0)
    ),
    'open_orders', count(*) filter (where o.status not in ('completed','cancelled')),
    'cancelled30', count(*) filter (where o.created_at >= now()-interval '30 days' and o.status='cancelled'),
    'pickup30', count(*) filter (where o.created_at >= now()-interval '30 days' and o.status<>'cancelled' and o.order_type='asporto'),
    'avg_accept_min30', coalesce(round(avg(extract(epoch from (o.accepted_at-o.created_at))/60.0) filter (where o.created_at >= now()-interval '30 days' and o.accepted_at is not null and o.status<>'cancelled')::numeric,1),0),
    'printed30', count(*) filter (where o.created_at >= now()-interval '30 days' and coalesce(o.print_count,0)>0 and o.status<>'cancelled'),
    'reprints30', coalesce(sum(greatest(coalesce(o.print_count,0)-1,0)) filter (where o.created_at >= now()-interval '30 days' and o.status<>'cancelled'),0)
  ) into v_result
  from public.argo_orders o;

  v_result := v_result || jsonb_build_object(
    'top_products', coalesce((
      select jsonb_agg(x order by (x->>'revenue')::numeric desc)
      from (
        select jsonb_build_object('name',oi.name,'qty',sum(oi.quantity),'revenue',sum(oi.line_total)) x
        from public.argo_order_items oi
        join public.argo_orders o on o.id=oi.order_id
        where o.created_at >= now()-interval '30 days' and o.status<>'cancelled'
        group by oi.name
        order by sum(oi.line_total) desc
        limit 10
      ) q
    ),'[]'::jsonb),
    'status_breakdown', coalesce((
      select jsonb_agg(jsonb_build_object('status',q.status,'count',q.cnt) order by q.cnt desc)
      from (
        select o.status,count(*) cnt
        from public.argo_orders o
        where o.created_at >= now()-interval '30 days'
        group by o.status
      ) q
    ),'[]'::jsonb)
  );

  return v_result;
end;
$function$


-- argo_admin_toggle_promo(text,uuid,boolean)
CREATE OR REPLACE FUNCTION public.argo_admin_toggle_promo(p_token text, p_id uuid, p_active boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
 if not argo_admin_valid(p_token) then raise exception 'unauthorized'; end if;
 update argo_offers set active=p_active where id=p_id;
 return found;
end $function$


-- argo_admin_update_item(text,uuid,text,numeric,text,boolean)
CREATE OR REPLACE FUNCTION public.argo_admin_update_item(p_token text, p_id uuid, p_name text, p_price numeric, p_image_url text, p_active boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v_current_image text;
begin
  if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;
  select image_url into v_current_image from public.argo_menu_items where id=p_id for update;
  if not found then return false; end if;
  if coalesce(p_image_url,'') is distinct from coalesce(v_current_image,'') then
    raise exception 'Le immagini menu si gestiscono solo tramite Verifica Foto';
  end if;
  if coalesce(btrim(p_name),'')='' then raise exception 'Nome obbligatorio'; end if;
  if p_price is null or p_price < 0 then raise exception 'Prezzo non valido'; end if;
  update public.argo_menu_items
     set name=btrim(p_name), price=p_price, active=p_active, updated_at=now()
   where id=p_id;
  return found;
end;
$function$


-- argo_admin_upsert_promo(text,uuid,text,text,text,numeric,numeric,integer,integer,timestamp with time zone,timestamp with time zone,boolean)
CREATE OR REPLACE FUNCTION public.argo_admin_upsert_promo(p_token text, p_id uuid, p_title text, p_code text, p_discount_type text, p_discount_value numeric, p_min_order numeric, p_max_uses integer, p_per_customer_limit integer, p_starts_at timestamp with time zone, p_ends_at timestamp with time zone, p_active boolean)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare v_id uuid;
begin
 if not argo_admin_valid(p_token) then raise exception 'unauthorized'; end if;
 if coalesce(trim(p_title),'')='' then raise exception 'title_required'; end if;
 if coalesce(trim(p_code),'')='' then raise exception 'code_required'; end if;
 if p_discount_type not in ('percent','fixed') then raise exception 'invalid_discount_type'; end if;
 if coalesce(p_discount_value,0)<=0 then raise exception 'invalid_discount_value'; end if;
 if p_discount_type='percent' and p_discount_value>100 then raise exception 'invalid_percent'; end if;
 if coalesce(p_min_order,0)<0 then raise exception 'invalid_min_order'; end if;
 if p_max_uses is not null and p_max_uses<1 then raise exception 'invalid_max_uses'; end if;
 if coalesce(p_per_customer_limit,0)<0 then raise exception 'invalid_per_customer_limit'; end if;
 if p_starts_at is not null and p_ends_at is not null and p_ends_at<=p_starts_at then raise exception 'invalid_date_range'; end if;
 if exists(select 1 from public.argo_offers o where lower(trim(o.code))=lower(trim(p_code)) and (p_id is null or o.id<>p_id)) then raise exception 'code_already_exists'; end if;
 if p_id is null then
   insert into argo_offers(title,body,code,active,priority,discount_type,discount_value,min_order,max_uses,per_customer_limit,starts_at,ends_at)
   values(trim(p_title),'',upper(trim(p_code)),coalesce(p_active,true),0,p_discount_type,p_discount_value,coalesce(p_min_order,0),p_max_uses,coalesce(p_per_customer_limit,1),p_starts_at,p_ends_at) returning id into v_id;
 else
   update argo_offers set title=trim(p_title),code=upper(trim(p_code)),discount_type=p_discount_type,discount_value=p_discount_value,min_order=coalesce(p_min_order,0),max_uses=p_max_uses,per_customer_limit=coalesce(p_per_customer_limit,1),starts_at=p_starts_at,ends_at=p_ends_at,active=coalesce(p_active,true) where id=p_id returning id into v_id;
   if v_id is null then raise exception 'promo_not_found'; end if;
 end if;
 return v_id;
end
$function$


-- argo_admin_valid(text)
CREATE OR REPLACE FUNCTION public.argo_admin_valid(p_token text)
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
  select exists(
    select 1 from public.argo_admin_sessions s
    join public.argo_admin_users u on u.email=s.email and u.active=true
    where s.token_hash=encode(digest(convert_to(p_token,'UTF8'),'sha256'),'hex') and s.expires_at>now()
  );
$function$


-- argo_admin_weekly_promos(text)
CREATE OR REPLACE FUNCTION public.argo_admin_weekly_promos(p_token text)
 RETURNS TABLE(day_no integer, day_name text, code text, title text, discount_type text, discount_value numeric, min_order numeric, active boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
 if not argo_admin_valid(p_token) then raise exception 'unauthorized'; end if;
 return query
 with days(day_no,day_name) as (values
   (1,'Lunedì'),(2,'Martedì'),(3,'Mercoledì'),(4,'Giovedì'),(5,'Venerdì'),(6,'Sabato'),(7,'Domenica')
 )
 select d.day_no,d.day_name,o.code,o.title,o.discount_type,o.discount_value,o.min_order,o.active
 from days d
 left join argo_offers o on o.recurring_weekdays @> array[d.day_no]::smallint[]
 order by d.day_no,o.priority desc nulls last;
end $function$


-- argo_admin_withdraw_menu_photo(text,uuid)
CREATE OR REPLACE FUNCTION public.argo_admin_withdraw_menu_photo(p_token text, p_item_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v_media public.argo_media_library%rowtype;
  v_admin_email text;
begin
  if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;
  perform 1 from public.argo_menu_items where id=p_item_id and active=true and image_url is not null for update;
  if not found then raise exception 'Active menu photo not found'; end if;
  select * into v_media from public.argo_media_library
  where linked_menu_item_id=p_item_id and category='menu_verified' and status='menu' and active=true
  order by created_at desc limit 1 for update;
  if not found then raise exception 'Verified media mapping not found'; end if;
  select s.email into v_admin_email
  from public.argo_admin_sessions s join public.argo_admin_users u on u.email=s.email and u.active=true
  where s.token_hash=encode(digest(convert_to(p_token,'UTF8'),'sha256'),'hex') and s.expires_at>now() limit 1;
  update public.argo_menu_items set image_url=null,updated_at=now() where id=p_item_id;
  update public.argo_media_library set category='menu_candidate',status='future' where id=v_media.id;
  insert into public.argo_media_review_events(media_id,admin_email,old_category,new_category,old_status,new_status,old_linked_menu_item_id,new_linked_menu_item_id,sync_menu_image,notes)
  values(v_media.id,v_admin_email,v_media.category,'menu_candidate',v_media.status,'future',v_media.linked_menu_item_id,v_media.linked_menu_item_id,false,'Foto rimossa dal menu; file e crop conservati per una nuova verifica.');
  return true;
end
$function$


-- argo_customer_key(text,text)
CREATE OR REPLACE FUNCTION public.argo_customer_key(p_phone text, p_email text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
 select case when regexp_replace(coalesce(p_phone,''),'\D','','g')<>'' then regexp_replace(coalesce(p_phone,''),'\D','','g') else lower(trim(coalesce(p_email,''))) end
$function$


-- argo_enforce_pickup_hours()
CREATE OR REPLACE FUNCTION public.argo_enforce_pickup_hours()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  local_ts timestamp;
  local_dow int;
  local_t time;
begin
  if new.order_type = 'asporto' then
    if new.requested_at is null then
      raise exception 'pickup_closed';
    end if;
    local_ts := new.requested_at at time zone 'Europe/Rome';
    local_dow := extract(dow from local_ts);
    local_t := local_ts::time;
    if local_dow = 3 or local_t < time '18:30' or local_t > time '23:00' then
      raise exception 'pickup_closed';
    end if;
  end if;
  return new;
end;
$function$


-- argo_enforce_pickup_minimum()
CREATE OR REPLACE FUNCTION public.argo_enforce_pickup_minimum()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  if new.order_type in ('asporto','pickup') then
    if new.requested_at is null or new.requested_at < now() + interval '30 minutes' then
      new.requested_at := now() + interval '30 minutes';
    end if;
  end if;
  return new;
end;
$function$


-- argo_enforce_pickup_only()
CREATE OR REPLACE FUNCTION public.argo_enforce_pickup_only()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  if new.order_type is distinct from 'asporto' then
    raise exception 'delivery_not_supported_use_deliveroo_or_justeat';
  end if;
  new.delivery_fee := 0;
  new.address := null;
  return new;
end;
$function$


-- argo_notify_order_push()
CREATE OR REPLACE FUNCTION public.argo_notify_order_push()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v_secret text;
begin
  select secret into v_secret from public.argo_internal_config where key='order_push_secret';
  if coalesce(v_secret,'')='' then
    raise warning 'ARGO push secret missing; notification not dispatched for order %', new.id;
    return new;
  end if;
  perform net.http_post(
    url := 'https://zibubwrntdmdxyimqddo.supabase.co/functions/v1/argo-push-order',
    headers := jsonb_build_object('Content-Type','application/json','X-ARGO-Push-Secret',v_secret),
    body := jsonb_build_object(
      'type','INSERT',
      'table','argo_orders',
      'schema','public',
      'record',jsonb_build_object('id',new.id),
      'old_record',null
    ),
    timeout_milliseconds := 5000
  );
  return new;
end;
$function$


-- argo_place_order(text,text,text,text,timestamp with time zone,text,text,text,jsonb)
CREATE OR REPLACE FUNCTION public.argo_place_order(p_customer_name text, p_phone text, p_email text, p_order_type text, p_requested_at timestamp with time zone, p_address text, p_notes text, p_payment_method text, p_items jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  return public.argo_place_order(
    p_customer_name,
    p_phone,
    p_email,
    p_order_type,
    p_requested_at,
    p_address,
    p_notes,
    p_payment_method,
    p_items,
    null::text
  );
end;
$function$


-- argo_place_order(text,text,text,text,timestamp with time zone,text,text,text,jsonb,text)
CREATE OR REPLACE FUNCTION public.argo_place_order(p_customer_name text, p_phone text, p_email text, p_order_type text, p_requested_at timestamp with time zone, p_address text, p_notes text, p_payment_method text, p_items jsonb, p_promo_code text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
 v_order uuid; v_no bigint; v_subtotal numeric(10,2):=0; v_total numeric(10,2); v_discount numeric(10,2):=0;
 v_offer uuid; v_promo jsonb; v_ck text; x jsonb; mi argo_menu_items%rowtype; q int; base_line numeric(10,2);
 mods jsonb; mod_ids uuid[]; mod_extra numeric(10,2); mod_notes text; invalid_count int; grp_bad int;
begin
 if coalesce(trim(p_customer_name),'')='' or coalesce(trim(p_phone),'')='' then raise exception 'name_and_phone_required'; end if;
 if p_order_type not in ('asporto','delivery') then raise exception 'invalid_order_type'; end if;
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

 insert into argo_orders(customer_name,phone,email,order_type,requested_at,address,notes,payment_method,subtotal,discount_amount,total,promo_code,offer_id)
 values(trim(p_customer_name),trim(p_phone),nullif(trim(p_email),''),p_order_type,p_requested_at,nullif(trim(p_address),''),nullif(trim(p_notes),''),coalesce(nullif(p_payment_method,''),'pay_at_store'),v_subtotal,v_discount,v_total,upper(nullif(trim(p_promo_code),'')),v_offer)
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
end $function$


-- argo_public_today_promo()
CREATE OR REPLACE FUNCTION public.argo_public_today_promo()
 RETURNS TABLE(day_no integer, day_name text, code text, title text, discount_type text, discount_value numeric, min_order numeric)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with current_day as (
    select extract(isodow from (now() at time zone 'Europe/Rome'))::integer as day_no
  )
  select w.* from public.argo_public_weekly_promos() w, current_day d where w.day_no=d.day_no;
$function$


-- argo_public_weekly_promos()
CREATE OR REPLACE FUNCTION public.argo_public_weekly_promos()
 RETURNS TABLE(day_no integer, day_name text, code text, title text, discount_type text, discount_value numeric, min_order numeric)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with days(day_no,day_name) as (values
    (1,'Lunedì'),(2,'Martedì'),(3,'Mercoledì'),(4,'Giovedì'),(5,'Venerdì'),(6,'Sabato'),(7,'Domenica')
  )
  select d.day_no,d.day_name,o.code,o.title,o.discount_type,o.discount_value,o.min_order
  from days d
  left join lateral (
    select x.code,x.title,x.discount_type,x.discount_value,x.min_order
    from public.argo_offers x
    where x.active=true
      and x.recurring_weekdays @> array[d.day_no]::smallint[]
      and (x.starts_at is null or x.starts_at<=now())
      and (x.ends_at is null or x.ends_at>now())
      and (x.max_uses is null or x.uses_count<x.max_uses)
    order by x.priority desc,x.created_at desc
    limit 1
  ) o on true
  order by d.day_no;
$function$


-- argo_public_welcome_offer()
CREATE OR REPLACE FUNCTION public.argo_public_welcome_offer()
 RETURNS TABLE(code text, title text, discount_type text, discount_value numeric, min_order numeric, first_order_only boolean)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select o.code,o.title,o.discount_type,o.discount_value,o.min_order,o.first_order_only
  from public.argo_offers o
  where o.active=true
    and o.first_order_only=true
    and (o.starts_at is null or o.starts_at<=now())
    and (o.ends_at is null or o.ends_at>now())
    and (o.max_uses is null or o.uses_count<o.max_uses)
  order by o.priority desc,o.created_at desc
  limit 1;
$function$


-- argo_track_order(bigint,text)
CREATE OR REPLACE FUNCTION public.argo_track_order(p_order_number bigint, p_phone text)
 RETURNS TABLE(order_number bigint, status text, order_type text, requested_at timestamp with time zone, created_at timestamp with time zone, accepted_at timestamp with time zone, subtotal numeric, discount_amount numeric, total numeric, items jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_phone_digits text := regexp_replace(coalesce(p_phone,''), '\D', '', 'g');
begin
  if p_order_number is null or v_phone_digits = '' then
    raise exception 'order_number_and_phone_required';
  end if;

  return query
  select
    o.order_number,
    o.status,
    o.order_type,
    o.requested_at,
    o.created_at,
    o.accepted_at,
    o.subtotal,
    o.discount_amount,
    o.total,
    coalesce((
      select jsonb_agg(jsonb_build_object('name', i.name, 'quantity', i.quantity, 'notes', i.notes) order by i.created_at)
      from public.argo_order_items i where i.order_id = o.id
    ), '[]'::jsonb) as items
  from public.argo_orders o
  where o.order_number = p_order_number
    and regexp_replace(coalesce(o.phone,''), '\D', '', 'g') = v_phone_digits
  limit 1;
end;
$function$


-- argo_validate_promo(text,numeric,text,text)
CREATE OR REPLACE FUNCTION public.argo_validate_promo(p_code text, p_subtotal numeric, p_phone text DEFAULT NULL::text, p_email text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
 o argo_offers%rowtype; d numeric(10,2):=0; ck text; used int:=0; prior_orders int:=0; iso_day int;
begin
 if coalesce(trim(p_code),'')='' then return jsonb_build_object('valid',false,'reason','empty_code'); end if;
 select * into o from argo_offers where active=true and upper(trim(code))=upper(trim(p_code)) and (starts_at is null or starts_at<=now()) and (ends_at is null or ends_at>=now()) order by priority desc,created_at desc limit 1;
 if o.id is null then return jsonb_build_object('valid',false,'reason','invalid_or_expired'); end if;
 if o.max_uses is not null and o.uses_count>=o.max_uses then return jsonb_build_object('valid',false,'reason','max_uses_reached'); end if;
 iso_day:=extract(isodow from (now() at time zone 'Europe/Rome'))::int;
 if o.recurring_weekdays is not null and cardinality(o.recurring_weekdays)>0 and not (iso_day=any(o.recurring_weekdays)) then return jsonb_build_object('valid',false,'reason','wrong_day'); end if;
 if p_subtotal<coalesce(o.min_order,0) then return jsonb_build_object('valid',false,'reason','min_order','min_order',o.min_order); end if;
 ck:=argo_customer_key(p_phone,p_email);
 if o.first_order_only then
   if ck='' then return jsonb_build_object('valid',false,'reason','phone_required_first_order'); end if;
   select count(*) into prior_orders from argo_orders x where x.source='argo_web' and x.status not in ('cancelled') and argo_customer_key(x.phone,x.email)=ck;
   if prior_orders>0 then return jsonb_build_object('valid',false,'reason','first_order_only'); end if;
 end if;
 if ck<>'' and coalesce(o.per_customer_limit,0)>0 then
   if o.recurring_weekdays is not null and cardinality(o.recurring_weekdays)>0 then
     select count(*) into used from argo_promo_redemptions r where r.offer_id=o.id and r.customer_key=ck and (r.created_at at time zone 'Europe/Rome')::date=(now() at time zone 'Europe/Rome')::date;
   else
     select count(*) into used from argo_promo_redemptions r where r.offer_id=o.id and r.customer_key=ck;
   end if;
   if used>=o.per_customer_limit then return jsonb_build_object('valid',false,'reason',case when o.recurring_weekdays is not null and cardinality(o.recurring_weekdays)>0 then 'daily_customer_limit' else 'customer_limit' end); end if;
 end if;
 if o.discount_type='percent' then d:=round(p_subtotal*(o.discount_value/100.0),2);
 elsif o.discount_type='fixed' then d:=least(p_subtotal,o.discount_value);
 else return jsonb_build_object('valid',false,'reason','offer_not_configured'); end if;
 d:=greatest(0,least(p_subtotal,d));
 return jsonb_build_object('valid',true,'offer_id',o.id,'code',o.code,'title',o.title,'discount_type',o.discount_type,'discount_value',o.discount_value,'discount_amount',d,'total',p_subtotal-d,'first_order_only',o.first_order_only,'recurring_weekdays',o.recurring_weekdays);
end $function$

