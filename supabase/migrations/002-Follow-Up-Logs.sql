-- Day 10: follow_up_logs for 3x24h Follow-up Engine
create table if not exists public.follow_up_logs (
  id uuid primary key default gen_random_uuid(),
  lead_id uuid references public.leads(id) on delete cascade,
  phone text not null,
  attempt_number int not null check (attempt_number between 1 and 3),
  scheduled_at timestamptz not null,
  sent_at timestamptz,
  status text default 'pending' check (status in ('pending','sent','failed','replied','cancelled')),
  template_lang text default 'en' check (template_lang in ('en','ar')),
  message_content text,
  whatsapp_message_id text,
  created_at timestamptz default now()
);

create index if not exists idx_follow_up_scheduled on public.follow_up_logs(scheduled_at);
create index if not exists idx_follow_up_lead on public.follow_up_logs(lead_id);
create index if not exists idx_follow_up_status on public.follow_up_logs(status);

alter table public.follow_up_logs enable row level security;
create policy "Allow all for service role" on public.follow_up_logs for all using (true) with check (true);
