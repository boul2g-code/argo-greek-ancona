# ARGO LIVE MENU PHOTO COVERAGE

Generated from the live Supabase menu state on 2026-09-13. Supabase remains canonical for names, prices and active status. This document is a commercial photo-work queue, not a replacement menu source.

## Current food-menu coverage

Active food categories audited: Pita, Piatti, Mezedes, Insalate, Vegetariano, Salse, Dolci.

- Pita: 1 / 8 items with image.
- Piatti: 2 / 9 items with image.
- Mezedes: 2 / 17 items with image.
- Insalate: 1 / 2 items with image.
- Vegetariano: 0 / 4 items with image.
- Salse: 1 / 16 items with image.
- Dolci: 0 / 6 items with image.
- Total: 7 / 62 active food/menu items currently have an image URL.

Small sauce variants, condiments and pita-vuota do not require the same photographic priority as core dishes. The raw percentage therefore understates practical commercial coverage, but the gap remains large.

## Already covered with verified/live images

- Pita Gyros — €9.
- Gyros di Suino al Piatto — €15.
- Gyros di Pollo al Piatto — €15.
- Feta — €5.50.
- Dolmas — €6.50.
- Insalata greca choriatiki — €10.
- Tzatziki — €5.

## P0 — featured active products missing an image

These should be the first shoot / verification targets because they are featured or strategically central:

1. Pita Pollo — €9.
2. Pita Agnello — €11.
3. Mix Grill — €16.
4. Moussaka — €15.
5. Pita Vegetariana — €9.

Pita Gyros and the two Gyros plates are already covered.

## P1 — existing conditional assets that may close gaps without a new shoot

These require visual/product confirmation before any publication:

- Moussaka: `IMG-20211130-WA0005.jpg` — verify current portion/plating.
- Saganaki candidate: `IMG-20240216-WA0006.jpg` — identify exact product.
- Saganaki vs Halloumi: `IMG-20240216-WA0036.jpg` — exact cheese identity required. Current live candidates are Saganaki €7 and Halloumi alla griglia €8.
- Piatto Meze Vegetariano: `IMG-20240216-WA0046.jpg` — verify current composition.
- Hummus: `IMG-20240216-WA0130.jpg` — confirm exact sauce identity.
- Melitzanosalata: `IMG-20240216-WA0135.jpg` — confirm exact sauce identity.
- Mixed/Souvlaki plate: `IMG-20220628-WA0010.jpg` — verify exact current product and portion.
- Vegetarian polpettine: `IMG-20240216-WA0096.jpg` — identify exact variety.
- Desserts: `IMG-20240216-WA0078.jpg` and `IMG-20240216-WA0081.jpg` — identify exact dessert before naming/linking.

No conditional asset is to be auto-published.

## P1 — new shoot gaps with highest commercial value

- Pita Pollo.
- Pita Agnello.
- Mix Grill.
- Current Moussaka if old plating no longer matches.
- Pita Vegetariana.
- Saganaki.
- Halloumi alla griglia.
- Bugiurdi.
- Piatto Souvlaki Chirino.
- Piatto Souvlaki Kotopoulo.
- Hummus.
- Melitzanosalata.
- Tirokafteri.
- Baklava / Kataifi / Portokalopita / Sokolatopita, with exact product identity.

## P2 — useful menu coverage after the core set

- Pita Bifteki.
- Pita Salsiccia.
- Pita chicky — distinct product from Pita Pollo; needs its own exact visual identity.
- Pita piggy — distinct product from Pita Gyros; needs its own exact visual identity.
- Bifteki alla griglia.
- Bistecche di suino con patatine fritte.
- Feta in pastafillo con miele e sesamo.
- Spiedino di suino con pita e salsa.
- Spiedino di pollo con pita e salsa.
- Feta al Cartoccio.
- Feta ed Olive.
- Polpettine di Ceci.
- Polpettine di Melanzane.
- Polpettine di melanzane e formaggio.
- Filettini di Pollo Panati.
- Insalata verde con pomodorini.
- Pita Feta / Pita vegan / Pita dolmas.
- Yogurt con miele / Yogurt con Miele e Noci.

## Distinct-pita protection

The following pairs are confirmed operationally as different products and must stay separate in menu cleanup, photography, admin mapping and future merchandising:

- Pita Pollo != Pita chicky.
- Pita Gyros != Pita piggy.

Do not reuse the Pita Pollo image for Pita chicky or the Pita Gyros image for Pita piggy merely because the base protein family is similar. Each product requires exact-product verification. Current descriptions are not sufficient to document the real operational difference, so no invented wording should be pushed to production until that difference is explicitly supplied.

## Low-priority image gaps

These can reasonably share family imagery or remain without dedicated photography until core coverage is complete:

- Pita Vuota.
- Pita greca.
- Patatine fritte.
- Small sauce variants.
- Ketchup / Maionese.
- Yogurt naturale sauce variants.

## Data-quality decisions already applied before photo mapping

- Duplicate `Halloumi Grigliato €7.50` was deactivated; canonical active item is `Halloumi alla griglia €8`.
- Duplicate `Mussaka della Casa €15` was deactivated; canonical active item is `Moussaka €15`.
- Semantic duplicate `Tiri ki elies €9` was deactivated; canonical active item is `Feta ed Olive €7.50`.
- `Piatto Meze Vegetariano` corrected to `vegetarian=true`.
- `Dolmas`, `Feta in pastafillo con miele e sesamo`, and `Tirokeftedes pikantikoi` corrected to `vegetarian=true` based on their current live descriptions.
- `Polpettine di melanzane e formaggio` description corrected so it is no longer identical to the plain melanzane item.
- Active exact-name duplicates are now blocked by the database guard `argo_menu_items_active_category_name_uq`.
- Pita Pollo/Pita chicky and Pita Gyros/Pita piggy are confirmed distinct and are explicitly excluded from duplicate cleanup.

## Safety rules

- Workbook/master verdict = visual truth where filename-level classification exists.
- Supabase = current product/name/price/availability truth.
- Never map by visual similarity alone.
- Do not use an old photo when portion, garnish or composition differs from the current product.
- Better no image than a misleading image.
- Never relabel the verified Soutzoukakia asset as Bifteki without explicit product proof.
