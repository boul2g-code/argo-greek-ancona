# ARGO admin access policy

## Intentional admin identities

The following email identities are intentional ARGO administrators and must not be removed from ARGO RLS policies without an explicit owner decision:

- `boul2g@gmail.com` — full administrator / technical operator.
- `argocucinagreca@gmail.com` — ARGO owner administrator.

## Two authentication paths

ARGO currently has two legitimate admin access paths:

1. **ARGO Admin custom session**
   - Used by the normal `admin/*.html` UI.
   - Authenticated through `argo_admin_login` / `argo_admin_valid`.
   - Business mutations normally go through protected ARGO RPCs.
   - This is the preferred everyday operational path.

2. **Native Supabase Auth**
   - The two intentional admin email identities may receive direct RLS-authorized access where policies explicitly allow it.
   - This path is intentional full / break-glass administrative access.
   - Do not remove it merely because it can bypass UI-level or RPC-only workflow guardrails.

## Security rule

Do not solve guardrail differences by revoking either administrator's intended access.

Critical data integrity rules should preferably live in database constraints or carefully designed table-level invariants when they must apply to **all** write paths. Workflow-only rules may remain in RPCs when direct native-admin access is intentionally allowed for emergency administration.

Never commit passwords, session tokens, OAuth secrets, service-role keys, or user access tokens to this repository.
