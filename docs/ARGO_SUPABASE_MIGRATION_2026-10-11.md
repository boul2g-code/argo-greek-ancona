# ARGO Supabase migration

ARGO now uses the dedicated Supabase project `argo-greek-ancon` (`xbzixjrdglpsssgnzrxl`, eu-west-1). The previous shared KIROX project is retained as a rollback source.

Migrated 28 public ARGO tables and 455 rows, constraints, indexes, policies, role grants, sequences, 55 RPC/trigger functions, 5 triggers, and 11 ARGO Edge Functions. The private `argo-admin-media` bucket contains 44 files (7,478,133 bytes); all file contents were verified by SHA-256. Existing VAPID keys and push subscriptions were preserved. The ARGO custom admin password/session records and the existing native Supabase Auth breakglass account were preserved. No KIROX application tables were copied.

Frontend endpoints and publishable keys, photo references, menu snapshots, snapshot workflow, print bridge defaults and service-worker caches use the new project. Both admin login entry points stop waiting after 12 seconds and allow retry when the network is unavailable. Browser sessions on the same GitHub Pages origin retain their existing tokens and notification subscriptions.

Validation: complete source/destination application data comparison before cutover; private storage byte counts and SHA-256 comparison; anon menu access (85 active items); rejection of invalid admin credentials; JavaScript syntax checks for the modified login handlers and service workers. Temporary storage transfer functions were closed after transfer and JWT verification restored.

Only publishable API keys belong in this repository. VAPID private keys and internal order push secrets remain in Supabase. The historical unvalidated opening-hours constraint retains its existing semantics for old orders.
