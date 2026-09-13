# ARGO PROJECT KNOWLEDGE

Canonical working knowledge for ARGO Greek Comfort Food. This file is the primary production reference and supersedes stale chat notes where they conflict.

## Business
- ARGO Greek Comfort Food, Via Marconi 27, Ancona.
- Current hours: 18:30–23:00 Monday, Tuesday, Thursday, Friday, Saturday, Sunday. Wednesday closed. No lunch for now.
- Instagram: @argoancona.
- Positioning: contemporary Mediterranean/Greek premium street food, mobile-first, authentic real-food photography.
- Commercial priority: increase attachment sales of mezedes, sauces and desserts.

## Ordering-channel policy
- ARGO Direct / website accepts **pickup only** (`asporto` / ritiro dal locale).
- ARGO Direct does **not** operate delivery, riders, delivery addresses or delivery fees.
- Home delivery is handled externally by **Deliveroo** and **Just Eat**.
- Homepage and menu ordering CTAs must first lead customers to a channel-choice section: delivery via Deliveroo/Just Eat or pickup via ARGO Direct.
- Admin operational order queues and SUNMI are only for ARGO Direct pickup orders.
- Supabase enforces pickup-only orders at database level.
- Canonical policy doc: `docs/ARGO_ORDER_CHANNEL_POLICY.md`.

## Canonical data architecture
- Supabase is the source of truth for active menu, prices, availability, offers, orders, admin state and media workflow.
- Canonical flow: Supabase -> Admin -> ARGO Direct -> homepage.
- Do not use old `menu.json` as source of truth.
- `ordina/menu-snapshot.json` is fallback only and is refreshed from Supabase.
- Photo workbook is visual/audit truth only. Never use workbook prices as production prices.

## Confirmed product distinctions
- `Pita Pollo` and `Pita chicky` are distinct products. Never merge or treat as aliases.
- `Pita Gyros` and `Pita piggy` are distinct products. Never merge or treat as aliases.
- Photo mapping must preserve those distinctions.

## Current menu/photo rule
- Product images shown to customers must come from verified ARGO media or approved public/cache assets.
- Better no image than a misleading image.
- Manual free-form `image_url` editing from the menu editor is blocked; menu-photo assignment goes through the verified photo workflow.
- Seven exact verified menu mappings currently exist: Pita Gyros, Gyros di Suino al Piatto, Gyros di Pollo al Piatto, Tzatziki, Insalata greca choriatiki, Feta, Dolmas.
- Remaining candidate/conditional photos must not be auto-published.

## Photo master
Source of truth for visual audit: `ARGO_Photo_Audit_Master_2026.xlsx`.
- Originals reconciled: 227.
- Originals classified: 227.
- Pending verdicts: 0.
- Confirmed ACTIVE: 35.
- Conditional ACTIVE: 5.
- Heritage winners: 2.
- Estimated menu coverage: 58%.
- Newest operational workbook build has 56 sheets.
- Permanent File Library copy may still be older until the actual newer XLSX is explicitly uploaded/replaced.

### Operational workbook flow
`7-Day Sprint -> Shoot Prep -> Contact Sheet Log -> Post-Shoot Handoff -> Asset Register / Launch Queue`

## Current production-method rule
- Meat is cooked in Rational, chilled safely, cut, then finished on grill/plate to order.
- Never present vertical-spit imagery as the current production method.
- Generated concepts do not prove the real appearance of menu items.

## Media infrastructure
- `argo_media_library` contains all 227 reconciled originals.
- Private bucket `argo-admin-media` exists and is non-public.
- Admin photo import supports filename-based import from the local source folder.
- Private preview functions protect Admin-only media.
- Public customer menu images use approved public/cache routes rather than raw private Google Drive access.
- Import of the full local 227-photo folder remains a user-side physical/local-file task.

## Photo review safety
- Menu publication requires `category=menu_verified`, `status=menu`, and an exact active linked menu item.
- Archive media cannot stay linked to menu items.
- `menu_verified_unlinked` remains future/unlinked until exact product identity exists.
- Review decisions are written to `argo_media_review_events`.

## Homepage / customer flow
- Homepage reads active menu and current offers from Supabase.
- `ORDINA ORA` and product-order CTAs lead to the channel-choice section rather than forcing Deliveroo or ARGO Direct.
- Delivery choices: Deliveroo / Just Eat.
- Pickup choice: ARGO Direct.
- Homepage and ARGO Direct expose live daily pickup promotions.
- Welcome and daily promotions are validated server-side.
- Current hero/food imagery should use real ARGO assets, not generic Greece stock art.
- Hours: 18:30–23:00, Wednesday closed, no lunch.
- Chatbot must not guess prices or availability.

## Promotions
- Promo creation/editing has DB and UI safeguards for discount values, thresholds, dates, use limits and duplicate codes.
- Daily pickup promotions are exposed publicly through dedicated RPCs.
- Welcome offer is exposed separately from daily offers.
- Promo validation remains server-side and redemption is audited.

## Orders / kitchen workflow
- ARGO Direct orders are pickup-only.
- Backend order state machine:
  - `new -> accepted` via `accept_print`
  - `accepted -> preparing`
  - `accepted/preparing -> ready`
  - `ready -> completed`
  - cancellation blocked after terminal states
  - reprint blocked for cancelled orders
- Invalid transitions raise an error.
- `argo_order_events` records action history with admin identity, old/new status, print count and timestamps.
- `admin/order-history.html` exposes the audit trail.
- `admin/orders.html` sorts operationally by state, shows elapsed waiting time and highlights long-waiting orders.

## SUNMI
- SUNMI web terminal actions match the hardened backend state machine.
- Native Android app includes printer bridge, keep-screen-on behavior and printer readiness exposure.
- Latest known successful Android build is the current SUNMI legacy APK workflow output.
- Software build is complete; **physical install and real printer validation are still pending**.

## Notifications / background push
- Browser-page sound and background Web Push are separate systems.
- Orders polling continues every 5 seconds while the page is open.
- Background notifications are server-triggered from new order inserts and do not require the Orders page to be open.
- Order push Edge Function requires an internal secret; unauthenticated direct calls are rejected.
- Push dispatch has duplicate protection and retry handling for transient provider failures.
- Dead subscriptions are disabled when push providers return permanent-gone responses.
- `admin/push-test.html` provides a real background push diagnostic test.
- Last verified server-side real dispatch before hardening delivered to 5 active subscriptions with 0 provider failures.
- Final visual/audio confirmation still depends on each physical device and OS notification settings.

## Bookings
- Booking transitions are protected.
- Booking status changes write to `argo_booking_events`.
- `admin/booking-history.html` exposes booking audit history.
- Admin booking UI prioritizes real booking date/time and future reservations.

## Marketing
- Marketing Hub exists with draft/approval/schedule/ready/published workflow.
- Linked product must remain active.
- Menu-verified media must match the exact selected product.
- Conditional/archive/reconciled media cannot auto-publish.
- Paid ads require an explicit positive budget.
- Meta and Google Business providers remain disconnected until real external authorization is supplied.

## Stats / Settings
- `admin/stats.html` shows pickup-focused ARGO Direct metrics; Deliveroo and Just Eat are intentionally excluded.
- `admin/settings.html` is the operational control center for Orders, SUNMI, push tests, bookings, photos, marketing, promos and stats.
- Admin logout clears the local admin session token.

## Security / database hardening
- Admin tables use RLS and token-authenticated SECURITY DEFINER RPCs where required.
- `argo_registro_emergenza` legacy anonymous access was removed; it is currently locked from anonymous/authenticated direct CRUD.
- `argo_notify_order_push()` is not executable by anon/authenticated roles.
- Critical SECURITY DEFINER functions have explicit `search_path` settings.
- Missing foreign-key support indexes were added for admin sessions, booking events, media links, modifier relations, order items and offer links.
- Exact active menu duplicates are blocked by a partial unique index on active category/name.

## GitHub / deployment
- Repo: `boul2g-code/argo-greek-ancona`.
- `main` is production.
- GitHub Pages auto-deploys production site/admin changes.
- A task is considered deployed only after a real commit and successful Pages deployment where relevant.
- Keep `.github/workflows/argo-menu-snapshot.yml` and `.github/workflows/build-sunmi-apk.yml`.
- Obsolete one-shot patch workflows were removed.

## Stable constraints
- Never reintroduce site delivery logic into ARGO Direct without an explicit business decision.
- Never treat Deliveroo/Just Eat delivery as ARGO Direct orders.
- Never merge confirmed-distinct pita products.
- Never guess unidentified photo contents.
- Never auto-publish conditional images.
- Never claim physical SUNMI, social-account authorization, photo verification or local-folder import complete without real evidence.

## Current open work
Only tasks requiring real external, local or physical input remain as material blockers:
1. Import the 227 local originals into private ARGO storage from the actual local folder.
2. Verify the 13 conditional/candidate photos against current products and portions.
3. Execute the physical P1 photo shoot and post-shoot handoff.
4. Install the current SUNMI APK on the real device and perform printer validation with a real/test operational order path.
5. Connect Meta/Instagram/Facebook and optional Google Business using real provider authorization when desired.
6. Replace the permanent File Library workbook with the validated 56-sheet XLSX when the actual file is available.

## Checkpoints
- `docs/ARGO_COMPLETION_CHECKPOINT_2026-09-13.md`
- `docs/ARGO_IMPROVEMENTS_2026-09-13.md`
- `docs/ARGO_ORDER_CHANNEL_POLICY.md`
