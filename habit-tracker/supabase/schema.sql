-- Ember habit tracker — Supabase schema (direct-client, header-scoped RLS)
-- Project: "Paul Personal Database" (ref: fuzisxdefycuwkhbuynx)
-- Convention: ember_* tables (matches this DB's per-project prefix convention).
--
-- Design: no in-app login and no server. The browser talks to Supabase directly
-- with the public *publishable* key. Every app state is one JSON blob keyed by
-- `owner` = PBKDF2(passcode). RLS restricts each request to the single row whose
-- owner equals the `x-ember-owner` request header, so a client only ever sees the
-- blob for the passcode it holds; without that hash it sees nothing and cannot
-- enumerate other rows. The publishable key is safe to ship — RLS is the guard.
--
-- To apply: Supabase Dashboard -> SQL Editor -> paste this file -> Run. (Idempotent.)

create table if not exists public.ember_state (
  owner      text primary key,                  -- PBKDF2(passcode); the tenant key
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
comment on table public.ember_state is
  'Ember habit tracker: one JSON blob per passcode (owner = PBKDF2(passcode)). '
  'Convention: ember_* for all tables in this app. Access is scoped by the '
  'x-ember-owner request header via RLS.';

-- Always stamp updated_at server-side so other devices can detect a change.
create or replace function public.ember_touch() returns trigger
  language plpgsql as $$ begin new.updated_at = now(); return new; end $$;
drop trigger if exists ember_state_touch on public.ember_state;
create trigger ember_state_touch before insert or update on public.ember_state
  for each row execute function public.ember_touch();

alter table public.ember_state enable row level security;

-- Each request may only touch the row whose owner matches the x-ember-owner header.
-- Missing/wrong header -> owner '' -> no rows.
drop policy if exists ember_state_by_header on public.ember_state;
create policy ember_state_by_header on public.ember_state
  for all to anon, authenticated
  using      (owner = coalesce(nullif(current_setting('request.headers', true), '')::json ->> 'x-ember-owner', ''))
  with check (owner = coalesce(nullif(current_setting('request.headers', true), '')::json ->> 'x-ember-owner', ''));

grant select, insert, update on public.ember_state to anon, authenticated;
