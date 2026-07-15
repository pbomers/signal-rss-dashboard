-- Ember habit tracker — Supabase schema (serverless-proxy model)
-- Project: "Paul Personal Database" (ref: fuzisxdefycuwkhbuynx)
-- Convention: ember_* tables (matches this DB's per-project prefix convention).
--
-- Design: no in-app Supabase login. A Vercel serverless route (/api/sync) holds
-- the service_role key and is the ONLY thing that touches this table. The client
-- authenticates to that route with a token = sha256(passcode); that same token is
-- the tenant key (the `owner` column). So the whole app state is one JSON blob per
-- passcode. RLS is enabled with NO policies, so anon/authenticated roles get
-- nothing — only the service_role (which bypasses RLS) can read/write.
--
-- To apply: Supabase Dashboard -> SQL Editor -> paste this file -> Run. (Idempotent.)

create table if not exists public.ember_state (
  owner      text primary key,                 -- sha256(passcode); the tenant key
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
comment on table public.ember_state is
  'Ember habit tracker: one JSON blob per passcode (owner = sha256(passcode)). '
  'Convention: ember_* for all tables in this app. Accessed only via the /api/sync '
  'service_role proxy; RLS on with no policies denies all direct client access.';

alter table public.ember_state enable row level security;
-- Intentionally no policies: only the service_role key (server-side) may touch this.
