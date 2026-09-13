# ARGO PHOTO MASTER

Canonical photo-audit summary. Source workbook: ARGO_Photo_Audit_Master_2026.xlsx.

## Audit status
- Originals reconciled: 227
- Originals classified: 227
- Pending verdicts: 0
- Confirmed ACTIVE: 35
- Conditional ACTIVE: 5
- Heritage winners: 2
- Estimated menu coverage: 58%
- Corrected arithmetic: 128 + 49 + 35 + 13 + 2 = 227

## Current process rule
Meat is cooked in Rational, chilled safely, cut, then finished on grill/plate to order. Do not present vertical-spit imagery as the current production method.

Generated concepts never prove the appearance of a real menu item. Menu photography must match current product, portion and garnish.

## Primary verified winners
- WA0114: A1 HERO, Greek sharing table
- WA0034: A2 MENU, Pita Gyros
- WA0014: A2 MENU, Gyros plate
- WA0016: A2 MENU, Chicken plate
- WA0038: A2 MENU, Soutzoukakia plate
- WA0046: A2 MENU, Vegetarian plate, current composition to verify
- WA0112: A2 MENU, Tzatziki
- WA0137: A2 MENU, Greek salad
- WA0154: A2 MENU, Feta ladorigani
- WA0157: A2 MENU, Dolmas, verify current 4-piece + tzatziki serving

## Conditional assets
- WA0036: fried/grilled cheese, identify exact product before menu use
- WA0096: vegetarian polpettine, identify exact variety before menu use
- WA0130: light dip, likely hummus/other, identify before publishing
- WA0135: dark dip, likely melitzanosalata, identify before publishing
- WA0078 / WA0081: dessert assets, identify exact product before naming
- 20211130-WA0005: Moussaka plate, current plating must match
- 20220628-WA0010: old large mixed souvlaki plate, current product/portion must match
- 20240624-WA0001: stuffed vegetables, item must still be active
- 20240808-WA0019: Nissos beer + Greek salad, beer availability must be verified
- 20231113-WA0019: person serving ouzo, public use requires consent

## Archive / backstage / heritage
- WA0164: Feta service plate, C / BACKSTAGE B. Stories/process only, not homepage/menu/ads.
- 20251222-WA0002: Moussaka production, BACKSTAGE.
- 20211130-WA0012: HERITAGE A, old Greek spread.
- 20220610-WA0014: HERITAGE A3, old Pita Gyros series superseded by WA0034.

## Current database sync state
- argo_media_library now contains all 227 originals.
- Corpus reconciliation is complete; no original is missing from Supabase.
- Seven production menu links are already verified and linked: WA0034, WA0014, WA0016, WA0112, WA0137, WA0154, WA0157.
- WA0038 is menu_verified but intentionally not linked to a different current menu item by guesswork.
- WA0046 remains conditional until current composition is checked.
- Many imported rows still say da_classificare in Supabase. This does NOT mean the master audit is incomplete. The workbook says 227/227 classified, but its recovered filename-level Asset Register does not repeat every one of the 227 verdicts.
- Never manufacture classifications for those remaining rows from filenames alone.

## Photo Admin reliability
- Drive preview fallback chain is enabled for desktop/browser failures.
- Progressive rendering loads 36 photos at a time and adds another 36 through Carica altre foto.
- Progressive-loading production commit: 09052eac4effc7476fb548d45590a4835b4e471c.
- GitHub Pages deployment for that commit succeeded.

## Coverage priorities
P0 ready: Pita Gyros, Gyros plate, Chicken plate, Greek salad, Tzatziki, Feta ladorigani. Soutzoukakia asset is ready but current exact product link must exist. Dolmas is ready after current piece-count verification.

P1 shoot/verify: Pita Pollo, Pita Agnello, Pita Soutzoukaki, Pita Salsiccia, product-specific Pita Vegetariana, current Souvlaki plate, current Mix Grill, current Moussaka, Bugiurdi, sauce identification and current Rational-to-grill process.

P2/P3: Halloumi, Saganaki, Halloumi fries, Feta sticks, vegetarian polpettine variants, Feta e olive, Feta al cartoccio, Portokalopita, yogurt with honey and walnuts, current store/team photography.

## Publishing rules
- Exact-map only verified A2 MENU assets to current menu items.
- Conditional assets never auto-publish.
- HERO, SOCIAL, BACKSTAGE and ARCHIVE stay separate from menu-card imagery.
- Workbook is visual truth; Supabase is current product/name/price/availability truth.
- Keep original filenames and retain source mapping for derivatives.
- Verify portion, ingredients, garnish and consent before public use.
