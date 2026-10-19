-- Day 10: idempotency_keys to prevent duplicate WhatsApp replies
create table if not exists public.idempotency_keys (
  id uuid primary key default gen_random_uuid(),
  key text unique not null, -- hash of phone + message + workflow
  phone text not null,
  workflow_name text not null,
  created_at timestamptz default now(),
  expires_at timestamptz default (now() + interval '24 hours')
);

create index if not exists idx_idempotency_key on public.idempotency_keys(key);
create index if not exists idx_idempotency_expires on public.idempotency_keys(expires_at);
create index if not exists idx_idempotency_phone on public.idempotency_keys(phone);

-- Auto-cleanup expired keys
create or replace function public.cleanup_idempotency_keys()
returns void as $$
begin
  delete from public.idempotency_keys where expires_at < now();
end;
$$ language plpgsql;

alter table public.idempotency_keys enable row level security;
create policy "Allow all for service role" on public.idempotency_keys for all using (true) with check (true);
