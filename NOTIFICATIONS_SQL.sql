-- NOTIFIKASI FRIENDSHIP EBENHAEZER
-- Jalankan sekali di Supabase SQL Editor.
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  actor_id uuid references auth.users(id) on delete set null,
  type text not null,
  content text not null,
  related_id text,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.notifications enable row level security;
drop policy if exists notifications_select on public.notifications;
drop policy if exists notifications_update on public.notifications;
drop policy if exists notifications_delete on public.notifications;
create policy notifications_select on public.notifications for select to authenticated using (auth.uid()=user_id);
create policy notifications_update on public.notifications for update to authenticated using (auth.uid()=user_id) with check (auth.uid()=user_id);
create policy notifications_delete on public.notifications for delete to authenticated using (auth.uid()=user_id);
create index if not exists notifications_user_created_idx on public.notifications(user_id, created_at desc);
create index if not exists notifications_unread_idx on public.notifications(user_id, is_read);

-- Fungsi pembuat notifikasi internal; dipanggil oleh trigger.
create or replace function public.create_notification(p_user uuid, p_actor uuid, p_type text, p_content text, p_related text default null)
returns void language plpgsql security definer set search_path=public as $$
begin
  if p_user is not null and (p_actor is null or p_user <> p_actor) then
    insert into public.notifications(user_id,actor_id,type,content,related_id)
    values(p_user,p_actor,p_type,p_content,p_related);
  end if;
end; $$;

create or replace function public.notify_friend_request()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  if new.status='pending' then
    perform public.create_notification(new.recipient_id,new.requester_id,'friend_request','mengirim permintaan teman.',new.id::text);
  end if;
  return new;
end; $$;
drop trigger if exists trg_notify_friend_request on public.friend_requests;
create trigger trg_notify_friend_request after insert on public.friend_requests for each row execute function public.notify_friend_request();

create or replace function public.notify_friend_accept()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  if new.status='accepted' and old.status is distinct from new.status then
    perform public.create_notification(new.requester_id,new.recipient_id,'friend_accepted','menerima permintaan teman Anda.',new.id::text);
  end if;
  return new;
end; $$;
drop trigger if exists trg_notify_friend_accept on public.friend_requests;
create trigger trg_notify_friend_accept after update on public.friend_requests for each row execute function public.notify_friend_accept();

create or replace function public.notify_message()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  perform public.create_notification(new.receiver_id,new.sender_id,'message','mengirim pesan baru.',new.id::text);
  return new;
end; $$;
drop trigger if exists trg_notify_message on public.messages;
create trigger trg_notify_message after insert on public.messages for each row execute function public.notify_message();

create or replace function public.notify_like()
returns trigger language plpgsql security definer set search_path=public as $$
declare owner_id uuid;
begin
  select user_id into owner_id from public.posts where id=new.post_id;
  perform public.create_notification(owner_id,new.user_id,'like','menyukai postingan Anda.',new.post_id::text);
  return new;
end; $$;
drop trigger if exists trg_notify_like on public.likes;
create trigger trg_notify_like after insert on public.likes for each row execute function public.notify_like();

create or replace function public.notify_comment()
returns trigger language plpgsql security definer set search_path=public as $$
declare owner_id uuid;
begin
  select user_id into owner_id from public.posts where id=new.post_id;
  perform public.create_notification(owner_id,new.user_id,'comment','mengomentari postingan Anda.',new.post_id::text);
  return new;
end; $$;
drop trigger if exists trg_notify_comment on public.comments;
create trigger trg_notify_comment after insert on public.comments for each row execute function public.notify_comment();
