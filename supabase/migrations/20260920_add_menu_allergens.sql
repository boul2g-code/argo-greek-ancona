-- ARGO menu allergens
-- Adds explicit reviewable allergen metadata without guessing from product names.

alter table public.argo_menu_items
  add column if not exists allergens text[],
  add column if not exists allergens_note text,
  add column if not exists allergens_reviewed_at timestamptz;

alter table public.argo_menu_items
  drop constraint if exists argo_menu_items_allergens_allowed_check;

alter table public.argo_menu_items
  add constraint argo_menu_items_allergens_allowed_check
  check (
    allergens is null
    or allergens <@ array[
      'gluten','crustaceans','eggs','fish','peanuts','soy',
      'milk','nuts','celery','mustard','sesame','sulphites',
      'lupin','molluscs'
    ]::text[]
  );

create or replace function public.argo_admin_update_item_allergens(
  p_token text,
  p_id uuid,
  p_allergens text[],
  p_note text default null,
  p_mark_reviewed boolean default true
)
returns boolean
language plpgsql
security definer
set search_path to public, extensions
as $$
declare
  v_allowed constant text[] := array[
    'gluten','crustaceans','eggs','fish','peanuts','soy',
    'milk','nuts','celery','mustard','sesame','sulphites',
    'lupin','molluscs'
  ];
  v_clean text[];
begin
  if not public.argo_admin_valid(p_token) then
    raise exception 'Unauthorized';
  end if;

  if p_allergens is not null then
    select coalesce(array_agg(distinct x order by x),'{}'::text[])
      into v_clean
      from unnest(p_allergens) x
      where x is not null and btrim(x) <> '';

    if not (v_clean <@ v_allowed) then
      raise exception 'invalid_allergen_code';
    end if;
  else
    v_clean := null;
  end if;

  update public.argo_menu_items
     set allergens = v_clean,
         allergens_note = nullif(btrim(coalesce(p_note,'')),''),
         allergens_reviewed_at = case
           when coalesce(p_mark_reviewed,false) then now()
           else null
         end,
         updated_at = now()
   where id = p_id;

  return found;
end;
$$;

revoke all on function public.argo_admin_update_item_allergens(text,uuid,text[],text,boolean) from public;
grant execute on function public.argo_admin_update_item_allergens(text,uuid,text[],text,boolean) to anon, authenticated;
