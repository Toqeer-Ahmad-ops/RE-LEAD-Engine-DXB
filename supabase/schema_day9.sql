-- S1: Outbox pattern for HubSpot (so S2 can retry 429/401 without losing lead)
create table if not exists hubspot_outbox (
  id uuid primary key default gen_random_uuid(),
  correlation_id text unique not null,
  phone text not null,
  payload jsonb not null, -- mapper output
  status text not null default 'pending', -- pending | processing | done | failed
  attempts int default 0,
  last_error text,
  hubspot_contact_id text,
  hubspot_deal_id text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- S1: Human takeover pause flag (S5 prep)
create table if not exists bot_pause_flags (
  phone text primary key,
  paused_until timestamptz not null,
  reason text default 'TAKEOVER',
  created_at timestamptz default now()
);

-- S1: Add columns to existing leads table for S2/S3
alter table leads add column if not exists hubspot_contact_id text;
alter table leads add column if not exists hubspot_deal_id text;
alter table leads add column if not exists agent_assigned text; -- agent_ar / agent_palm / round-robin
alter table leads add column if not exists routing_reason text;
alter table leads add column if not exists idempotency_key text unique;

-- Index for S1 idempotency
create index if not exists idx_leads_idempotency on leads(idempotency_key);
create index if not exists idx_outbox_status on hubspot_outbox(status, created_at);
-- Enable RLS for new tables (service_role still works, anon blocked)
alter table hubspot_outbox enable row level security;
alter table bot_pause_flags enable row level security;

-- Allow service_role full access (n8n uses service_role key)
create policy "service_role all" on hubspot_outbox for all using (true) with check (true);
create policy "service_role all" on bot_pause_flags for all using (true) with check (true);
