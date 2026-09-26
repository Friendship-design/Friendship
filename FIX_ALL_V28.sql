-- Friendship Ebenhaezer V28 - perbaikan database utama
-- Jalankan SATU KALI di Supabase SQL Editor.

-- PROFILES
alter table public.profiles enable row level security;
alter table public.profiles add column if not exists avatar_url text;
alter table public.profiles add column if not exists banner_url text;
drop policy if exists profiles_select on public.profiles;
drop policy if exists profiles_update_self on public.profiles;
create policy profiles_select on public.profiles for select to authenticated using (true);
create policy profiles_update_self on public.profiles for update to authenticated using (auth.uid()=id) with check (auth.uid()=id);

-- POSTS
alter table public.posts enable row level security;
alter table public.posts add column if not exists media_url text;
alter table public.posts add column if not exists media_type text;
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
create table if not exists public.messages(
 id uuid primary key default gen_random_uuid(),
 sender_id uuid not null references auth.users(id) on delete cascade,
 receiver_id uuid not null references auth.users(id) on delete cascade,
 content text not null,
 created_at timestamptz not null default now()
);
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
create table if not exists public.friend_requests(
 id uuid primary key default gen_random_uuid(),
 requester_id uuid not null references auth.users(id) on delete cascade,
 recipient_id uuid not null references auth.users(id) on delete cascade,
 status text not null default 'pending',
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(requester_id,recipient_id)
);
alter table public.friend_requests enable row level security;
drop policy if exists friend_requests_select on public.friend_requests;
drop policy if exists friend_requests_insert on public.friend_requests;
drop policy if exists friend_requests_update on public.friend_requests;
drop policy if exists friend_requests_delete on public.friend_requests;
create policy friend_requests_select on public.friend_requests for select to authenticated using (auth.uid()=requester_id or auth.uid()=recipient_id);
create policy friend_requests_insert on public.friend_requests for insert to authenticated with check (auth.uid()=requester_id and requester_id<>recipient_id);
create policy friend_requests_update on public.friend_requests for update to authenticated using (auth.uid()=requester_id or auth.uid()=recipient_id) with check (auth.uid()=requester_id or auth.uid()=recipient_id);
create policy friend_requests_delete on public.friend_requests for delete to authenticated using (auth.uid()=requester_id or auth.uid()=recipient_id);

-- NOTIFICATIONS: INI BAGIAN PENTING UNTUK MEMPERBAIKI ERROR actor_id
create table if not exists public.notifications(
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 actor_id uuid references auth.users(id) on delete set null,
 type text not null,
 content text not null,
 related_id text,
 is_read boolean not null default false,
 created_at timestamptz not null default now()
);
-- Jika tabel notifications SUDAH ada tetapi actor_id belum ada, tambahkan kolomnya.
alter table public.notifications add column if not exists actor_id uuid references auth.users(id) on delete set null;
alter table public.notifications add column if not exists related_id text;
alter table public.notifications add column if not exists is_read boolean not null default false;
alter table public.notifications add column if not exists type text;
alter table public.notifications add column if not exists content text;
alter table public.notifications add column if not exists created_at timestamptz not null default now();
alter table public.notifications enable row level security;
drop policy if exists notifications_select on public.notifications;
drop policy if exists notifications_update on public.notifications;
drop policy if exists notifications_delete on public.notifications;
create policy notifications_select on public.notifications for select to authenticated using(auth.uid()=user_id);
create policy notifications_update on public.notifications for update to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
create policy notifications_delete on public.notifications for delete to authenticated using(auth.uid()=user_id);
create index if not exists notifications_user_created_idx on public.notifications(user_id,created_at desc);
create index if not exists notifications_unread_idx on public.notifications(user_id,is_read);

-- STORAGE UNTUK FOTO PROFIL, BANNER, FOTO POSTINGAN DAN REELS
insert into storage.buckets(id,name,public) values('friendship-media','friendship-media',true) on conflict(id) do update set public=true;
drop policy if exists friendship_media_insert on storage.objects;
drop policy if exists friendship_media_select on storage.objects;
drop policy if exists friendship_media_update on storage.objects;
drop policy if exists friendship_media_delete on storage.objects;
create policy friendship_media_insert on storage.objects for insert to authenticated with check(bucket_id='friendship-media' and (storage.foldername(name))[1]=auth.uid()::text);
create policy friendship_media_select on storage.objects for select to public using(bucket_id='friendship-media');
create policy friendship_media_update on storage.objects for update to authenticated using(bucket_id='friendship-media' and (storage.foldername(name))[1]=auth.uid()::text) with check(bucket_id='friendship-media' and (storage.foldername(name))[1]=auth.uid()::text);
create policy friendship_media_delete on storage.objects for delete to authenticated using(bucket_id='friendship-media' and (storage.foldername(name))[1]=auth.uid()::text);

-- TRIGGER NOTIFIKASI
create or replace function public.create_notification(p_user uuid,p_actor uuid,p_type text,p_content text,p_related text default null)
returns void language plpgsql security definer set search_path=public as $$
begin
 if p_user is not null and (p_actor is null or p_user<>p_actor) then
   insert into public.notifications(user_id,actor_id,type,content,related_id) values(p_user,p_actor,p_type,p_content,p_related);
 end if;
end; $$;

create or replace function public.notify_friend_request() returns trigger language plpgsql security definer set search_path=public as $$
begin if new.status='pending' then perform public.create_notification(new.recipient_id,new.requester_id,'friend_request','mengirim permintaan teman.',new.id::text); end if; return new; end; $$;
drop trigger if exists trg_notify_friend_request on public.friend_requests;
create trigger trg_notify_friend_request after insert on public.friend_requests for each row execute function public.notify_friend_request();

create or replace function public.notify_friend_accept() returns trigger language plpgsql security definer set search_path=public as $$
begin if new.status='accepted' and old.status is distinct from new.status then perform public.create_notification(new.requester_id,new.recipient_id,'friend_accepted','menerima permintaan teman Anda.',new.id::text); end if; return new; end; $$;
drop trigger if exists trg_notify_friend_accept on public.friend_requests;
create trigger trg_notify_friend_accept after update on public.friend_requests for each row execute function public.notify_friend_accept();

create or replace function public.notify_message() returns trigger language plpgsql security definer set search_path=public as $$
begin perform public.create_notification(new.receiver_id,new.sender_id,'message','mengirim pesan baru.',new.id::text); return new; end; $$;
drop trigger if exists trg_notify_message on public.messages;
create trigger trg_notify_message after insert on public.messages for each row execute function public.notify_message();

create or replace function public.notify_like() returns trigger language plpgsql security definer set search_path=public as $$
declare owner_id uuid; begin select user_id into owner_id from public.posts where id=new.post_id; perform public.create_notification(owner_id,new.user_id,'like','menyukai postingan Anda.',new.post_id::text); return new; end; $$;
drop trigger if exists trg_notify_like on public.likes;
create trigger trg_notify_like after insert on public.likes for each row execute function public.notify_like();

create or replace function public.notify_comment() returns trigger language plpgsql security definer set search_path=public as $$
declare owner_id uuid; begin select user_id into owner_id from public.posts where id=new.post_id; perform public.create_notification(owner_id,new.user_id,'comment','mengomentari postingan Anda.',new.post_id::text); return new; end; $$;
drop trigger if exists trg_notify_comment on public.comments;
create trigger trg_notify_comment after insert on public.comments for each row execute function public.notify_comment();
