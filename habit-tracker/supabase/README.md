# Ember × Supabase (cloud sync)

Supabase is the source of truth; `localStorage` is the offline copy. **No login and
no server:** the browser talks to Supabase directly with the public *publishable*
key, and a row-level-security policy scopes every request to the single row whose
`owner` matches an `x-ember-owner` header. That header is `PBKDF2(passcode)`, so one
passcode = one cloud blob, and the same passcode on another device sees the same
data. Without the passcode you can't derive the owner or enumerate other rows; the
publishable key is safe to ship because RLS is the guard.

- **Project:** Paul Personal Database (`fuzisxdefycuwkhbuynx`)
- **Table:** `ember_state` (prefix `ember_`) — one JSON blob per passcode.
- **Config baked into the app** (both public): project URL + publishable key.

## Setup — two steps

1. **Create the table:** Supabase → SQL Editor → paste [`schema.sql`](./schema.sql)
   → Run. (Idempotent. This is the one step that must be done in Supabase — DDL
   can't be applied from the app.)
2. **Host the static files** over HTTPS (Vercel, GitHub Pages, anything). There is
   **no build, no serverless function, and no env var** — it's just the files in
   `habit-tracker/`. Then on each device open the app and set the **same passcode**
   (Habits → App lock) to turn sync on.

## How sync behaves

- Every edit writes `localStorage` instantly (offline-safe), then pushes after a
  short debounce. On open / focus / regaining network, it pulls.
- Whole-state last-write-wins by an opaque server revision; a `dirty` flag means
  unpushed local edits always win over the cloud, so nothing is lost offline. Fine
  for a single user; simultaneous edits on two devices resolve to whoever pushed
  last. JSON export/import remains a manual backup.
- No passcode set → sync is off, app is local-only.

## Security note

The only secret is your passcode, stretched with PBKDF2 (200k iterations) before it
becomes the row key — so a weak passcode is the weak link. Use a strong one. The URL
is `noindex` + `robots.txt`-disallowed.

## Verified / not

Two-device sync (both directions), offline-then-reconnect, and per-passcode
isolation were driven end-to-end with the real client against an intercepted mock of
Supabase REST (correct auth headers + upsert body confirmed). **Not** verified here:
the live RLS header-forwarding on real Supabase — it needs the table to exist. Do a
quick "set the same passcode on two devices, edit on one, see it on the other" check
after step 1.
