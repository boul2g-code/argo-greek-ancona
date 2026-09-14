# ARGO PROJECT KNOWLEDGE

Canonical working knowledge for ARGO Greek Comfort Food. This file is the primary production reference and supersedes stale chat notes where they conflict.

## CONTINUATION INSTRUCTION FOR FUTURE CHATS
When continuing ARGO work in a new ChatGPT conversation, read this file first before making production changes. Treat Supabase as live truth for menu/prices/state and this file as the durable project context. Do not restart completed work or repeat photo QA already recorded here. When a new production milestone is completed, update this file.

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
- Nine exact verified menu mappings remain in the media/database workflow: Pita Gyros, Gyros di Suino al Piatto, Gyros di Pollo al Piatto, Tzatziki, Insalata greca choriatiki, Feta, Dolmas, Saganaki and Patatine fritte.
- Customer-facing rendering is enabled only for the six approved centered derivatives on homepage and ARGO Direct.
- Six verified originals are suitable for strict, non-generative centered derivatives: Pita Gyros, Gyros di Suino al Piatto, Insalata greca choriatiki, Feta, Dolmas and Saganaki.
- Three verified originals require a new photo instead of forced cropping: Gyros di Pollo al Piatto, Tzatziki and Patatine fritte.
- Moussaka is no longer verified: its former source was identified as stock imagery, archived, unlinked, removed from the public cache and cleared from the active menu row.
- Remaining candidate/conditional photos must not be auto-published.

## Photo QA checkpoint — 2026-09-14
This section records the visual QA done in chat so future sessions do not repeat it.

### Verified image disposition
- Crop-ready originals (strict crop/resize only; never alter the food): `IMG-20240216-WA0157.jpg` -> Dolmas; `IMG-20240216-WA0154.jpg` -> Feta; `IMG-20240216-WA0014.jpg` -> Gyros di Suino al Piatto; `IMG-20240216-WA0137.jpg` -> Insalata greca choriatiki; `IMG-20240216-WA0034.jpg` -> Pita Gyros; `IMG-20240216-WA0006.jpg` -> Saganaki.
- Reshoot required: `IMG-20240216-WA0016.jpg` -> Gyros di Pollo al Piatto (low perspective); `IMG-20240216-WA0051.jpg` -> Patatine fritte (excess background/cut plate); `IMG-20240216-WA0112.jpg` -> Tzatziki (too low/flat).
- Blocked/archived: `IMG-20211130-WA0005.jpg` -> former Moussaka mapping; identified as stock imagery and removed from every customer-facing mapping.

### Strong candidates / conditional mappings
- `WA0021`, `WA0022`, `WA0023`, `WA0039`, `WA0040`, `WA0061`, `WA0062`, `WA0064` -> Bifteki alla griglia candidate set. Strong visual match; verify current recipe/portion before `menu_verified`.
- `WA0045`, `WA0047`, `WA0052`, `WA0054`, `WA0055`, `WA0056`, `WA0057` -> Piatto Meze Vegetariano candidate set. Strong visual match; verify current composition/quantity.
- `WA0130` -> Hummus candidate; strong visual match, kitchen confirmation required.
- `WA0135` -> Melitzanosalata candidate; strong visual match, kitchen confirmation required.
- `WA0153` -> Tirokafteri candidate; strong visual match, kitchen confirmation required.
- `WA0065` -> Salsa curry grande candidate; strong visual match, kitchen confirmation required.
- `WA0010` from 2022 -> Piatto Souvlaki Kotopoulo candidate, but image shows 3 skewers; verify current portion before approval.
- `WA0035` and old `WA0004` -> ambiguous Pita Gyros vs Pita piggy. Never link without confirmation.
- old `WA0003` -> ambiguous Pita Pollo vs Pita chicky. Never link without confirmation.
- `WA0049`, `WA0050`, `WA0078`, `WA0081` -> dessert family candidates, likely Portokalopita/Kataifi range, but no exact mapping without kitchen confirmation.
- `WA0096`, `WA0066` -> fried polpettine family, but filling cannot be distinguished from photo; do not map to Ceci/Melanzane/Melanzane e formaggio without confirmation.

### Conditional recheck — 2026-09-14
- Exact Drive originals for the Bifteki and Piatto Meze Vegetariano candidate sets were recovered and visually reviewed.
- Best current Bifteki candidate: `IMG-20240216-WA0039.jpg`; it shows two bifteki with fries, salad, tomato, onion and tzatziki.
- Best current vegetarian meze candidate: `IMG-20240216-WA0057.jpg`; it shows dolmas, fried polpettine, fries, salad, olives and tzatziki.
- The owner could not confirm that either image still matches the current portion/composition. Both remain `conditional` and must not be published until checked against today's actual dishes.
- `IMG-20240216-WA0035.jpg` is a real pita image but remains ambiguous between Pita Gyros and Pita piggy; do not relink it.
- `IMG-20220628-WA0003.jpg` and `IMG-20220628-WA0004.jpg` show old souvlaki plates, not the current unresolved pita products; do not use them as pita photos.

### Useful alternatives / social assets
- `WA0026`, `WA0028`, `WA0029`, `WA0030`, `WA0031` -> Gyros di Pollo al Piatto alternatives; verified/public main image already exists.
- `WA0033`, old `WA0012`, old `WA0002` -> Gyros di Suino / generic gyros plate alternatives; main verified/public image already exists.
- `WA0152` -> Tzatziki alternative/social asset; verified/public main image already exists.
- `WA0037`, `WA0041`, `WA0042`, `WA0043`, `WA0044` -> real ARGO salsiccia plate assets, but active menu currently has Pita Salsiccia, not this exact plated item. Do not use as Pita Salsiccia photo.
- `WA0032`, `WA0060`, `WA0025` -> backstage/process assets, not exact menu product photos.

### Heritage / blocked for current public use
- old `WA0007` -> Gemista heritage; not current menu.
- old `WA0008` -> Dolmas old portion, 5 pieces without tzatziki; current serving differs.
- old `WA0010`, `WA0011` -> old 5-piece polpettine serving; current serving differs.
- `WA0058` -> heritage backstage, identifiable person + vertical-spit machine; requires consent/right and does not represent current process.
- `WA0059` -> foreground resembles Meze Vegetariano but background shows vertical-spit machine; not valid current menu photo unless fully cropped and re-reviewed.

### Current photo priorities
Prioritize exact current-product coverage for:
1. Mix Grill
2. Pita Pollo and Pita chicky separately
3. Pita Gyros and Pita piggy separately
4. Pita Agnello
5. Pita Bifteki
6. Pita Salsiccia
7. Pita Vegetariana
8. Halloumi
9. Bugiurdi
10. desserts and sauces after exact confirmation

### Centered derivative specification — 2026-09-14
- Target format for customer cards: 1200x800 (3:2), baseline/non-progressive JPEG, sRGB, metadata stripped, quality 88.
- No generative editing and no alteration of the food. Only crop, resize and re-encode the real ARGO originals.
- Exact sources/targets: `WA0157 -> dolmas.jpg`; `WA0154 -> feta.jpg`; `WA0014 -> gyros-suino.jpg`; `WA0137 -> insalata-greca.jpg`; `WA0034 -> pita-gyros.jpg`; `WA0006 -> saganaki.jpg`.
- Landscape sources use centered 3:2 crop. Gyros Suino uses source crop `900x600+0+225`; Insalata greca uses source crop `938x625+0+455`.
- All six locally generated previews decoded successfully at 1200x800 and passed contact-sheet review.
- The local execution environment became unavailable before the six derivatives were committed. Production continues to hide every menu photo; regenerate/restore these exact derivatives before re-enabling rendering.
- Re-enable rule: both homepage and ARGO Direct must use a 3:2 media frame, image width/height 100%, `object-fit: cover`, centered object position, and tested error fallback.

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
- Admin photo import also accepts genuinely new shooting filenames. Each new file is stored privately and registered as unlinked `menu_candidate` / `future`; it must pass Admin photo review before any product mapping or publication.
- Raw uploads cannot enter the public menu. `menu_derivative_ready` becomes true only after crop and mobile QA; both the review RPC and the public photo endpoint enforce this gate.
- `admin/photo-crop.html` creates a non-generative 1200x800 JPEG from the private original. The server validates the exact dimensions and stores it separately at `argo-menu-derivatives/{media_id}.jpg`; saving a crop unlocks review but does not auto-publish.
- Private preview functions protect Admin-only media.
- Public customer menu images use approved public/cache routes rather than raw private Google Drive access.
- `argo-public-menu-photo` was hardened so only exact active `menu_verified` mappings can be served.
- The previous Moussaka derivative was withdrawn after its source was identified as stock imagery. Saganaki remains crop-ready; Patatine fritte requires a reshoot.
- The six centered derivatives are live in 3:2 frames with `object-fit: cover`, centered positioning and tested error fallbacks.
- Import of the full local 227-photo folder remains a user-side physical/local-file task.

## Photo review safety
- Menu publication requires `category=menu_verified`, `status=menu`, and an exact active linked menu item.
- Archive media cannot stay linked to menu items.
- `menu_verified_unlinked` remains future/unlinked until exact product identity exists.
- Review decisions are written to `argo_media_review_events` where applicable.

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
- Homepage now reads `image_url` and uses real verified menu photos where available, with fallback and image error handling.
- ARGO Direct now uses the same resilient customer-facing rule: every item has a stable visual placeholder, failed image URLs fall back without a broken-image icon, and real photos use lazy loading, async decoding and a fixed mobile-friendly aspect ratio.

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
- Next major phase after photo completion: build ARGO-owned table reservation system on the site, replacing dependency on Pienissimo runtime.
- Reuse existing `argo_bookings` / `argo_booking_events` where sensible; do not create a parallel duplicate booking universe.
- Planned booking system must include actual table availability, double-booking prevention, operating-hour rules, customer booking flow, admin calendar/table view, status workflow and audit trail.

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
- `assets/menu/verified/` contains only the six approved centered derivatives. The public legacy files for Moussaka, Gyros Pollo, Tzatziki and Patatine were removed, and their menu/fallback URLs are null.

## Stable constraints
- Never reintroduce site delivery logic into ARGO Direct without an explicit business decision.
- Never treat Deliveroo/Just Eat delivery as ARGO Direct orders.
- Never merge confirmed-distinct pita products.
- Never guess unidentified photo contents.
- Never auto-publish conditional images.
- Never claim physical SUNMI, social-account authorization, photo verification or local-folder import complete without real evidence.

## Current open work
Priority order:
1. Keep Gyros di Pollo al Piatto, Tzatziki and Patatine fritte image-free until new photos pass QA.
2. Execute the physical P1 photo shoot and post-shoot handoff for unresolved high-value products, including a replacement Moussaka photo.
3. Preserve the completed 227/227 media audit; do not repeat already classified filenames.
4. Import the 227 local originals into private ARGO storage from the actual local folder when local-file access is available.
5. After photo phase is closed, implement the ARGO-owned table reservation system.
6. Install the current SUNMI APK on the real device and perform printer validation.
7. Connect Meta/Instagram/Facebook and optional Google Business only with real provider authorization.
8. Replace the permanent File Library workbook with the validated 56-sheet XLSX when the actual file is available.

## Checkpoints
- `docs/ARGO_COMPLETION_CHECKPOINT_2026-09-13.md`
- `docs/ARGO_IMPROVEMENTS_2026-09-13.md`
- `docs/ARGO_ORDER_CHANNEL_POLICY.md`
