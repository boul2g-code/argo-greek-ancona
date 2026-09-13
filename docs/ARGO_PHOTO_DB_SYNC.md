# ARGO PHOTO -> DATABASE SYNC SPEC

Use this file when synchronising the completed 2026 photo audit into Supabase. The spreadsheet audit is the visual source of truth. Supabase remains the menu/product source of truth.

## Important rule
Do not copy prices from the photo workbook into production. The photo workbook contains older price snapshots. Always read current price/name/active state from Supabase before publishing.

Examples of current live differences already confirmed:
- Pita Gyros is €9 in Supabase, while the workbook still shows €8.
- Dolmas is €6.50 in Supabase, while the workbook still shows €5.
- Feta is €5.50 in Supabase, while the workbook uses an older €5 label.
- Insalata greca choriatiki is €12 in Supabase, while the workbook shows €10.
- Saganaki is €7 in Supabase, while the workbook shows €6.50.

## Production-ready mappings already present in Supabase
- IMG-20240216-WA0034.jpg -> Pita Gyros
- IMG-20240216-WA0014.jpg -> Gyros di Suino al Piatto
- IMG-20240216-WA0016.jpg -> Gyros di Pollo al Piatto
- IMG-20240216-WA0112.jpg -> Tzatziki
- IMG-20240216-WA0137.jpg -> Insalata greca choriatiki
- IMG-20240216-WA0154.jpg -> Feta
- IMG-20240216-WA0157.jpg -> Dolmas

These existing links must not be overwritten casually.

## Ready assets that exist in media library but are not yet linked
- IMG-20240216-WA0038.jpg -> Soutzoukakia plate. Audit class A2 MENU. Current media row is still future/da_classificare.
- IMG-20240216-WA0046.jpg -> Vegetarian plate. Audit class A2 MENU after current composition verification. Current media row is still future/da_classificare.

Before linking either asset, resolve the exact current menu item name in Supabase. Do not infer an ID from an old workbook label.

## Conditional assets: NEVER AUTO-PUBLISH
- IMG-20240216-WA0036.jpg -> fried/grilled cheese. Identify exact product before mapping to Saganaki or Halloumi.
- IMG-20240216-WA0130.jpg -> light dip. Likely hummus/other; kitchen identification required.
- IMG-20240216-WA0135.jpg -> dark dip. Likely melitzanosalata; kitchen identification required.
- IMG-20240216-WA0078.jpg -> dessert. Exact dessert required.
- IMG-20240216-WA0081.jpg -> dessert. Exact dessert required.
- IMG-20211130-WA0005.jpg -> Moussaka plate. Publish only if current plating/portion still matches.
- IMG-20220628-WA0010.jpg -> old large mixed souvlaki plate. Verify current product and portion.
- IMG-20240624-WA0001.jpg -> stuffed vegetables. Verify item is currently active.
- IMG-20240808-WA0019.jpg -> Nissos beer + Greek salad. Verify beer is still sold.
- IMG-20231113-WA0019.jpg -> person serving ouzo. Public use requires consent.

## Backstage / heritage, not menu thumbnails
- IMG-20240216-WA0164.jpg -> Feta service plate, backstage/archive use only.
- IMG-20251222-WA0002.jpg -> Moussaka production, backstage/process use only.
- IMG-20211130-WA0012.jpg -> heritage Greek spread.
- IMG-20220610-WA0014.jpg -> heritage old Pita Gyros series, superseded by WA0034.

## Current live menu items relevant to unresolved photo mapping
Verified from Supabase at the time of this sync spec:
- Piatto Meze Vegetariano €15, no image yet.
- Moussaka €15, no image yet.
- Saganaki €7, no image yet.
- Feta in pastafillo con miele e sesamo €9, no image yet.
- Feta €5.50, image already linked.
- Dolmas €6.50, image already linked.
- Feta ed Olive €7.50, no image yet.
- Feta al Cartoccio €9, no image yet.
- Pita Feta €9, no image yet.
- Pita dolmas €9, no image yet.
- Pita Vegetariana €9, no image yet.
- Hummus €5 / grande €6 / piccola €1.50, no images yet.
- Melitzanosalata €5 / grande €6 / piccola €1.50, no images yet.

## Safe sync order
1. Preserve all existing verified links.
2. Update media classification metadata from the master audit.
3. Promote only A2 MENU assets that also pass current product/portion verification.
4. Link each approved asset to the exact current Supabase menu item.
5. Set the menu item's image_url from the media asset thumb URL.
6. Re-read the live menu and photo admin after each batch.
7. Conditional assets remain unlinked until explicitly verified.

## Database state warning
The last audit found argo_media_library still far behind the completed workbook classification. Database status fields must not be treated as the visual-audit source of truth until this sync is completed.
