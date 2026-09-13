# ARGO PHOTO -> DATABASE SYNC SPEC

Use this file when synchronising the completed 2026 photo audit into Supabase. The spreadsheet audit is the visual source of truth. Supabase remains the current menu/product/name/price/availability source of truth.

## Current sync state
- argo_media_library contains all 227 reconciled originals.
- No corpus originals are currently missing from Supabase.
- The master workbook declares 227/227 classified and 0 pending verdicts.
- The old `da_classificare` state has been removed from rows whose filename-level verdict was not recoverable.
- Those rows are now `audit_reconciled`: they are known to belong to the completed 227/227 master audit, but their specific filename-level verdict was not preserved in the recoverable register.
- `audit_reconciled` means HOLD, not approved. Never auto-publish those rows until the original verdict is recovered or a fresh visual review is completed.

## Verified database state after reconciliation
- Total media rows: 227.
- `audit_reconciled` / future: 184.
- `menu_verified` / menu: 7.
- `menu_verified` / future: 1 (Soutzoukakia plate, not force-linked to a non-identical current item).
- `menu_conditional` / future: 6.
- Remaining rows are explicit social, backstage, heritage, archive, dessert/sauce conditional, menu candidate/secondary and other recovered categories.
- No `da_classificare` rows remain after the reconciliation pass.

## Price rule
Never copy prices from the photo workbook into production. The workbook contains historical price snapshots. Always use current Supabase values.

Examples already confirmed:
- Pita Gyros: live €9 vs workbook €8.
- Dolmas: live €6.50 vs workbook €5.
- Feta: live €5.50 vs older workbook €5.
- Insalata greca choriatiki: live €12 vs workbook €10.
- Saganaki: live €7 vs workbook €6.50.

## Production-ready mappings already present in Supabase
- IMG-20240216-WA0034.jpg -> Pita Gyros
- IMG-20240216-WA0014.jpg -> Gyros di Suino al Piatto
- IMG-20240216-WA0016.jpg -> Gyros di Pollo al Piatto
- IMG-20240216-WA0112.jpg -> Tzatziki
- IMG-20240216-WA0137.jpg -> Insalata greca choriatiki
- IMG-20240216-WA0154.jpg -> Feta
- IMG-20240216-WA0157.jpg -> Dolmas

These verified links must not be overwritten casually.

## Verified asset not currently linked to an exact active product
- IMG-20240216-WA0038.jpg -> Soutzoukakia plate, A2 MENU. Keep menu_verified, but do not force it onto Bifteki or another non-identical current item.

## Conditional assets: NEVER AUTO-PUBLISH
- IMG-20240216-WA0046.jpg -> vegetarian plate; verify current composition before linking to the current vegetarian plate.
- IMG-20240216-WA0036.jpg -> fried/grilled cheese; identify exact product before Saganaki/Halloumi mapping.
- IMG-20240216-WA0096.jpg -> vegetarian polpettine; identify exact variety.
- IMG-20240216-WA0130.jpg -> light dip; kitchen identification required.
- IMG-20240216-WA0135.jpg -> dark dip; kitchen identification required.
- IMG-20240216-WA0078.jpg / WA0081.jpg -> desserts; identify exact item before naming.
- IMG-20211130-WA0005.jpg -> Moussaka plate; publish only if current plating/portion still matches.
- IMG-20220628-WA0010.jpg -> old large mixed souvlaki plate; verify exact current product and portion.
- IMG-20240624-WA0001.jpg -> stuffed vegetables; verify item is currently active.
- IMG-20240808-WA0019.jpg -> Nissos beer + Greek salad; verify beer is still sold.
- IMG-20231113-WA0019.jpg -> person serving ouzo; public use requires consent.

## Backstage / heritage, not menu thumbnails
- IMG-20240216-WA0164.jpg -> Feta service plate, C / BACKSTAGE B. Not unresolved. Stories/process only, not homepage/menu/ads.
- IMG-20251222-WA0002.jpg -> Moussaka production, BACKSTAGE.
- IMG-20211130-WA0012.jpg -> heritage Greek spread.
- IMG-20220610-WA0014.jpg -> heritage old Pita Gyros series, superseded by WA0034.

## Safe sync order
1. Preserve every existing verified menu link.
2. Apply filename-level master verdicts only where explicitly recovered/verified.
3. Treat `audit_reconciled` as HOLD until an exact verdict is recovered or re-reviewed visually.
4. Promote only A2 MENU assets that also pass current product/portion checks.
5. Link approved assets to the exact active Supabase item.
6. Set image_url from the approved media asset only after exact mapping.
7. Re-read live menu and media rows after each batch.
8. Conditional assets remain unlinked until verification.

## Photo Admin reliability state
- Drive preview fallback chain is active.
- Progressive rendering now shows 36 cards initially, then loads 36 more on demand.
- Current progressive-loading commit: 09052eac4effc7476fb548d45590a4835b4e471c.
- The GitHub Pages deployment for that commit completed successfully.

## Remaining work
- Recover exact filename-level verdicts for `audit_reconciled` rows where commercially useful, or visually re-review them.
- Verify conditional product identity/portion/consent items.
- Map exact verified A2 assets to current active menu items where a true one-to-one product match exists.
- Execute new P1 shoot for missing core pitas, current Moussaka, current Souvlaki/Mix Grill, Bugiurdi, sauces and current production workflow.
