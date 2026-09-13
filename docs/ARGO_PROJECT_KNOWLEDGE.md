# ARGO PROJECT KNOWLEDGE

Canonical working knowledge for ARGO Greek Comfort Food. Keep this file updated when important decisions change.

## Business
- ARGO Greek Comfort Food, Ancona, Via Marconi 27.
- Greek comfort/street food, takeaway + delivery + limited seating.
- Current hours: 18:30–23:00 on Monday, Tuesday, Thursday, Friday, Saturday, Sunday. Wednesday closed. No lunch for now.
- Instagram: @argoancona.
- Positioning: contemporary Mediterranean/Greek premium street-food, mobile-first, authentic real food photography. Avoid generic stock-Greece imagery.
- User wants the site/menu to increase sales of mezedes, sauces and desserts.

## Canonical menu and data flow
- Supabase is the source of truth for the active menu.
- Canonical flow: Supabase -> Admin -> ARGO Direct -> homepage.
- Do not use old menu.json as source of truth.
- Do not hardcode old prices or product availability in chatbot/homepage.
- ARGO Direct is the direct ordering channel. Pienissimo remains only for table bookings where applicable.

## Current key menu items/prices
- Pita Gyros €9; Pita Pollo €9; Pita Agnello €11; Pita Bifteki €10; Pita Salsiccia €10; Pita chicky €10; Pita piggy €10; Pita Vuota €1.50.
- Gyros di Suino al Piatto €15; Gyros di Pollo al Piatto €15; Bifteki alla griglia €15; Piatto Souvlaki Kotopoulo €15; Piatto Souvlaki Chirino €15; Piatto Meze Vegetariano €15; Bistecche di suino con patatine fritte €13; Moussaka €15.
- Saganaki €7; Tirokeftedes pikantikoi €6.50; Feta €5.50; Feta in pastafillo con miele e sesamo €9; Dolmas €6.50; Halloumi alla griglia €8; Spiedino di suino con pita e salsa €7; Spiedino di pollo con pita e salsa €7; Feta al Cartoccio €9; Feta ed Olive €7.50; Pita greca €2; Tiri ki elies €9; Polpettine di Ceci €6.50; Polpettine di Melanzane €5; Keftedakia €6.50; Filettini di Pollo Panati €7; Polpettine di melanzane e formaggio €6.50; Patatine fritte €5.
- Insalata greca choriatiki €12; Insalata verde con pomodorini €7.
- Pita Feta €9; Pita vegan €9; Pita dolmas €9; Pita Vegetariana €9.
- Tzatziki €5; Tzatziki grande €6; Tzatziki piccola €1.50.
- Baklava €5.50; Kataifi €5.50; Sokolatopita €5; Yogurt con miele €6; Yogurt con Miele e Noci €7.
- Use Dolmas or dolmadakia, not singular dolmadaki.
- Keftedakia are pan-fried beef meatballs.
- Do not resurrect old Spanakopita/Tiropitaki data without checking current Supabase state.

## Repository and production
- Repo: boul2g-code/argo-greek-ancona.
- main is production source.
- Admin pages include orders.html and photos.html; service worker is admin/sw.js.
- Verify production changes against real remote state, not only local drafts.
- Do not call work deployed until a real commit SHA or verified remote state exists.

## Homepage decisions already established
- Homepage now reads active menu from Supabase, not old menu.json.
- Hero/social image uses real ARGO photo WA0114.
- Hours are 18:30–23:00, closed Wednesday, no lunch opening.
- Lunch booking options removed.
- Old Pienissimo ordering references changed to ARGO Direct; Pienissimo only for bookings where relevant.
- Old Spanakopita/Tiropita and outdated hours references cleaned.
- Chatbot must not guess prices or availability and should defer to live menu.
- Instagram corrected to @argoancona; copyright 2026.

## Admin notification fix
- Commit: 7a01a869d0b1eb75544be5379a4b48a807bb8335.
- Sound and system notifications are independent.
- unlockSound() must not request notification permission.
- Denied notification permission must not show a blocking alert.
- States: NOTIFICHE BLOCCATE / ATTIVA NOTIFICHE / NOTIFICHE ATTIVE.
- requestPermission() only after user action and only while permission is default.
- Orders/polling/actions/sound continue if notifications are denied.
- Polling remains every 5 seconds.
- admin/sw.js was not changed for this fix.

## Photo system
- Admin photo library is backed by argo_media_library and shown in admin/photos.html.
- Real ARGO photos only for production food imagery. No AI/stock for food library.
- Commercial classes: HERO, MENU, SOCIAL, BACKSTAGE, ARCHIVE/REJECT.
- Existing DB workflow also uses menu/future/archive plus category metadata.

### Corpus reconciliation
- 227/227 filenames reconciled.
- 226/227 have a recoverable visual verdict.
- IMG-20240216-WA0164.jpg remains unresolved and must be visually reopened before classification.
- WA0163 is BACKSTAGE only if the depicted process is still current.
- Corrected arithmetic: 128 + 49 + 35 + 13 + 2 = 227. The 006x–010x block is 49, not 39.

### Database gap from last audit
- argo_media_library: 210 rows, all active.
- 7 linked to menu items.
- 7 status=menu.
- 203 status=future.
- 0 status=archive.
- Therefore visual review is far ahead of DB classification.
- With 227 corpus originals vs 210 media rows, 17 originals still need reconciliation into the library.

### Active menu image coverage from last audit
- Pita 1/8.
- Piatti 2/8.
- Mezedes 2/18.
- Insalate 1/2.
- Vegetariano 0/4.
- Salse 1/20.
- Dolci 0/5.

### Already linked verified mappings
- WA0014 -> Gyros di Suino al Piatto.
- WA0016 -> Gyros di Pollo al Piatto.
- WA0034 -> Pita Gyros.
- WA0112 -> Tzatziki.
- WA0137 -> Insalata greca choriatiki.
- WA0154 -> Feta.
- WA0157 -> Dolmas.

### Known visual verdicts
- WA0012 -> MENU ACTIVE, strong meat-plate candidate.
- WA0011 -> SOCIAL + MENU secondary.
- WA0013 / WA0017 -> alternatives.
- WA0016 -> SOCIAL/AD ACTIVE, also linked to chicken plate.
- WA0018 -> SOCIAL.
- WA0019 -> ARCHIVE/MEDIUM.
- WA0010 -> SOCIAL, pita held with glove.
- WA0015 -> BACKSTAGE.
- WA0006 -> MENU ACTIVE for fried cheese / strong Saganaki candidate.
- WA0007 -> MENU secondary for same fried-cheese product.
- WA0009 -> SOCIAL/ARCHIVE alternative open-pita shot.
- WA0163 -> BACKSTAGE if process is still current.
- WA0164 -> unresolved, never guess.
- WA0075 -> dolci / Revani.
- WA0091 -> contorni / Patate.
- WA0130 -> salse, identify before publication.
- WA0152 -> salse / Tzatziki.
- WA0153 -> mezedes atmosphere.
- WA0158 -> Dolmadakia alternative.

### Photo production priorities
Priority 1: Pita Pollo, Pita Agnello, Pita Bifteki, Pita Salsiccia, Moussaka, Souvlaki chicken/pork plates, Saganaki, Halloumi, Tirokeftedes, Feta in pastafillo.
Priority 2: Polpettine di Ceci, Polpettine di Melanzane, Keftedakia, Tirokafteri, Hummus, Melitzanosalata, Baklava, Kataifi, Sokolatopita.
Low priority bespoke photography: Pita Vuota, Patatine, commodity drinks/cutlery.

### Photo workflow
1. Import visual classification ledger into argo_media_library.
2. Reconcile 17 missing originals.
3. Keep WA0164 unresolved until visually inspected.
4. Build a commercial active set rather than exposing all 227 images.
5. Exact-map approved MENU images to menu items.
6. Update menu image URLs only from approved assets.
7. Verify Photo Admin, homepage cards and ARGO Direct after updates.
8. Keep HERO/SOCIAL/BACKSTAGE separate from menu-card imagery.

## Stable constraints
- Never reintroduce old menu.json as canonical.
- Never guess unidentified photo contents from filename.
- Prefer authentic ARGO food photos over stock/AI.
- Avoid unrelated changes to auth, service worker, order flow or database logic while doing photo mapping.
- Verify against real GitHub main and real Supabase state.

## Current open work
- Finish photo-ledger import into Supabase.
- Reconcile 17 missing media rows.
- Resolve WA0164 visually.
- Complete exact product-photo mapping.
- Improve active menu image coverage.
- Final end-to-end order-flow test.
- SUNMI integration/testing after order flow is stable.
