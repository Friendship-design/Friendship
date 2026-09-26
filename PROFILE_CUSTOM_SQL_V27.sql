-- FRIENDSHIP EBENHAEZER V26 - FOTO PROFIL & BANNER
-- Jalankan sekali di Supabase SQL Editor.

alter table public.profiles add column if not exists avatar_url text;
alter table public.profiles add column if not exists banner_url text;

alter table public.profiles enable row level security;

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self
on public.profiles for update to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

-- Pastikan penyimpanan media dan izinnya aktif.
insert into storage.buckets (id,name,public)
values ('friendship-media','friendship-media',true)
on conflict (id) do update set public=true;

drop policy if exists friendship_media_insert on storage.objects;
create policy friendship_media_insert
on storage.objects for insert to authenticated
with check (
  bucket_id='friendship-media'
  and (storage.foldername(name))[1]=auth.uid()::text
);

drop policy if exists friendship_media_select on storage.objects;
create policy friendship_media_select
on storage.objects for select to public
using (bucket_id='friendship-media');

drop policy if exists friendship_media_update on storage.objects;
create policy friendship_media_update
on storage.objects for update to authenticated
using (bucket_id='friendship-media' and (storage.foldername(name))[1]=auth.uid()::text)
with check (bucket_id='friendship-media' and (storage.foldername(name))[1]=auth.uid()::text);
