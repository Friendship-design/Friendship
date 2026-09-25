-- FRIENDSHIP EBENHAEZER V17 - CHAT
-- Jalankan sekali di Supabase > SQL Editor.

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
with check (auth.uid() = sender_id);

create policy messages_update on public.messages
for update to authenticated
using (auth.uid() = receiver_id or auth.uid() = sender_id)
with check (auth.uid() = receiver_id or auth.uid() = sender_id);

create policy messages_delete on public.messages
for delete to authenticated
using (auth.uid() = sender_id or auth.uid() = receiver_id);
