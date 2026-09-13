# ARGO order channel policy

Canonical operational rule, effective 2026-09-13.

## ARGO Direct

The ARGO website / ARGO Direct accepts **pickup orders only** (`order_type = asporto`).

- Customer orders on the ARGO site.
- Customer collects from ARGO Greek Comfort Food, Via Guglielmo Marconi 27, Ancona.
- No delivery address is collected or operationally used by ARGO Direct.
- Delivery fee is always `0`.
- Admin Orders and SUNMI are the operational queue for ARGO Direct pickup orders.

Database enforcement:

- `argo_orders_pickup_only_check` requires `order_type='asporto'` and zero delivery fee.
- `argo_orders_pickup_only` trigger rejects non-pickup writes.
- `argo_admin_orders` exposes only pickup orders to ARGO Admin/SUNMI.

## Home delivery

Home delivery is **not fulfilled by ARGO Direct**.

Delivery orders are handled externally through:

- Deliveroo
- Just Eat

Those external delivery orders are not ARGO Direct orders and must not be represented in ARGO Direct sales/order-flow metrics unless a future explicit integration is built.

## Product rule

Do not add ARGO riders, ARGO delivery fees, delivery addresses, delivery ETA, delivery status, or delivery dispatch logic to the ARGO Direct flow unless the business model is explicitly changed later.
