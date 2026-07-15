# Ember × Supabase

Optional cloud sync so your habits and streaks live on Supabase and stay in sync
across your phone, iPad, and laptop — instead of only in one device's browser.

- **Project:** Paul Personal Database (`fuzisxdefycuwkhbuynx`)
- **Tables:** `ember_habits`, `ember_entries` (prefix `ember_`, matching this DB's
  per-project convention). Row-level security is owner-only — every row is scoped
  to `auth.uid()`, so nothing else in the database can read Ember's data.
- **Auth:** magic-link email. You sign in once per device with your email; every
  device resolves to the same user, so they all see the same data.

## 1. Create the tables

Supabase Dashboard → **SQL Editor** → paste [`schema.sql`](./schema.sql) → **Run**.
(Idempotent — safe to run more than once.)

## 2. Turn on email auth

Dashboard → **Authentication → Providers → Email** → enable it (on by default).
Magic-link (OTP) is included. Once the app is deployed, set **Authentication → URL
Configuration → Site URL** (and add a redirect URL) to the app's Vercel URL so the
sign-in link returns to the app.

## 3. Client config

The app needs two public values (safe to ship in client code — RLS is what
protects the data):

- **Project URL** — `https://fuzisxdefycuwkhbuynx.supabase.co`
- **Publishable/anon key** — Dashboard → **Project Settings → API keys**

These get dropped into the app's config block when the sync layer is wired in.

## Architecture (local-first)

`localStorage` stays the fast, offline source of truth — taps are instant and the
PWA keeps working with no signal. Changes sync to Supabase in the background and
pull on open. Conflicts resolve last-write-wins per habit/day cell (fine for a
single user). The JSON export remains as a manual backup.
