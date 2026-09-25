-- FRIENDSHIP EBENHAEZER V16
-- Perbaikan izin Suka dan Komentar.
-- Jalankan seluruh isi file ini di Supabase > SQL Editor > Run.

-- =========================
-- SUKA POSTINGAN
-- =========================
alter table public.likes enable row level security;

drop policy if exists likes_select on public.likes;
drop policy if exists likes_insert on public.likes;
drop policy if exists likes_delete on public.likes;
drop policy if exists likes_update on public.likes;

create policy likes_select
on public.likes
for select
to authenticated
using (true);

create policy likes_insert
on public.likes
for insert
to authenticated
with check (auth.uid() = user_id);

create policy likes_delete
on public.likes
for delete
to authenticated
using (auth.uid() = user_id);


-- =========================
-- KOMENTAR
-- =========================
alter table public.comments enable row level security;

drop policy if exists comments_select on public.comments;
drop policy if exists comments_insert on public.comments;
drop policy if exists comments_delete on public.comments;
drop policy if exists comments_update on public.comments;

create policy comments_select
on public.comments
for select
to authenticated
using (true);

create policy comments_insert
on public.comments
for insert
to authenticated
with check (auth.uid() = user_id);

create policy comments_delete
on public.comments
for delete
to authenticated
using (auth.uid() = user_id);


-- =========================
-- CEK CEPAT
-- =========================
select tablename, rowsecurity
from pg_tables
where schemaname = 'public'
and tablename in ('likes','comments');
