-- FRIENDSHIP EBENHAEZER V26 - CHAT FIX
-- Jalankan sekali di Supabase SQL Editor.

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references auth.users(id) on delete cascade,
  receiver_id uuid not null references auth.users(id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now()
);

alter table public.messages add column if not exists sender_id uuid;
alter table public.messages add column if not exists receiver_id uuid;
alter table public.messages add column if not exists content text;
alter table public.messages add column if not exists created_at timestamptz not null default now();

alter table public.messages enable row level security;

drop policy if exists messages_select on public.messages;
drop policy if exists messages_insert on public.messages;
drop policy if exists messages_update on public.messages;
drop policy if exists messages_delete on public.messages;

create policy messages_select on public.messages
for select to authenticated
using (auth.uid() = sender_id or auth.uid() = receiver_id);

create policy messages_insert on public.messages
for insert to authenticated
with check (auth.uid() = sender_id and auth.uid() <> receiver_id);

create policy messages_update on public.messages
for update to authenticated
using (auth.uid() = sender_id or auth.uid() = receiver_id)
with check (auth.uid() = sender_id or auth.uid() = receiver_id);

create policy messages_delete on public.messages
for delete to authenticated
using (auth.uid() = sender_id or auth.uid() = receiver_id);

create index if not exists messages_sender_receiver_idx on public.messages(sender_id,receiver_id,created_at);
create index if not exists messages_receiver_sender_idx on public.messages(receiver_id,sender_id,created_at);
