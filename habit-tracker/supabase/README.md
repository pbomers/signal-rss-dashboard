# Ember × Supabase (cloud sync)

Supabase is the source of truth; `localStorage` is the offline copy. There is **no
in-app login** — the passcode you already set doubles as the sync credential:
`sha256(passcode)` is sent to a serverless proxy that holds the service_role key and
is the only thing that touches the database. The same hash is the row key, so one
passcode = one cloud blob. Use the same passcode on another device to see the same
data.

- **Project:** Paul Personal Database (`fuzisxdefycuwkhbuynx`)
- **Table:** `ember_state` (prefix `ember_`, matching this DB's convention) — one
  JSON blob per passcode. RLS is **on with no policies**, so anon/authenticated
  roles get nothing; only the service_role (server-side) can read/write.
- **Proxy:** `../api/sync.js` (Vercel serverless function).

## Setup

1. **Create the table** — Supabase → SQL Editor → paste [`schema.sql`](./schema.sql)
   → Run. (Idempotent.)
2. **Deploy the app to Vercel** (static site + the `/api` function) and set two env
   vars in the Vercel project:
   - `SUPABASE_URL` = `https://fuzisxdefycuwkhbuynx.supabase.co`
   - `SUPABASE_SERVICE_ROLE` = the project's **service_role** secret key
     (Supabase → Project Settings → API keys → service_role). This is a secret —
     it lives only in Vercel env, never in the repo or the browser bundle.
3. On each device, open the app and set the **same passcode** (Habits → App lock).
   That turns on sync.

## How sync behaves

- Every edit writes `localStorage` instantly (offline-safe), then pushes to the
  cloud after a short debounce. On open / regaining focus / coming back online, the
  app pulls.
- Whole-state last-write-wins by an opaque server revision; a `dirty` flag means
  local edits that haven't been pushed yet always win over the cloud, so nothing is
  lost offline. Fine for a single user; simultaneous edits on two devices resolve to
  whichever pushed last.
- No passcode set → sync is off, app is local-only. JSON export/import still works
  as a manual backup either way.

## Verified

Two-device sync (A↔B, both directions) and offline-edit-then-reconnect were driven
end-to-end against a local mock of this proxy. The live round-trip through the
deployed Vercel function against real Supabase is **not** verified here — it needs
the deploy + service_role env var; do a quick "set passcode on two devices, edit on
one, see it on the other" check once it's live.
