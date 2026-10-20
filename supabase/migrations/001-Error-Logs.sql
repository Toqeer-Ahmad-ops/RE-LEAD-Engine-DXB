-- Day 10: error_logs table for Central Error Handler
create table if not exists public.error_logs (
  id uuid primary key default gen_random_uuid(),
  workflow_name text not null,
  node_name text,
  error_message text not null,
  error_stack text,
  payload jsonb,
  level text default 'error' check (level in ('info','warn','error','critical')),
  resolved boolean default false,
  created_at timestamptz default now(),
  resolved_at timestamptz
);

create index if not exists idx_error_logs_created_at on public.error_logs(created_at desc);
create index if not exists idx_error_logs_workflow on public.error_logs(workflow_name);
create index if not exists idx_error_logs_resolved on public.error_logs(resolved);

alter table public.error_logs enable row level security;
create policy "Allow all for service role" on public.error_logs for all using (true) with check (true);
