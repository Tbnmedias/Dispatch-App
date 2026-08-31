# Sand Dispatch — starter

Vite + React frontend, Supabase for auth/database/storage/realtime,
deployed to Netlify manually via CLI (not Git-linked, so it never eats
into Netlify's build-minute quota — you build locally and upload the
already-built `dist` folder).

## 1. Supabase setup

1. In your Supabase project dashboard, open the SQL editor and run
   `supabase/schema.sql` — creates `trucks`, `drivers`, `customers`,
   `orders`, `loads` with RLS enabled.
2. **Note on RLS while testing:** the starter policies require
   `auth.role() = 'authenticated'`. Since this starter doesn't wire up
   login yet, you have two options until you add auth:
   - Temporarily add a permissive policy for the `anon` role for local
     testing, or
   - Add Supabase Auth (email/password or magic link) before going further.
   Don't leave a fully open anon policy in place once this holds real
   customer/payment data.
3. Grab your Project URL and anon public key from Project Settings → API.

## 2. Local environment

```bash
cp .env.example .env
# then fill in VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY
npm install
npm run dev
```

## 3. One-time Netlify link

```bash
npm install -g netlify-cli   # if you don't already have it
netlify login
netlify init
```

When `netlify init` asks:
- **"Create & configure a new site"** (pick the right team/account)
- Build command: leave blank or `npm run build` — doesn't matter, we won't
  use Netlify's own build step
- Publish directory: `dist`

Then set your Supabase keys as Netlify site env vars (so they're available
if you ever do let Netlify build, and for consistency):

```bash
netlify env:set VITE_SUPABASE_URL "https://your-project-ref.supabase.co"
netlify env:set VITE_SUPABASE_ANON_KEY "your-anon-public-key"
```

## 4. Deploy (every time, CLI-only — no build minutes used)

```bash
npm run build          # builds locally into dist/
netlify deploy --prod --dir=dist
```

Drop `--prod` to push a draft preview URL first if you want to check it
before it goes live.

## What's included

- `src/App.jsx` — live fleet status board, subscribed to Supabase Realtime
  changes on the `trucks` table
- `src/lib/supabaseClient.js` — Supabase client, reads keys from env
- `supabase/schema.sql` — Phase 1 tables (trucks, drivers, customers,
  orders, loads) per the system blueprint

## Not built yet (next steps)

- Auth (dispatcher vs driver login)
- Order entry form → `orders` table
- Driver screen (big-button flow: Start Trip → Loaded → Delivered, etc.)
- Digital delivery ticket + photo/signature upload to Supabase Storage
- Daily management dashboard (totals, sales, outstanding balances)
