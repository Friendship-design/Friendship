-- Friendship Ebenhaezer V27 - jalankan SEKALI di Supabase SQL Editor
-- Memastikan fitur posting, reels, like, komentar, teman, chat, profil dan notifikasi dapat dipakai.

-- PROFILES
alter table public.profiles enable row level security;
drop policy if exists profiles_select on public.profiles;
drop policy if exists profiles_update_self on public.profiles;
create policy profiles_select on public.profiles for select to authenticated using (true);
create policy profiles_update_self on public.profiles for update to authenticated using (auth.uid()=id) with check (auth.uid()=id);
alter table public.profiles add column if not exists avatar_url text;
alter table public.profiles add column if not exists banner_url text;

-- POSTS
alter table public.posts enable row level security;
drop policy if exists posts_select on public.posts;
drop policy if exists posts_insert on public.posts;
drop policy if exists posts_update on public.posts;
drop policy if exists posts_delete on public.posts;
create policy posts_select on public.posts for select to authenticated using (true);
create policy posts_insert on public.posts for insert to authenticated with check (auth.uid()=user_id);
create policy posts_update on public.posts for update to authenticated using (auth.uid()=user_id) with check (auth.uid()=user_id);
create policy posts_delete on public.posts for delete to authenticated using (auth.uid()=user_id);

-- LIKES
alter table public.likes enable row level security;
drop policy if exists likes_select on public.likes;
drop policy if exists likes_insert on public.likes;
drop policy if exists likes_delete on public.likes;
create policy likes_select on public.likes for select to authenticated using (true);
create policy likes_insert on public.likes for insert to authenticated with check (auth.uid()=user_id);
create policy likes_delete on public.likes for delete to authenticated using (auth.uid()=user_id);

-- COMMENTS
alter table public.comments enable row level security;
drop policy if exists comments_select on public.comments;
drop policy if exists comments_insert on public.comments;
drop policy if exists comments_delete on public.comments;
create policy comments_select on public.comments for select to authenticated using (true);
create policy comments_insert on public.comments for insert to authenticated with check (auth.uid()=user_id);
create policy comments_delete on public.comments for delete to authenticated using (auth.uid()=user_id);

-- MESSAGES
create table if not exists public.messages(id uuid primary key default gen_random_uuid(),sender_id uuid not null references auth.users(id) on delete cascade,receiver_id uuid not null references auth.users(id) on delete cascade,content text not null,created_at timestamptz not null default now());
alter table public.messages enable row level security;
drop policy if exists messages_select on public.messages;
drop policy if exists messages_insert on public.messages;
drop policy if exists messages_update on public.messages;
drop policy if exists messages_delete on public.messages;
create policy messages_select on public.messages for select to authenticated using (auth.uid()=sender_id or auth.uid()=receiver_id);
create policy messages_insert on public.messages for insert to authenticated with check (auth.uid()=sender_id and auth.uid()<>receiver_id);
create policy messages_update on public.messages for update to authenticated using (auth.uid()=sender_id or auth.uid()=receiver_id) with check (auth.uid()=sender_id or auth.uid()=receiver_id);
create policy messages_delete on public.messages for delete to authenticated using (auth.uid()=sender_id or auth.uid()=receiver_id);

-- FRIEND REQUESTS
create table if not exists public.friend_requests(id uuid primary key default gen_random_uuid(),requester_id uuid not null references auth.users(id) on delete cascade,recipient_id uuid not null references auth.users(id) on delete cascade,status text not null default 'pending',created_at timestamptz not null default now(),updated_at timestamptz not null default now());
alter table public.friend_requests enable row level security;
drop policy if exists friend_requests_select on public.friend_requests;
drop policy if exists friend_requests_insert on public.friend_requests;
drop policy if exists friend_requests_update on public.friend_requests;
drop policy if exists friend_requests_delete on public.friend_requests;
create policy friend_requests_select on public.friend_requests for select to authenticated using (auth.uid()=requester_id or auth.uid()=recipient_id);
create policy friend_requests_insert on public.friend_requests for insert to authenticated with check (auth.uid()=requester_id and requester_id<>recipient_id);
create policy friend_requests_update on public.friend_requests for update to authenticated using (auth.uid()=requester_id or auth.uid()=recipient_id) with check (auth.uid()=requester_id or auth.uid()=recipient_id);
create policy friend_requests_delete on public.friend_requests for delete to authenticated using (auth.uid()=requester_id or auth.uid()=recipient_id);

-- MEDIA
insert into storage.buckets(id,name,public) values('friendship-media','friendship-media',true) on conflict(id) do update set public=true;
drop policy if exists friendship_media_insert on storage.objects;
drop policy if exists friendship_media_select on storage.objects;
drop policy if exists friendship_media_update on storage.objects;
drop policy if exists friendship_media_delete on storage.objects;
create policy friendship_media_insert on storage.objects for insert to authenticated with check(bucket_id='friendship-media' and (storage.foldername(name))[1]=auth.uid()::text);
create policy friendship_media_select on storage.objects for select to public using(bucket_id='friendship-media');
create policy friendship_media_update on storage.objects for update to authenticated using(bucket_id='friendship-media' and (storage.foldername(name))[1]=auth.uid()::text) with check(bucket_id='friendship-media' and (storage.foldername(name))[1]=auth.uid()::text);
create policy friendship_media_delete on storage.objects for delete to authenticated using(bucket_id='friendship-media' and (storage.foldername(name))[1]=auth.uid()::text);

-- NOTIFICATIONS
create table if not exists public.notifications(id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,actor_id uuid references auth.users(id) on delete set null,type text not null,content text not null,related_id text,is_read boolean not null default false,created_at timestamptz not null default now());
alter table public.notifications enable row level security;
drop policy if exists notifications_select on public.notifications;
drop policy if exists notifications_update on public.notifications;
drop policy if exists notifications_delete on public.notifications;
create policy notifications_select on public.notifications for select to authenticated using(auth.uid()=user_id);
create policy notifications_update on public.notifications for update to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
create policy notifications_delete on public.notifications for delete to authenticated using(auth.uid()=user_id);

-- POSTS MEDIA COLUMNS
alter table public.posts add column if not exists media_url text;
alter table public.posts add column if not exists media_type text;
