-- FRIENDSHIP EBENHAEZER V18 - MEDIA + SOCIAL
-- Jalankan seluruh isi file ini SATU KALI di Supabase > SQL Editor > Run.
-- Ini membuat penyimpanan foto/video dan izinnya.

-- 1. Buat bucket media publik jika belum ada
insert into storage.buckets (id, name, public)
values ('friendship-media', 'friendship-media', true)
on conflict (id) do update set public = true;

-- 2. Hapus policy lama dengan nama yang sama agar aman dijalankan ulang
drop policy if exists friendship_media_insert on storage.objects;
drop policy if exists friendship_media_select on storage.objects;
drop policy if exists friendship_media_update on storage.objects;
drop policy if exists friendship_media_delete on storage.objects;

-- 3. Pengguna login boleh upload ke folder miliknya
create policy friendship_media_insert
on storage.objects
for insert to authenticated
with check (
  bucket_id = 'friendship-media'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- 4. Semua pengguna boleh melihat media publik
create policy friendship_media_select
on storage.objects
for select to public
using (bucket_id = 'friendship-media');

-- 5. Pemilik boleh mengganti file miliknya
create policy friendship_media_update
on storage.objects
for update to authenticated
using (
  bucket_id = 'friendship-media'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'friendship-media'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- 6. Pemilik boleh menghapus file miliknya
create policy friendship_media_delete
on storage.objects
for delete to authenticated
using (
  bucket_id = 'friendship-media'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- 7. Pastikan posting boleh dibuat pengguna login
alter table public.posts enable row level security;
drop policy if exists posts_insert on public.posts;
create policy posts_insert
on public.posts for insert to authenticated
with check (auth.uid() = user_id);

-- 8. Pastikan posting dapat dibaca pengguna login
drop policy if exists posts_select on public.posts;
create policy posts_select
on public.posts for select to authenticated
using (true);

-- 9. Suka
alter table public.likes enable row level security;
drop policy if exists likes_select on public.likes;
drop policy if exists likes_insert on public.likes;
drop policy if exists likes_delete on public.likes;
create policy likes_select on public.likes for select to authenticated using (true);
create policy likes_insert on public.likes for insert to authenticated with check (auth.uid() = user_id);
create policy likes_delete on public.likes for delete to authenticated using (auth.uid() = user_id);

-- 10. Komentar
alter table public.comments enable row level security;
drop policy if exists comments_select on public.comments;
drop policy if exists comments_insert on public.comments;
drop policy if exists comments_delete on public.comments;
create policy comments_select on public.comments for select to authenticated using (true);
create policy comments_insert on public.comments for insert to authenticated with check (auth.uid() = user_id);
create policy comments_delete on public.comments for delete to authenticated using (auth.uid() = user_id);
