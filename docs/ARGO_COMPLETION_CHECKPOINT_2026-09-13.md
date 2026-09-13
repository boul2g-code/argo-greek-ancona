# ARGO Completion Checkpoint — 2026-09-13

This checkpoint records the actual production state after the 2026-09-13 cleanup and hardening pass. It overrides older "open work" notes where they conflict.

## Completed

- Marketing / Social Hub implemented in Admin with approval gates, scheduling, organic vs paid separation, audit trail and provider-specific autopublish gating.
- Paid campaigns cannot activate without explicit budget approval.
- Conditional, archive, reconciled and otherwise unverified photo assets are blocked from automatic marketing use.
- Photo-review RPC hardened: `menu_verified` requires menu status plus an exact active linked item; `menu_verified_unlinked` requires future status and no menu link; archive cannot retain a menu link; menu-image sync requires all publication gates.
- Desktop photo-preview architecture moved away from Google authorization popups. Admin preview now supports private ARGO/Supabase storage behind the existing Admin session.
- Private bucket `argo-admin-media` exists and is non-public. Import UI supports resumable filename-based migration of the 227 original images.
- Photo Shoot Plan is deployed and live.
- Direct-order backend was tested end-to-end inside a transaction and rolled back: plain order creation, modifier pricing, order items and totals passed without leaving test orders in production.
- Menu fallback snapshot was forcibly refreshed from live Supabase on 2026-09-13. The stale vegetarian flags are now synchronized; for example `Tirokeftedes pikantikoi` is `vegetarian=true` in the current snapshot.
- ARGO SUNMI Android debug APK build was re-run from current `main` and completed successfully. Artifact: `argo-sunmi-v2-legacy-apk`, workflow run `34765186877`, artifact id `10320545441`, SHA-256 digest `2ee72f32b78d8c1d5628d62094bcba358811756d790800995f0ac927a06ef582`.
- SUNMI web terminal actions match the production RPC actions: `accept_print`, `reprint`, `preparing`, `ready`, `completed`.
- Background push diagnostic page and Settings link were deployed. Latest verified GitHub Pages deployment for commit `45fbc6b6cb7237f8ce252dff25909ae6ce537735` completed successfully.
- Manual Supabase security review completed for ARGO tables, policies, privileges and ARGO `SECURITY DEFINER` functions.
- Legacy `argo_registro_emergenza` was confirmed empty and unused by the current ARGO repository/functions, then locked down: no RLS policies remain and `anon` / `authenticated` have no direct SELECT, INSERT, UPDATE or DELETE privileges.
- ARGO admin/private tables remain behind RLS with no direct public policies; operational access is through token-validating RPCs rather than direct table access.
- Performance hardening added missing leading indexes for ARGO foreign keys used by admin sessions, booking events, media/menu links, modifier relations, order items and order offers. This improves joins and referential actions without changing business data.
- Admin navigation currently exposes Orders, Menu, Promo, Marketing, Photos, Bookings, Statistics and Settings; Settings also exposes Photo Review, Photo Shoot Plan, Photo Import, SUNMI and push diagnostics.

## Intentionally pending because they require real external or physical input

1. Import the 227 originals from the local PC folder into `argo-admin-media`. Current migration state before user-side selection: 0 / 227 imported. This cannot be completed server-side because the local files are not available to the server.
2. Connect real Meta / Instagram / Facebook and Google Business credentials. The software queue is ready, but external authorization is deliberately not stored in public frontend code.
3. Verify the 13 conditional/candidate photos against the real current food and portions. No automatic guess or relabel is allowed.
4. Execute the physical P1 photo shoot and post-shoot handoff.
5. Install the freshly built SUNMI APK on the actual terminal and perform the physical printer test: new order alert → accept & print → preparing → ready → completed → reprint.
6. Replace the permanent File Library workbook with the validated 56-sheet build when the actual XLSX binary is available in a writable session.

## Current operational rule

All code/database work that can be completed safely from the connected tools has been completed or verified for this checkpoint. Remaining tasks need either the user's local files, real third-party account authorization, physical food/photo verification, or the physical SUNMI device. Do not simulate those steps or mark them complete without evidence.
