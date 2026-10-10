# Company and terminal setup

Central company/branch configuration and terminal enrollment were added on 2026-09-29. Start in Admin Settings → Company & BIR Details; see the central-registration workflow below. The original standalone POS flow remains available. Neither flow submits a BIR application or establishes accreditation.

## Original standalone POS flow

1. On launch, choose company setup or the demo workspace. Existing demo data remains available through the demo option.
2. Enter the registered seller name, nine-digit TIN, address, five-digit fiscal branch code, RDO code, VAT status, terminal code, machine serial, MIN, PTU number and issue date, and starting invoice serial. Confirm terminal/series uniqueness against the company's other devices.
3. Create the local owner account with a password of at least 15 characters. No demo users or sample products are seeded into the company workspace.
4. Optionally supply the business ID from an existing web admin deployment. This is not a BIR identifier. Cloud sign-in must match it; leaving it blank keeps the installation offline-only in this phase.
5. Sign in with the new owner account. In **Settings → Company & terminal**, review the saved details, correct them if necessary, and activate using the owner password.
6. The saved-invoice checkout now uses the registered seller and terminal. Grocery checkout is blocked in the registered workspace pending its permanent-invoice implementation.

From an existing demo session, its owner can use **Settings → Company & terminal → Set up company**. No demo records are converted, deleted or copied into the registered company.

## Storage and invariants

- Demo retains the existing `xantara_pos` SQLite/browser database. Registered-company storage is `xantara_company`. Cloud sessions and application-local store keys for the company have their own prefix; old biometric credentials are cleared on workspace transitions.
- A saved company registration always takes precedence at startup, regardless of the demo preference. Once registered, there is no UI to return that installation to demo or erase its records.
- Drift schema v6 adds an explicitly migrated singleton `company_registration` SQL table containing a versioned-by-schema JSON profile. Existing generated Drift tables do not change. New-table creation is included in both creation and upgrade paths; downgrade simulations in tests must remove it when simulating older schemas.
- Owner, MAIN operational branch, UUID terminal identity, invoice sequence and registration audit entry commit atomically. Failure rolls them all back. Registration refuses an already-populated database.
- MAIN is the current internal/cloud catalog branch key. The five-digit fiscal branch code is stored separately and used in invoice seller snapshots and the invoice prefix.
- A generated terminal code is proposed, displayed and editable before activation. The UUID is local identity; it does not independently prove centrally registered uniqueness. Operators must confirm the visible series across installations. Central device enrollment remains future work.
- Draft changes require the original owner's credentials, no invoices, and an unactivated profile. Activation is audited and idempotent. Registration identity and starting series cannot be edited after activation.
- Registered sale issuance checks activation, registered branch/terminal, active local staff, branch access and create-sale permission. Stored seller details override caller-supplied values. Historical invoice snapshots remain unchanged.
- The importer-supported tax codes `vat_exempt`, `zero_rated` and `non_vat` are normalized during issuance to domain enum values. Merchant/item tax compatibility checks remain in force.
- Registered cloud sessions are accepted only for the saved cloud business ID. Upload routing uses the registered installation UUID and terminal UUID. The backend is not modified or automatically provisioned by this change.

## Current limits

- One registered company and one terminal per installation, using the MAIN operational catalog branch. Other companies/devices use separate installations and series.
- Empty company catalogs must be configured or downloaded; no demo stock is carried over. Non-VAT sellers need non-VAT product categories.
- Cloud linkage is configured during setup and can be corrected before activation. Post-activation business-link changes need a separate controlled flow.
- No live reset, customer handover, machine retirement, backup/restore or central terminal enrollment is introduced here.
- X/Z reporting, statutory discounts, printer integration, full invoice/journal formats and the remaining inspection gaps are still tracked in `BIR_INSPECTION_GAP_AUDIT_2026-09-26.md`. Activation is not an assertion that those gaps are resolved.
- The web-admin first-run wizard remains a separate flow. This phase creates the local owner account, not a web account.

## Verification

- Registration suite: 11 tests covering atomic setup/rollback, validation, duplicate/setup refusal, owner activation, draft editing/locking, sale gating and seller identity, tax normalization, cloud mismatch rejection, isolated store keys, and v5 migration/reopen persistence.
- Setup widgets: 2 tests covering phone-size scrolling, validation/review and explicit demo selection. The phone test found and verified the fix for a tax-dropdown overflow.
- Flutter analysis passed. Release web build passed (existing Cupertino font warning).
- Final full suite: **97 passed, 1 failed**. Outdated downgrade fixtures were updated to remove post-version tables. The sole failure is the previously documented `Phone inventory editor switches tiers and saves a basic item`, outside this change.
- Live browser walkthrough unavailable: the computer-use tool reported no connected browsers. No real company was enrolled or activated, no physical printing tested, and no production deployment performed.
# Central registration and POS enrollment (2026-09-29)

The admin dashboard now manages fiscal configuration under **Settings → Company & BIR Details** at `http://127.0.0.1:3000/dashboard/settings`.

1. Sign in as an active administrator. Save the registered company name, nine-digit TIN, registered address and VAT/non-VAT status.
2. Select an existing operational branch and save its five-digit BIR branch code, RDO and registered address. Create operational branches through Branches first.
3. Save a terminal draft with a unique terminal code, machine serial and MIN, plus PTU number/date and the confirmed starting invoice serial.
4. Review and activate using the administrator password. This locks the company, that branch and terminal fiscal details. Copy the terminal ID and enrollment code. A lost code can be replaced only before enrollment; replacement invalidates the old code.
5. Open a fresh POS company workspace at `http://127.0.0.1:8086` and choose **Enroll from admin dashboard**. From demo, use Settings → Company & terminal → Set up company first.
6. Enter the terminal ID/code and cloud administrator credentials, and create a separate local owner account. The POS downloads the activated configuration and atomically creates its owner, terminal and invoice sequence.
7. Sign in locally and connect the **same cloud administrator** in POS Settings to synchronize stock. Enrollment itself does not save the cloud login session. Subsequent sales retain the local registered identity when offline.

Fiscal configuration is separate from general store display/contact settings. Changes in General do not change the registered invoice seller. Registration writes and activation/enrollment have an administrator audit history with before/after values; passwords and enrollment codes are excluded.

Each installed POS uses its existing local `MAIN`/`branch-main` slot for its assigned shop. The server sync mapping and catalog download use the actual assigned cloud branch. This is one terminal/branch per installation, not a multi-branch local selector. Invoice numbering remains local; the server supplies its starting point only during initial enrollment.

Existing standalone registrations and demo data are preserved. A populated company workspace cannot be replaced by enrollment. There is no migration of existing live standalone terminals, reassignment, sales reset, retirement or backup restoration UI in this phase. A completed enrollment leaves a local completion marker; lost databases require recovery rather than restarting a terminal series. Do not clone a registered browser profile or device database onto another terminal.

The deployment is still one company per server database, with multiple branches/terminals. It is not a multi-tenant service. Offline devices do not receive immediate revocation while disconnected. Existing inventory/printer/discount/X-Z readiness gaps still apply; activation in this app is not BIR accreditation or registration.

Backend endpoints: `GET/POST /api/v1/settings/fiscal/`, `POST /api/v1/settings/fiscal/terminals/<uuid>/activate/`, and `POST /api/v1/settings/fiscal/enroll/`. Administrator authentication is required. Enrollment claims are serialized and retryable for the same installation identity and account; a different installation is rejected. Codes are stored as password hashes and shown only when created/replaced.

Migration `settings_app/0008` adds fiscal company, branch, terminal and audit tables. On legacy MySQL/MyISAM deployments it converts only the four required parent/locking tables (`accounts_staff`, `branch`, `sync_installation`, `settings_app_storesettings`) to InnoDB and creates the four new tables in InnoDB. The local affected records were backed up before migration and compared unchanged afterward. Other legacy MyISAM tables remain a separate production-readiness issue.

Verification: 33 backend registration/sync tests passed on SQLite and a separate MySQL/InnoDB test database; frontend TypeScript, panel ESLint and production build passed. Flutter analysis passed, enrollment/repository/sync/widget checks passed, and the release preview was rebuilt. Local admin/POS returned HTTP 200; the live fiscal endpoint returned HTTP 401 without authentication. No signed-in browser walkthrough or real fiscal activation was performed.

---
