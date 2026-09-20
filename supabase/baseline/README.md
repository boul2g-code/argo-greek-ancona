# ARGO Supabase baseline

This directory keeps reviewable snapshots of the live ARGO database API surface.

- `argo_functions_2026-09-20.sql` contains only `public.argo_*` functions captured from production.
- KIROX and other non-ARGO functions are intentionally excluded.
- The snapshot lives outside `supabase/migrations/` so it cannot accidentally replay the entire current API over a fresh or newer database.
- Real changes continue to use focused migrations under `supabase/migrations/`.
- Refresh the snapshot after meaningful RPC changes to make production drift visible in Git.
