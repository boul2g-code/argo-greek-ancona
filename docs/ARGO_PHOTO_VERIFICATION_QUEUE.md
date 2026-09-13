# ARGO PHOTO VERIFICATION QUEUE

Current action queue for photo assets that still require a real-world identity, portion, consent or process check before public use.

Last reviewed: 2026-09-13.

## Queue rules
- Supabase is the current menu/product/price truth.
- The photo master is the visual/audit truth.
- Never map an asset to a product from appearance alone.
- Conditional and candidate assets stay unlinked until their gate is explicitly passed.
- Better no image than a misleading menu image.

## Current actionable queue: 13

1. IMG-20211130-WA0005.jpg — Moussaka plate
   - Gate: compare current Moussaka plating and portion with the 2021 image.
   - If matched: promote to A2 MENU and link to current Moussaka.
   - If not matched: archive as historic plating and shoot a current plate.

2. IMG-20220628-WA0010.jpg — large mixed Souvlaki / mixed plate
   - Gate: verify exact current product and current portion.
   - Do not map to either current Souvlaki plate unless composition is truly identical.

3. IMG-20231113-WA0019.jpg — person serving ouzo
   - Gate: consent/right-to-use check.
   - Social/brand use only. Not a menu-product proof asset.

4. IMG-20240216-WA0006.jpg — fried cheese candidate
   - Gate: identify exact product.
   - Do not choose Saganaki vs Halloumi from appearance alone.

5. IMG-20240216-WA0012.jpg — strong horizontal meat-plate candidate
   - Gate: identify exact current meat product and portion.
   - Keep unlinked until product identity is explicit.

6. IMG-20240216-WA0036.jpg — fried/grilled cheese
   - Gate: identify exact product.
   - Do not interchange Saganaki / Halloumi labels.

7. IMG-20240216-WA0046.jpg — vegetarian plate
   - Gate: verify that today's Piatto Meze Vegetariano composition matches the asset.
   - If matched: promote/link to the current vegetarian plate.

8. IMG-20240216-WA0078.jpg — dessert
   - Gate: identify exact dessert name.
   - Candidate current menu family: Baklava / Kataifi / Sokolatopita / yogurt desserts, but no assignment without confirmation.

9. IMG-20240216-WA0081.jpg — dessert
   - Gate: identify exact dessert name.
   - Same restriction as WA0078.

10. IMG-20240216-WA0096.jpg — vegetarian polpettine
    - Gate: identify exact variety.
    - Current candidates include Polpettine di Ceci / Melanzane / melanzane e formaggio, but never infer solely from the photo.

11. IMG-20240216-WA0130.jpg — light dip
    - Gate: kitchen identification.
    - Do not map automatically to Hummus or another sauce.

12. IMG-20240216-WA0135.jpg — dark dip
    - Gate: confirm whether it is Melitzanosalata.
    - Keep unlinked until confirmed.

13. IMG-20240216-WA0163.jpg — backstage process
    - Gate: confirm the depicted process still matches the current Rational -> safe chilling -> cutting -> grill/plate finish workflow.
    - If not current, archive rather than use as authenticity proof.

## Verified but intentionally not actionable

IMG-20240216-WA0038.jpg — Soutzoukakia plate
- Master verdict: A2 MENU verified.
- Current Supabase menu has no exact Soutzoukakia plate item.
- DB category: menu_verified_unlinked.
- Keep for future exact match / social proof. Do not relabel as Bifteki.

## Already removed from queue on current-menu evidence

- IMG-20240624-WA0001.jpg — stuffed vegetables -> ARCHIVE. No matching active current menu item.
- IMG-20240808-WA0019.jpg — Nissos beer + Greek salad -> SOCIAL_ARCHIVE. Nissos is not in the current active beer menu.

## Current queue state
- Total media originals: 227
- Actionable verification queue: 13
- Verified unlinked exact-product asset: 1
- Verified and linked menu assets: 7
- da_classificare: 0
