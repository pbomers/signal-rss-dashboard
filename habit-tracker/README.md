# Ember 🔥 — habit tracker

A tiny, phone-first habit tracker. No build step, no server, no account — one
HTML file plus a service worker. All data lives in `localStorage` on the device.

## Habit types

| Type | Success means | Example |
|---|---|---|
| **Check off** | did it at least once today | make the bed |
| **Build up** | reached the daily goal | water — 8 glasses |
| **Stay under** | stayed at/under the daily cap (an unlogged day counts as 0) | drinks — ≤ 2 |
| **Track #** | logged a number today | weight |

Streaks get a one-day grace: today doesn't break the streak until it's over.
Past days can be backfilled with the ‹ › arrows on the Today screen.

A habit can carry a **starting streak** (set it when adding/editing) for runs
you built up before tracking here — e.g. 1,004 days. It counts on top of the
tracked streak and is forfeited the first time you miss a day.

## Features

- "Stay under" entries are time-stamped: each **+** records the clock time; tap
  a time chip to adjust or remove that entry (backfilled days show `time?`)
- Two-tone SVG icon set (accent + 35% tint) — no emoji except the streak 🔥
- Current/best streaks, 30-day completion rate, 12-week heatmap per habit
- 90-day trend line for measured habits (weight), 14-day bars vs. goal/limit
- Add/edit/pause habits, JSON export/import backup
- Installable PWA: offline-capable, add-to-home-screen, dark & light themes
- Optional passcode lock (Habits → App lock): salted PBKDF2 hash, no plaintext
  stored, with a "remember this device for 30 days" flag — a privacy gate for
  hosting the app at a public URL, not real security (the data is on-device)

## Run it

Serve the folder over HTTP(S) — e.g. `python3 -m http.server` — or host it on
any static host (GitHub Pages, Vercel, Netlify). Open it on your phone and use
**Add to Home Screen** to install.
