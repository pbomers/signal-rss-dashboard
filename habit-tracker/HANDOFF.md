# Ember — Handoff & Deploy Guide

Everything needed to put **Ember** (a finished habit-tracker PWA) into a new
private GitHub repo, host it, and turn on cloud sync. Hand this whole folder/zip
to a new Claude chat that has access to the target GitHub repo — or do it yourself
from any normal machine. All steps are copy-pasteable.

---

## TL;DR for the next Claude session

The user wants this app in a **new private GitHub repo named `ember`**, then hosted
on a static host, then Supabase sync enabled. The code is **complete and verified** —
do not rebuild it. Your job is only the external actions the previous session was
blocked from doing:

1. Push `app/` (or `ember.bundle`) to a new private repo `ember`.
2. Have the user run `supabase/schema.sql` in the Supabase SQL Editor (one paste).
3. Deploy `app/` to a static host (no build, no env vars).
4. Have the user set the same passcode on each device to enable sync.

## Why this handoff exists

Ember was built in a Claude Code session **hard-bound at the proxy to a single repo
(`pbomers/signal-rss-dashboard`)**. That session physically could not create a new
GitHub repo, push to any other repo, apply the Supabase schema (DB writes refused),
or deploy to Vercel — every external write returned `403 … sessions are bound to
their configured repositories`. Nothing is wrong with the code; only these external
actions remain, and they must run from a context that can reach the target repo +
Supabase + a host.

---

## What's in this package

```
HANDOFF.md          <- this file
ember.bundle        <- the app as a git repo WITH history (push this)
app/                <- the same files, plain (deployable static site)
  index.html          the entire app: UI + logic + sync (one file, no build)
  sw.js               service worker (offline cache)
  manifest.webmanifest, icons/, robots.txt   PWA install + noindex
  README.md
  supabase/
    schema.sql        the one SQL statement to run
    README.md         sync design details
```

## Features (all built & verified in-session)

- Four habit types: **check-off** (make the bed), **count-up to a goal** (water),
  **stay-under a limit** (drinks), **track-a-number** (weight).
- **Drinks:** every `+` stamps the clock time; time chips are tap-to-edit / remove.
- **Trends tab:** 90-day **weight line graph**; drinks 28-day bars with a **7-day
  rolling-average reduction overlay** + this-week-vs-last-week tiles; 12-week
  heatmaps; streak / best / 30-day-rate tiles.
- **Streaks** with a one-day grace and a carry-over **starting-streak base**
  (e.g. 1,004 days) that's forfeited on the first missed day.
- **Duotone SVG icon set** — only the streak 🔥 is emoji.
- **Passcode lock** (PBKDF2 hash, "remember this device 30 days").
- **Optional cloud sync** (below). **JSON export/import** backup.

## Cloud-sync architecture (no server, no secret)

- Supabase is the source of truth; `localStorage` is the offline copy.
- The browser calls Supabase REST **directly** with the public **publishable** key
  (already hardcoded in `index.html` — safe; row-level security is the guard).
- **Auth = the passcode.** `owner = PBKDF2(passcode)` is sent as an `x-ember-owner`
  header; an RLS policy scopes every request to the single row with that owner. One
  passcode = one cloud blob; the same passcode on another device = the same data.
  No login screen.
- Config already baked into `index.html`:
  - Project: **Paul Personal Database** — ref `fuzisxdefycuwkhbuynx`
  - URL: `https://fuzisxdefycuwkhbuynx.supabase.co`
  - Publishable key: `sb_publishable_7J6VRBgBoNskWFoLdR6mFg_WrSuueef`
  - Table: `public.ember_state` (prefix `ember_`, matching this DB's per-app convention)

---

## Steps to finish

### 1 — New private GitHub repo
Create an empty **private** repo `ember` at <https://github.com/new> (no README).
Then push, either:

**A. From the bundle (keeps commit history):**
```bash
git clone ember.bundle ember
cd ember
git remote set-url origin https://github.com/<you>/ember.git
git push -u origin main
```

**B. From the plain folder:**
```bash
cd app
git init -b main && git add -A && git commit -m "Ember habit tracker"
git remote add origin https://github.com/<you>/ember.git
git push -u origin main
```

### 2 — Create the Supabase table
Supabase → project **Paul Personal Database** (`fuzisxdefycuwkhbuynx`) → **SQL Editor**
→ paste `supabase/schema.sql` (also inline at the bottom of this file) → **Run**.
Idempotent. No secrets involved.

### 3 — Host it (static — no build, no env vars)
Drag the **`app/`** folder onto <https://vercel.com/new> or
<https://app.netlify.com/drop>. Or connect the GitHub repo (Framework preset:
**Other**, no build command). It's pure static files.

### 4 — Turn on sync
Open the hosted URL on each device → **Habits** tab → **App lock** → set the **same
passcode** on each. Done — they sync. Add to Home Screen to install as an app.

---

## Verified vs. not

**Verified in-session:** the full app UI/logic (streaks, charts, all habit types),
and cloud sync — two devices, both directions, offline-queue-then-flush, and
per-passcode isolation — driven against an intercepted mock of Supabase REST with
correct auth headers asserted.

**Not verified (needs the live table):** the real RLS header-forwarding on Supabase.
After step 2, do one quick check: same passcode on two devices, edit on one, confirm
it appears on the other.

**Security note:** the only secret is the passcode (PBKDF2-stretched before it
becomes the row key) — use a strong one. The site is `noindex` + robots-disallowed.

---

## Original requests (context, in order)

1. A cool phone-first habit tracker: make the bed, weigh in / log weight, water,
   drinks (to reduce intake), streaks over time.
2. Day-over-day overlay on the drinks graph to track reduction.
3. Duotone icons, not real emoji (keep the fire one).
4. Timestamp each drink as it's consumed.
5. A starting-streak base (e.g. seed a 1,004-day streak).
6. Storage: keep it personal/simple — passcode + "cookie", installable PWA; then
   add Supabase cloud sync (Supabase as source of truth, localStorage as offline
   backup), no login, `ember_` table prefix.
7. A weight graph (already present in Trends).
8. Put it in a **new private GitHub repo** (this handoff).

---

## The SQL (same as `supabase/schema.sql`)

```sql
create table if not exists public.ember_state (
  owner      text primary key,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create or replace function public.ember_touch() returns trigger
  language plpgsql as $$ begin new.updated_at = now(); return new; end $$;
drop trigger if exists ember_state_touch on public.ember_state;
create trigger ember_state_touch before insert or update on public.ember_state
  for each row execute function public.ember_touch();

alter table public.ember_state enable row level security;

drop policy if exists ember_state_by_header on public.ember_state;
create policy ember_state_by_header on public.ember_state
  for all to anon, authenticated
  using      (owner = coalesce(nullif(current_setting('request.headers', true), '')::json ->> 'x-ember-owner', ''))
  with check (owner = coalesce(nullif(current_setting('request.headers', true), '')::json ->> 'x-ember-owner', ''));

grant select, insert, update on public.ember_state to anon, authenticated;
```
