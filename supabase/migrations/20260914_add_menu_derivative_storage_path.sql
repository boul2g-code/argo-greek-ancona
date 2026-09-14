alter table public.argo_media_library
  add column if not exists menu_derivative_storage_path text;

comment on column public.argo_media_library.menu_derivative_storage_path is
  'Private 1200x800 JPEG derivative path; never the raw upload path.';
