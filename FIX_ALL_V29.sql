-- Friendship Ebenhaezer V29
-- Fixes the notification trigger that was blocking chat/like/comment actions.
-- Run this ONE time in Supabase SQL Editor.

-- 1) Make notification fields compatible with existing notification triggers.
alter table public.notifications add column if not exists actor_id uuid;
alter table public.notifications add column if not exists message text;
alter table public.notifications add column if not exists type text;
alter table public.notifications add column if not exists related_id uuid;
alter table public.notifications add column if not exists is_read boolean default false;
alter table public.notifications add column if not exists created_at timestamptz default now();
alter table public.notifications alter column message drop not null;

-- Keep the actor reference valid when the column is used.
create index if not exists notifications_user_id_idx on public.notifications(user_id);
create index if not exists notifications_actor_id_idx on public.notifications(actor_id);
create index if not exists notifications_created_at_idx on public.notifications(created_at desc);

-- 2) Chat RLS.
alter table public.messages enable row level security;
drop policy if exists messages_select on public.messages;
drop policy if exists messages_insert on public.messages;
drop policy if exists messages_update on public.messages;
drop policy if exists messages_delete on public.messages;
create policy messages_select on public.messages for select to authenticated
using (auth.uid() = sender_id or auth.uid() = receiver_id);
create policy messages_insert on public.messages for insert to authenticated
with check (auth.uid() = sender_id);
create policy messages_update on public.messages for update to authenticated
using (auth.uid() = sender_id or auth.uid() = receiver_id)
with check (auth.uid() = sender_id or auth.uid() = receiver_id);
create policy messages_delete on public.messages for delete to authenticated
using (auth.uid() = sender_id or auth.uid() = receiver_id);

-- 3) Likes RLS.
alter table public.likes enable row level security;
drop policy if exists likes_select on public.likes;
drop policy if exists likes_insert on public.likes;
drop policy if exists likes_delete on public.likes;
create policy likes_select on public.likes for select to authenticated using (true);
create policy likes_insert on public.likes for insert to authenticated with check (auth.uid() = user_id);
create policy likes_delete on public.likes for delete to authenticated using (auth.uid() = user_id);

-- 4) Comments RLS.
alter table public.comments enable row level security;
drop policy if exists comments_select on public.comments;
drop policy if exists comments_insert on public.comments;
drop policy if exists comments_delete on public.comments;
create policy comments_select on public.comments for select to authenticated using (true);
create policy comments_insert on public.comments for insert to authenticated with check (auth.uid() = user_id);
create policy comments_delete on public.comments for delete to authenticated using (auth.uid() = user_id);

-- 5) Notifications RLS.
alter table public.notifications enable row level security;
drop policy if exists notifications_select on public.notifications;
drop policy if exists notifications_insert on public.notifications;
drop policy if exists notifications_update on public.notifications;
drop policy if exists notifications_delete on public.notifications;
create policy notifications_select on public.notifications for select to authenticated
using (auth.uid() = user_id);
create policy notifications_insert on public.notifications for insert to authenticated
with check (auth.uid() = user_id);
create policy notifications_update on public.notifications for update to authenticated
using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy notifications_delete on public.notifications for delete to authenticated
using (auth.uid() = user_id);

-- 6) Friend requests RLS.
alter table public.friend_requests enable row level security;
drop policy if exists friend_requests_select on public.friend_requests;
drop policy if exists friend_requests_insert on public.friend_requests;
drop policy if exists friend_requests_update on public.friend_requests;
drop policy if exists friend_requests_delete on public.friend_requests;
create policy friend_requests_select on public.friend_requests for select to authenticated
using (auth.uid() = requester_id or auth.uid() = recipient_id);
create policy friend_requests_insert on public.friend_requests for insert to authenticated
with check (auth.uid() = requester_id);
create policy friend_requests_update on public.friend_requests for update to authenticated
using (auth.uid() = requester_id or auth.uid() = recipient_id)
with check (auth.uid() = requester_id or auth.uid() = recipient_id);
create policy friend_requests_delete on public.friend_requests for delete to authenticated
using (auth.uid() = requester_id or auth.uid() = recipient_id);
