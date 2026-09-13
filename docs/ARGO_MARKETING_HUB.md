# ARGO Marketing & Social Hub

Status: implemented in Admin and Supabase on 2026-09-13.

## Purpose
The hub restores the old ARGO concept for direct/social promotion, but with approval and product-truth gates.

Admin page: `admin/marketing.html`.

## Current workflow
1. Choose only an approved/public-safe ARGO media asset.
2. Create caption + hashtags and select Instagram, Facebook and/or Google Business.
3. Choose `organic` or `ad`.
4. Ads require a positive total budget.
5. Save as draft.
6. Approve explicitly.
7. Schedule for a future time or mark for publishing.
8. Autopublish is blocked until a server-side provider connection is both connected and enabled.
9. Every create/edit/status action is written to an audit event table.

## Database
- `argo_marketing_posts`
- `argo_marketing_connections`
- `argo_marketing_events`

All three tables have RLS enabled. Browser access is through authenticated SECURITY DEFINER admin RPCs only.

Admin RPCs:
- `argo_admin_marketing_posts`
- `argo_admin_marketing_connections`
- `argo_admin_marketing_save`
- `argo_admin_marketing_action`
- `argo_admin_marketing_history`

## Publication safety
The save RPC rejects unapproved media. Acceptable media is currently limited to:
- media already published as verified menu media,
- HERO,
- HERITAGE,
- SOCIAL / social_* categories.

Conditional, candidate, audit_reconciled, backstage and archive assets cannot be used as marketing proof by this hub.

`menu_verified` photo review now requires `status=menu` plus an exact active menu item. `menu_verified_unlinked` requires `status=future` and no linked menu item.

## Advertising safety
Paid posts are distinct from organic posts.
- Ads require budget.
- Approval is explicit.
- No ad is auto-launched merely because a draft exists.
- Autopublish requires a connected and enabled server-side provider.

## External-provider boundary
The internal hub is complete enough for queueing, approval, scheduling and audit. Actual one-click / automatic external publishing cannot be truthfully enabled until provider authorization exists.

Do not store Meta or Google secrets in `marketing.html` or any public frontend file. Provider tokens belong in server-side secret storage / a trusted connector.

Current seeded providers:
- `meta` for Instagram/Facebook
- `google_business` for Google Business Profile

Both start disconnected and autopublish disabled.

## Recommended external connectors
For social scheduling/publishing, Metricool can connect Instagram/Facebook/Google Business. For Meta paid advertising, Windsor.ai FB Ads can manage campaigns after explicit confirmation. These are optional external connections and do not replace the ARGO audit/approval database.

## Remaining external-only steps
- connect the real ARGO Meta Business / Instagram account;
- connect Google Business Profile if wanted;
- connect an approved server-side publishing provider or deploy a Meta/Google publisher using protected secrets;
- test one organic post in a non-critical window;
- only then enable automatic publishing;
- test paid ads with a very small approved budget before enabling any recurring automation.
