-- Day 10: handoff_logs for Human Handoff + 15-min SLA
create table if not exists public.handoff_logs (
  id uuid primary key default gen_random_uuid(),
  lead_id uuid references public.leads(id) on delete cascade,
  phone text not null,
  reason text not null, -- keyword triggered: agent, human, etc.
  language text default 'en' check (language in ('en','ar')),
  status text default 'pending' check (status in ('pending','notified','acknowledged','resolved','expired')),
  requested_at timestamptz default now(),
  notified_at timestamptz,
  acknowledged_at timestamptz,
  resolved_at timestamptz,
  sla_deadline timestamptz generated always as (requested_at + interval '15 minutes') stored,
  sla_breached boolean default false,
  assigned_to text,
  notes text,
  created_at timestamptz default now()
);

create index if not exists idx_handoff_requested on public.handoff_logs(requested_at desc);
create index if not exists idx_handoff_status on public.handoff_logs(status);
create index if not exists idx_handoff_sla on public.handoff_logs(sla_deadline) where status = 'pending';

alter table public.handoff_logs enable row level security;
create policy "Allow all for service role" on public.handoff_logs for all using (true) with check (true);
