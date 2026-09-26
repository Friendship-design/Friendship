-- Friendship Forever V31 storage/profile fix
alter table public.profiles add column if not exists avatar_url text;
alter table public.profiles add column if not exists banner_url text;

insert into storage.buckets (id,name,public) values ('friendship-media','friendship-media',true) on conflict (id) do update set public=true;

drop policy if exists friendship_media_public_read on storage.objects;
create policy friendship_media_public_read on storage.objects for select using (bucket_id='friendship-media');

drop policy if exists friendship_media_auth_insert on storage.objects;
create policy friendship_media_auth_insert on storage.objects for insert to authenticated with check (bucket_id='friendship-media' and (storage.foldername(name))[1]=auth.uid()::text);

drop policy if exists friendship_media_owner_update on storage.objects;
create policy friendship_media_owner_update on storage.objects for update to authenticated using (bucket_id='friendship-media' and owner_id=auth.uid()) with check (bucket_id='friendship-media' and owner_id=auth.uid());

drop policy if exists friendship_media_owner_delete on storage.objects;
create policy friendship_media_owner_delete on storage.objects for delete to authenticated using (bucket_id='friendship-media' and owner_id=auth.uid());
