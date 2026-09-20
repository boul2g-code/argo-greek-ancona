# ARGO implementation roadmap

Updated: 2026-09-20

## Access and security
- [x] Keep `boul2g@gmail.com` as intentional full administrator.
- [x] Keep `argocucinagreca@gmail.com` as intentional owner administrator.
- [x] Document custom ARGO admin sessions vs native Supabase Auth full/break-glass access.
- [x] Preserve everyday UI mutations through guarded ARGO RPCs.
- [x] Keep critical database invariants in constraints where practical.

## Orders
- [x] Enforce ARGO Direct collection hours in Europe/Rome.
- [x] Keep 30-minute frontend lead time and 15-minute pickup slots.
- [x] Add customer order tracking RPC.
- [x] Add multilingual `ordine-stato.html`.
- [x] Link tracking from checkout without exposing phone number in the URL.
- [x] Add safe public PWA shell/service worker.
- [ ] Test ARGO Android/SUNMI APK on the real SUNMI V2.
- [ ] Verify new-order notification, print, reprint and status transitions on device.
- [ ] Verify background/reconnect behavior with Deliveroo running.

## Menu and allergens
- [x] Add allergen fields with explicit reviewed/unreviewed state.
- [x] Restrict stored allergen codes to the 14 EU allergen categories.
- [x] Add protected admin allergen RPC.
- [x] Add `admin/allergens.html`.
- [x] Link allergen admin from Menu and Settings.
- [x] Show only reviewed allergen declarations on public menu and ARGO Direct.
- [ ] Manually review active menu items and populate allergens from verified kitchen/ingredient information.
- [ ] Add cross-contamination notes where appropriate.

## Photos
- [x] Keep human approval and crop/derivative gate before public menu publication.
- [x] Keep private originals/previews and one verified menu photo per product.
- [ ] Upload/review Halloumi photo.
- [ ] Upload/review Tirokeftedes photo.
- [ ] Upload/review Pita Pollo winner and backups.
- [ ] Leave Pita Gyros Maxi inactive until owner decision.
- [ ] Continue remaining no-photo/candidate worklist.

## Marketing
- [x] Show real backend connection state for Meta, TikTok and Google Business.
- [x] Hide/disable unavailable autopublish actions.
- [ ] Complete Meta Developer app credentials.
- [ ] Build Meta OAuth callback + encrypted token storage + real COLLEGA flow.
- [ ] Complete Google Business OAuth.
- [ ] Complete TikTok Content Posting API authorization.
- [ ] Connect real publishing worker only after provider OAuth is live.

## Database/version control
- [x] Track focused Supabase migrations in `supabase/migrations/`.
- [x] Keep live ARGO-only function snapshot under `supabase/baseline/`, outside executable migrations.
- [x] Exclude KIROX/non-ARGO functions from ARGO baseline.
- [x] Refresh baseline after allergen RPC (51 functions as of 2026-09-20).

## Later commercial improvements
- [ ] Customer confirmation channel (email/SMS/WhatsApp, provider to be selected).
- [ ] Loyalty/customer account design.
- [ ] Reviews/reputation integration.
- [ ] Measure direct-order conversion and repeat-order rate after tracking/allergen rollout.
