create or replace function public.argo_admin_media_review(p_token text,p_media_id uuid,p_category text,p_status text,p_recommended_for text,p_notes text,p_linked_menu_item_id uuid default null,p_sync_menu_image boolean default false)
returns boolean language plpgsql security definer set search_path to 'public', 'extensions'
as $function$
declare
  v_old_category text; v_old_status text; v_old_link uuid; v_admin_email text; v_public_url text; v_derivative_ready boolean; v_previous record;
begin
  if not public.argo_admin_valid(p_token) then raise exception 'Unauthorized'; end if;
  select category,status,linked_menu_item_id,menu_derivative_ready into v_old_category,v_old_status,v_old_link,v_derivative_ready
  from public.argo_media_library where id=p_media_id and active=true for update;
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
  select s.email into v_admin_email from public.argo_admin_sessions s join public.argo_admin_users u on u.email=s.email and u.active=true
  where s.token_hash=encode(digest(convert_to(p_token,'UTF8'),'sha256'),'hex') and s.expires_at>now() limit 1;

  if p_status='menu' and p_category='menu_verified' then
    for v_previous in
      select id,category,status,linked_menu_item_id from public.argo_media_library
      where active=true and id<>p_media_id and linked_menu_item_id=p_linked_menu_item_id and category='menu_verified' and status='menu'
      for update
    loop
      update public.argo_media_library set category='menu_candidate',status='future' where id=v_previous.id;
      insert into public.argo_media_review_events(media_id,admin_email,old_category,new_category,old_status,new_status,old_linked_menu_item_id,new_linked_menu_item_id,sync_menu_image,notes)
      values(v_previous.id,v_admin_email,v_previous.category,'menu_candidate',v_previous.status,'future',v_previous.linked_menu_item_id,v_previous.linked_menu_item_id,false,'Sostituita da una nuova foto verificata; file e crop conservati.');
    end loop;
  end if;

  update public.argo_media_library set category=btrim(p_category),status=p_status,recommended_for=nullif(btrim(coalesce(p_recommended_for,'')),''),
    notes=nullif(btrim(coalesce(p_notes,'')),''),linked_menu_item_id=case when p_status='archive' then null else p_linked_menu_item_id end where id=p_media_id;
  if p_sync_menu_image then
    v_public_url := 'https://zibubwrntdmdxyimqddo.supabase.co/functions/v1/argo-public-menu-photo?item=' || p_linked_menu_item_id::text;
    update public.argo_menu_items set image_url=v_public_url,updated_at=now() where id=p_linked_menu_item_id and active=true;
  end if;
  insert into public.argo_media_review_events(media_id,admin_email,old_category,new_category,old_status,new_status,old_linked_menu_item_id,new_linked_menu_item_id,sync_menu_image,notes)
  values(p_media_id,v_admin_email,v_old_category,btrim(p_category),v_old_status,p_status,v_old_link,case when p_status='archive' then null else p_linked_menu_item_id end,p_sync_menu_image,nullif(btrim(coalesce(p_notes,'')),''));
  return true;
end
$function$;

revoke all on function public.argo_admin_media_review(text,uuid,text,text,text,text,uuid,boolean) from public;
grant execute on function public.argo_admin_media_review(text,uuid,text,text,text,text,uuid,boolean) to anon, authenticated, service_role;

create unique index if not exists argo_media_one_verified_photo_per_menu_item
  on public.argo_media_library(linked_menu_item_id)
  where active=true and category='menu_verified' and status='menu' and linked_menu_item_id is not null;
