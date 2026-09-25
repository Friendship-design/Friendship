-- FRIENDSHIP EBENHAEZER - TAMBAH TEMAN
-- Jalankan sekali di Supabase > SQL Editor.

create table if not exists public.friend_requests (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references auth.users(id) on delete cascade,
  recipient_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','declined')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(requester_id, recipient_id),
  check (requester_id <> recipient_id)
);

alter table public.friend_requests enable row level security;

drop policy if exists friend_requests_select on public.friend_requests;
drop policy if exists friend_requests_insert on public.friend_requests;
drop policy if exists friend_requests_update on public.friend_requests;
drop policy if exists friend_requests_delete on public.friend_requests;

create policy friend_requests_select
on public.friend_requests for select to authenticated
using (auth.uid() = requester_id or auth.uid() = recipient_id);

create policy friend_requests_insert
on public.friend_requests for insert to authenticated
with check (auth.uid() = requester_id and requester_id <> recipient_id);

create policy friend_requests_update
on public.friend_requests for update to authenticated
using (auth.uid() = requester_id or auth.uid() = recipient_id)
with check (auth.uid() = requester_id or auth.uid() = recipient_id);

create policy friend_requests_delete
on public.friend_requests for delete to authenticated
using (auth.uid() = requester_id or auth.uid() = recipient_id);

create index if not exists friend_requests_requester_idx on public.friend_requests(requester_id);
create index if not exists friend_requests_recipient_idx on public.friend_requests(recipient_id);
