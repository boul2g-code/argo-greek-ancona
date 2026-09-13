# ARGO PROJECT KNOWLEDGE

Canonical working knowledge for ARGO Greek Comfort Food. This file supersedes stale chat summaries. Update it whenever a production fact or decision materially changes.

## Business
- ARGO Greek Comfort Food, Ancona, Via Marconi 27.
- Greek comfort/street food, takeaway + delivery + limited seating.
- Current hours: 18:30–23:00 Monday, Tuesday, Thursday, Friday, Saturday, Sunday. Wednesday closed. No lunch for now.
- Instagram: @argoancona.
- Positioning: contemporary Mediterranean/Greek premium street-food, mobile-first, authentic real-food photography. Avoid generic stock-Greece imagery.
- Commercial priority: increase attachment sales of mezedes, sauces and desserts.

## Canonical data architecture
- Supabase is the source of truth for the active menu, product names, prices and availability.
- Canonical flow: Supabase -> Admin -> ARGO Direct -> homepage.
- Do not use old menu.json as source of truth.
- Do not hardcode old prices or availability in chatbot/homepage.
- ARGO Direct is the direct ordering channel. Pienissimo is retained only for bookings where applicable.
- Photo workbook is visual/audit truth only. Never copy workbook price snapshots into production.

## Repository / production
- Repo: boul2g-code/argo-greek-ancona.
- main is the production branch.
- Admin pages include admin/orders.html and admin/photos.html; service worker is admin/sw.js.
- A task is deployed only after a real remote commit and, where relevant, a successful GitHub Pages deployment.

## GitHub Actions hygiene
- Obsolete one-shot patch workflows have been removed from main to stop stale patch jobs/failures from firing during normal pushes.
- Removed: apply-ordina-fallback.yml, finalize-homepage.yml, fix-order-now-links.yml, fix-ordina-menu.yml, optimize-argo-direct.yml, patch-ordina-fallback.yml.
- Keep: argo-menu-snapshot.yml, because it refreshes the static ARGO Direct fallback snapshot on schedule.
- Keep: build-sunmi-apk.yml, because it is the legitimate SUNMI Android build workflow.
- Latest cleanup commit removing the final obsolete patch workflow: f0b70b9e1730f9b54c2f8c3fb5022a0aece1dc2d.

## Homepage decisions already established
- Homepage reads the active menu from Supabase, not old menu.json.
- Hero/social image uses real ARGO photo WA0114.
- Hours are 18:30–23:00, closed Wednesday, no lunch opening.
- Lunch booking options removed.
- Old Pienissimo ordering references changed to ARGO Direct; Pienissimo only for bookings where relevant.
- Old Spanakopita/Tiropita and outdated hours references cleaned.
- Chatbot must not guess prices or availability and should defer to the live menu.
- Instagram corrected to @argoancona; copyright 2026.

## Admin notification fix
- Commit: 7a01a869d0b1eb75544be5379a4b48a807bb8335.
- Sound and system notifications are independent.
- unlockSound() must not request notification permission.
- Denied notification permission must not show a blocking alert.
- Notification states: NOTIFICHE BLOCCATE / ATTIVA NOTIFICHE / NOTIFICHE ATTIVE.
- requestPermission() only after user action and only while permission is default.
- Orders, polling, actions and sound continue if browser notifications are denied.
- Polling remains every 5 seconds.
- admin/sw.js was not changed for this fix.

## Photo master
Source of truth for visual audit: ARGO_Photo_Audit_Master_2026.xlsx.

### Master status
- Originals reconciled: 227.
- Originals classified: 227.
- Pending verdicts: 0.
- Confirmed ACTIVE: 35.
- Conditional ACTIVE: 5.
- Heritage winners: 2.
- Estimated menu coverage: 58%.
- Corrected arithmetic: 128 + 49 + 35 + 13 + 2 = 227.

### Current production-method rule
- Meat is cooked in Rational, chilled safely, cut, then finished on grill/plate to order.
- Do not present vertical-spit imagery as the current production method.
- Generated concepts never prove the appearance of a real menu item.
- A menu photo must match current product, portion, garnish and composition.
- Keep original filenames; selected derivatives must retain source mapping.

### Verified primary assets
- IMG-20240216-WA0114.jpg -> A1 HERO, Greek sharing table. Homepage / Google cover / pinned social. Not a single-product menu thumbnail.
- IMG-20240216-WA0034.jpg -> A2 MENU, Pita Gyros. Primary pita winner.
- IMG-20240216-WA0014.jpg -> A2 MENU, Gyros plate. Primary plate winner.
- IMG-20240216-WA0016.jpg -> A2 MENU, Chicken plate. Primary chicken winner.
- IMG-20240216-WA0038.jpg -> A2 MENU, Soutzoukakia plate. Never relabel as Bifteki unless identical product is explicitly verified.
- IMG-20240216-WA0046.jpg -> A2 MENU, Vegetarian plate. Publish only after current-composition verification.
- IMG-20240216-WA0112.jpg -> A2 MENU, Tzatziki.
- IMG-20240216-WA0137.jpg -> A2 MENU, Greek salad.
- IMG-20240216-WA0154.jpg -> A2 MENU, Feta ladorigani.
- IMG-20240216-WA0157.jpg -> A2 MENU, Dolmas. Current rule: verify 4 pieces + tzatziki.

### Conditional / restricted assets
- WA0036 -> fried/grilled cheese; identify exact product before Saganaki/Halloumi use.
- WA0096 -> vegetarian polpettine; identify exact variety.
- WA0078 / WA0081 -> desserts; identify exact dessert before naming.
- WA0130 -> light dip; likely hummus/other, identify before publication.
- WA0135 -> dark dip; likely melitzanosalata, confirm.
- WA0164 -> Feta service plate, C / BACKSTAGE B. Process/story only, not homepage/menu/paid ads.
- 20251222-WA0002 -> Moussaka production, BACKSTAGE.
- 20240203-WA0005 -> meat/lamb skewers, A3 / MENU ALT. Social/authentic proof; do not promise an exact plate if composition differs.
- 20211130-WA0005 -> Moussaka plate, CONDITIONAL A2. Use only if current plating still matches.
- 20211130-WA0012 -> HERITAGE A, old Greek spread.
- 20220610-WA0014 -> HERITAGE A3, old Pita Gyros series superseded by WA0034.
- 20220628-WA0010 -> large mixed souvlaki plate, CONDITIONAL A2/A3; verify current product/portion.
- 20240624-WA0001 -> stuffed vegetables, CONDITIONAL; use only if item remains active.
- 20240808-WA0019 -> Nissos beer + Greek salad, CONDITIONAL; verify beer availability.
- 20231113-WA0019 -> person serving ouzo, CONDITIONAL; public use requires consent.

## Current Supabase media-library state
- argo_media_library contains all 227 originals. Corpus reconciliation is complete.
- No original is missing from the media library.
- 7 production menu mappings are linked and verified.
- There are zero rows remaining with category da_classificare.
- 184 rows are now category audit_reconciled: the original exists and belongs to the completed master audit, but the recoverable filename-level register does not expose the precise verdict for that individual file. These are HOLD / no auto-publish, not "unreviewed".
- The remainder is explicitly classified as menu_verified, menu_conditional, candidate, social, backstage, heritage, archive, sauces, desserts, etc.
- Database category/status fields are workflow metadata; the workbook remains visual-audit truth where it has an explicit filename-level verdict.

### Verified menu links already in Supabase
- WA0034 -> Pita Gyros.
- WA0014 -> Gyros di Suino al Piatto.
- WA0016 -> Gyros di Pollo al Piatto.
- WA0112 -> Tzatziki.
- WA0137 -> Insalata greca choriatiki.
- WA0154 -> Feta.
- WA0157 -> Dolmas.

### Important currently-unlinked media rows
- WA0038 -> menu_verified / future; safe asset for Soutzoukakia plate, but there is no exact active current menu item link to force blindly.
- WA0046 -> menu_conditional / future; vegetarian plate, requires current-composition verification.
- WA0036, WA0096, WA0078, WA0081, WA0130, WA0135 and other conditional rows remain NO AUTO-PUBLISH until identity/current-state checks pass.

## Photo Admin / desktop loading
- admin/photos.html authenticates through argo_admin_valid and loads media through argo_admin_media.
- Google Drive previews are inherently less reliable across browsers than locally hosted/Supabase Storage images, so the admin uses fallbacks.
- Preview chain: stored thumb_url -> lh3.googleusercontent.com/d/<ID>=w1200 -> drive.google.com/uc?export=view&id=<ID> -> visible unavailable-preview warning.
- referrerpolicy=no-referrer is used on photo previews.
- Initial rendering is progressive: 36 photos at a time, then Carica altre foto loads 36 more. This reduces desktop browser/Drive request pressure.
- Photo Admin has search and a Da verificare queue for conditional/candidate/unlinked verified assets.
- Photo-admin audit filters include menu, hero, verified, conditional, social, backstage, heritage, archive, reconciled, mezedes, sauces, salads and desserts.
- Progressive-loading commit: 09052eac4effc7476fb548d45590a4835b4e471c.
- Verification-queue/search commit: 119f647a77f2f4ac14b749d550d107291e3ab527.

## Publishing / selection rules
- Exact-map only verified A2 MENU assets to current menu items.
- Conditional assets never auto-publish.
- HERO, SOCIAL, BACKSTAGE and ARCHIVE remain separate from menu-card imagery.
- Verify current item, portion, ingredients, garnish and rights/consent before public use.
- Better no image than a misleading product image.

## Current high-priority photo gaps
- Pita Pollo.
- Pita Agnello.
- Pita Bifteki / Soutzoukaki identity gap.
- Pita Salsiccia / Loukaniko.
- Product-specific Pita Vegetariana.
- Current Souvlaki plate.
- Current Mix Grill.
- Current Moussaka plate + cut-open detail.
- Bugiurdi.
- Sauce family identification / shoot.
- Current Rational-to-grill process series.

## Stable constraints
- Never reintroduce old menu.json as canonical.
- Never guess unidentified photo contents from filename alone.
- Prefer authentic ARGO food photos over stock/AI.
- Avoid unrelated auth/service-worker/order-flow changes while working on photo mapping.
- Verify against real GitHub main and real Supabase state.
- Workbook = visual truth; Supabase = current menu/product/price truth.

## Current open work
- Recover or recreate filename-level verdicts for audit_reconciled rows only when needed for commercial use.
- Verify conditional assets and promote/archive each appropriately.
- Complete exact product-photo mapping where current product identity exists.
- Execute the P1 photo shoot to improve menu coverage beyond the current 58% estimate.
- Final end-to-end order-flow test.
- SUNMI integration/testing after order flow is stable.
