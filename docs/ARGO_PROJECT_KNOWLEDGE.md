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
- Admin photo pages: admin/photos.html, admin/photo-review.html, admin/photo-review-history.html.
- Service worker: admin/sw.js.
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
- IMG-20240216-WA0038.jpg -> A2 MENU, Soutzoukakia plate. Current DB state: menu_verified_unlinked because no exact active menu item exists. Never relabel as Bifteki unless identical product is explicitly verified.
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
- 20240624-WA0001 -> ARCHIVE. Stuffed vegetables have no matching active menu item as of 2026-09-13.
- 20240808-WA0019 -> SOCIAL ARCHIVE. Nissos beer is not in the current active beer menu as of 2026-09-13.
- 20231113-WA0019 -> person serving ouzo, CONDITIONAL; public use requires consent.

## Current Supabase media-library state
- argo_media_library contains all 227 originals. Corpus reconciliation is complete.
- No original is missing from the media library.
- Current counts: 227 total, 184 audit_reconciled, 13 verification-queue assets, 1 menu_verified_unlinked, 7 linked menu images, 4 archived.
- There are zero rows remaining with category da_classificare.
- audit_reconciled means the original belongs to the completed master audit but the recoverable filename-level register does not expose the precise verdict for that file. HOLD / no auto-publish.
- Database category/status fields are workflow metadata; the workbook remains visual-audit truth where it has an explicit filename-level verdict.

### Verified menu links already in Supabase
- WA0034 -> Pita Gyros.
- WA0014 -> Gyros di Suino al Piatto.
- WA0016 -> Gyros di Pollo al Piatto.
- WA0112 -> Tzatziki.
- WA0137 -> Insalata greca choriatiki.
- WA0154 -> Feta.
- WA0157 -> Dolmas.

## Photo Admin / desktop loading
- admin/photos.html authenticates through argo_admin_valid and loads media through argo_admin_media.
- Google Drive preview chain: stored thumb_url -> lh3.googleusercontent.com/d/<ID>=w1200 -> drive.google.com/uc?export=view&id=<ID> -> visible unavailable-preview warning.
- referrerpolicy=no-referrer is used on photo previews.
- Initial rendering is progressive: 36 photos at a time, then Carica altre foto loads 36 more.
- Photo Admin has search, a 13-item Da verificare queue, a separate Verified senza match state, and links into the dedicated review flow.
- Verification page: admin/photo-review.html.
- Audit-history page: admin/photo-review-history.html, including per-asset filtering through ?media=<uuid>.
- Progressive-loading commit: 09052eac4effc7476fb548d45590a4835b4e471c.
- Verification-queue/search commit: 119f647a77f2f4ac14b749d550d107291e3ab527.
- Review-page commit: 17ead362878390680f691f25e735652e2b4dc1d2.
- Library/review linking commit: 6b2f56f5c020d1672079698c8b43602b1c74a025.
- History-page commit: 46890d0a88626ce2a5a1a5ef2ef9e2b20289323e.
- Per-asset history filtering commit: a6a1bb1c203c72a13da8b8ef4bfccb051f6544b0. GitHub Pages deployment completed successfully.

## Photo review safety / audit trail
- argo_admin_media_review is the only admin RPC intended for review decisions.
- Menu publication requires category=menu_verified, status=menu and an exact active linked menu item.
- Archived media cannot remain linked to a menu item.
- Menu image sync is blocked unless all publication gates pass.
- Review actions are written to argo_media_review_events with admin email, before/after category, status, menu link, sync flag, notes and timestamp.
- argo_media_review_events has RLS enabled.
- Review history is exposed only through the authenticated SECURITY DEFINER RPC argo_admin_media_review_history.
- The audit table had 0 events immediately after setup, confirming that implementation/testing did not fabricate review decisions.

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
- Use the 13-item review queue to promote/archive assets only after real product verification.
- Recover audit_reconciled assets only when needed for a concrete commercial gap.
- Complete exact product-photo mapping where current product identity exists.
- Execute the P1 photo shoot to improve menu coverage beyond the current 58% estimate.
- Final end-to-end order-flow test.
- SUNMI integration/testing after order flow is stable.
