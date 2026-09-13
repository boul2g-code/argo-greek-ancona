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
8. Editing an approved/scheduled/failed item resets it to `draft` and clears approval, so changed copy cannot bypass review.
9. Autopublish is blocked until the exact required provider connection is connected, enabled and has autopublish enabled.
10. Every create/edit/status action is written to an audit event table.

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
The save RPC rejects unapproved media. Acceptable media is limited to:
- media already published as verified menu media (`status=menu`),
- `hero`,
- `heritage`,
- `social`,
- `social_verified`.

There is deliberately no `social_%` wildcard anymore. Therefore `social_conditional`, `social_archive`, candidate, audit_reconciled, backstage and archive assets cannot leak into the marketing queue merely because their category begins with `social_`.

`menu_verified` photo review requires `status=menu` plus an exact active menu item. `menu_verified_unlinked` requires `status=future` and no linked menu item.

## Channel safety
Autopublish readiness is validated against the channels of the individual post:
- Instagram and/or Facebook require the `meta` provider to be connected, enabled and autopublish-enabled.
- Google Business requires the `google_business` provider to be connected, enabled and autopublish-enabled.
- A connection to an unrelated provider cannot unlock a post for another channel.

A post can be manually marked as published only with an explicit confirmation in the Admin UI, for cases where it was genuinely posted by hand outside ARGO.

## Advertising safety
Paid posts are distinct from organic posts.
- Ads require budget.
- Approval is explicit.
- No ad is auto-launched merely because a draft exists.
- Editing after approval resets the item to draft.
- Autopublish requires the correct connected server-side provider for every selected channel.

## External-provider boundary
The internal hub is complete for queueing, approval, scheduling, provider gating and audit. Actual external publishing cannot be truthfully enabled until provider authorization exists.

Do not store Meta or Google secrets in `marketing.html` or any public frontend file. Provider tokens belong in server-side secret storage or a trusted connector.

Current seeded providers:
- `meta` for Instagram/Facebook
- `google_business` for Google Business Profile

Both start disconnected and autopublish disabled.

## Recommended external connectors
For social scheduling/publishing, Metricool can connect Instagram/Facebook/Google Business. For Meta paid advertising, Windsor.ai FB Ads can manage campaigns after explicit confirmation. These external connections do not replace the ARGO approval/audit database.

## Remaining external-only steps
- connect the real ARGO Meta Business / Instagram account;
- connect Google Business Profile if wanted;
- connect an approved server-side publishing provider or deploy a Meta/Google publisher using protected secrets;
- test one organic post in a non-critical window;
- only then enable automatic publishing;
- test paid ads with a very small approved budget before enabling recurring automation.
