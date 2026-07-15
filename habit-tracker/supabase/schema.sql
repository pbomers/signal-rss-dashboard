-- Ember habit tracker — Supabase schema
-- Project: "Paul Personal Database" (ref: fuzisxdefycuwkhbuynx)
-- Convention: ember_* tables (matches this DB's per-project prefix convention).
-- Safe to re-run: guarded with IF NOT EXISTS / DROP POLICY IF EXISTS.
--
-- To apply: Supabase Dashboard -> SQL Editor -> paste this file -> Run.

-- ---------- tables ----------
create table if not exists public.ember_habits (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name        text not null,
  icon        text not null default 'spark',
  type        text not null check (type in ('check','count','limit','measure')),
  goal        numeric not null default 1,
  unit        text not null default '',
  base        integer not null default 0,
  hue         integer not null default 0,
  sort        integer not null default 0,
  archived    boolean not null default false,
  deleted     boolean not null default false,           -- soft delete so removals sync across devices
  created_day date not null default (now() at time zone 'utc')::date,
  updated_at  timestamptz not null default now()
);
comment on table public.ember_habits is
  'Ember habit tracker: habit definitions. Convention: ember_* for all tables in this app. RLS: owner-only.';

create table if not exists public.ember_entries (
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  habit_id   uuid not null references public.ember_habits(id) on delete cascade,
  day        date not null,
  value      jsonb not null,                            -- a number, or an array of clock times (limit habits)
  updated_at timestamptz not null default now(),
  primary key (habit_id, day)
);
comment on table public.ember_entries is
  'Ember habit tracker: one row per habit per day. RLS: owner-only.';

create index if not exists ember_habits_user_idx     on public.ember_habits (user_id);
create index if not exists ember_entries_user_day_idx on public.ember_entries (user_id, day);

-- ---------- row level security (owner-only) ----------
alter table public.ember_habits  enable row level security;
alter table public.ember_entries enable row level security;

drop policy if exists "ember_habits owner all"  on public.ember_habits;
drop policy if exists "ember_entries owner all" on public.ember_entries;

create policy "ember_habits owner all" on public.ember_habits
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "ember_entries owner all" on public.ember_entries
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
