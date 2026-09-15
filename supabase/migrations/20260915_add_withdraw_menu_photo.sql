create or replace function public.argo_admin_withdraw_menu_photo(p_token text, p_item_id uuid)
returns boolean
language plpgsql
security definer
set search_path to 'public', 'extensions'
as $function$
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
$function$;

revoke all on function public.argo_admin_withdraw_menu_photo(text,uuid) from public;
revoke all on function public.argo_admin_withdraw_menu_photo(text,uuid) from anon, authenticated;
grant execute on function public.argo_admin_withdraw_menu_photo(text,uuid) to service_role;
