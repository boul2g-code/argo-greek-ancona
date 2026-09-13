# ARGO Improvements — 2026-09-13

This checkpoint records the current improvement wave applied after the main ARGO completion pass.

## Marketing safety
- Marketing posts can be linked to a live `argo_menu_items` product.
- Product activity is re-checked before approve, schedule and autopublish-ready transitions.
- Menu-verified photos cannot be attached to a different linked product.
- Generic approved HERO / HERITAGE / SOCIAL assets remain usable for non-product-specific content.
- Marketing table now has database constraints for allowed channels and paid-ad budget validity.
- Paid ads require a positive total budget.

## Admin settings dashboard
- `admin/settings.html` now shows private-photo migration progress.
- It shows Meta and Google Business connection/autopublish state.
- It links directly to photo import, photo library, photo review, photo shoot plan, marketing, orders, SUNMI and order audit history.
- Admin logout is explicit and clears the local ARGO admin token.

## Sales statistics
- New authenticated RPC: `argo_admin_stats(p_token)`.
- `admin/stats.html` now reports today, last 7 days and last 30 days.
- KPIs include orders, sales, average ticket, open orders and 30-day cancellations.
- It reports top products by 30-day revenue, order-type mix and order-status distribution.
- Cancelled orders are excluded from sales/average/product-ranking metrics.
- Business-day grouping uses `Europe/Rome`.

## Order-state safety
- `argo_admin_order_action` now enforces an explicit state machine.
- `accept_print`: only `new -> accepted`.
- `preparing`: only `accepted -> preparing`.
- `ready`: only `accepted|preparing -> ready`.
- `completed`: only `ready -> completed`.
- `cancelled`: blocked after completed/cancelled.
- Reprint is blocked for cancelled orders.
- This prevents accidental backwards or impossible operational transitions.

## Order audit trail
- Added private/RLS table `argo_order_events`.
- Every successful admin/SUNMI order action stores admin email, action, old status, new status, print metadata and timestamp.
- Added authenticated RPC `argo_admin_order_history`.
- Added `admin/order-history.html` with searchable audit history.

## Still external/manual
- Private photo migration remains dependent on selecting the originals from a local PC at least once.
- Meta / Instagram / Facebook / Google Business external authorization can be connected later.
- Physical SUNMI printer verification still requires the actual device.
- Conditional photo identities require real visual/product confirmation, never guessing.
