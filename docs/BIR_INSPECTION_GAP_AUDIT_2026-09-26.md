# Xantara POS: BIR inspection readiness audit

**Historical baseline.** The [7 October 2026 review](INSPECTION_REVIEW_2026-10-07.md) records current invoice, tax and report evidence. Preserve the dated findings below, but do not treat superseded findings as current implementation status.

Date: 2026-09-26. Result: **not ready for a production POS accreditation demonstration**.

This is an engineering readiness assessment, not a BIR determination. Application code and live data were not changed. The working tree already contained substantial uncommitted work; that current working tree is the audited version.

## Scope and evidence

Reviewed the Flutter POS sale and grocery checkout paths, company/terminal configuration, invoice model and formatter, reporting repository, authorization, audit chain, local database, cloud catalog importer, hardware jobs, and related tests. No physical printer, live trading database, disaster recovery exercise, or BIR submission was tested. The Django and Next.js applications were not comprehensively audited in this pass.

Regulatory references:

- [RMO 24-2023](https://bir-cdn.bir.gov.ph/local/pdf/RMO%20No.%2024-2023.pdf), visually reviewed pages 2-13, particularly IV(5)-(7). It covers accumulated totals, tamper resistance, activity logs, durable storage, electronic journals, X/Z readings, supporting reports, numbering, reprints, retention, and invoice particulars. It identifies Annex F as the demonstration checklist. The separate Annex F and D/E files were not retrieved; final field-by-field annex sign-off remains outstanding.
- [RMC 77-2024](https://bir-cdn.bir.gov.ph/BIR/pdf/RMC%20No.%2077-2024.pdf) and its [invoice information/sample annexes](https://orus.bir.gov.ph/files/RMC_No_77_2024_Annex_A1_B6.pdf), especially A1/A2: current invoice wording, seller/buyer particulars, tax/discount breakdowns, beneficiary information, and applicable permit details. The samples cover multiple invoice methods; manual/loose-leaf ATP examples are not automatically requirements for every POS installation.
- [BIR official RMO index](https://www.bir.gov.ph/2023-Revenue-Memorandum-Order?label=2023+Revenue+Memorandum+Orders&to=2023-Revenue-Memorandum-Order&type=PAGE) for the official annex inventory.

Confirm the filing route, current amendments, and applicable annexes with the receiving BIR office before submission. Native offline POS, web-based POS, CAS components, and electronic invoicing must not be treated as interchangeable classifications. This audit does not certify 2026 EIS/PTI applicability or deadlines.

Priority definitions: P0 = blocks a credible live sales demonstration; P1 = finish before inspection; P2 = documentary/deployment decisions and evidence to resolve before filing. These are engineering priorities, not official BIR ratings.

## Findings

### 01. P0 - Grocery checkout does not commit a sale

**Observed:** `grocery_payment_dialog.dart:191` constructs `GroceryReceiptData`, increments a Riverpod counter, and clears the cart. Its caller only opens the receipt dialog. There is no call to `OfflineSaleRepository.issueSale` along this path. The counter starts at 1 per session (`grocery_cart_provider.dart:140`). The printable grocery document uses hard-coded store details and a four-digit TXN label; it is not the stored BIR invoice formatter.

**Impact:** A cashier can confirm and print a grocery transaction that never reaches the invoice ledger, stock movements, audit events, or terminal readings. Restarting also loses the transaction counter. Noncash confirmation accepts a typed reference without gateway evidence.

**Required implementation:** Route grocery checkout through the same durable invoice/payment transaction as F&B. Use registered terminal numbering and stored invoice output. Define and validate external-terminal/manual payment evidence if supported; a reference string alone must not imply verified gateway capture.

**Acceptance:** Make a grocery sale, restart, and find exactly one invoice, payment, stock movement set, audit entry, and reading contribution. Printing the same sale must not create another sale.

Evidence: [payment confirmation](../lib/features/pos/retail/widgets/grocery_payment_dialog.dart), [caller](../lib/features/pos/retail/screens/grocery_pos_screen.dart), [counter](../lib/features/pos/retail/providers/grocery_cart_provider.dart), [grocery print output](../lib/features/pos/retail/widgets/grocery_receipt_dialog.dart).

### 02. P0 - Live seller and device enrollment are not connected to checkout

**Observed:** F&B checkout explicitly supplies `trainingMerchantProfile` (`checkout_screen.dart:137`). That constant contains placeholder registration data; receipt metadata always sets `isTraining: true`. Seeding creates training MIN/PTU/serial values and `POS01` for each seeded branch. `terminalIdForBranch` derives the same terminal ID for every installation using that branch. Cloud store name/address settings do not replace this invoice profile.

**Impact:** Editing store settings does not establish the actual invoice seller. Separate fresh devices in the same branch can independently start the same invoice series; this is an architectural collision risk, not a concurrency test result. Default local training accounts also need replacement during production enrollment.

**Required implementation:** Durable company and device registration, a unique assigned terminal identity, configurable approved serial starting point, production activation checks, and an owner setup flow. Preserve seller/registration snapshots on issued invoices. Separate demo installations from live trading.

**Acceptance:** Register two devices for one company and demonstrate distinct series, persistence across restarts, and accurate seller/terminal details. A settings change must not rewrite old invoices.

Evidence: [checkout](../lib/features/checkout/screens/checkout_screen.dart), [merchant profile](../lib/features/checkout/providers/checkout_provider.dart), [seed](../lib/local/database_seed.dart), [cloud store settings](../lib/features/settings/providers/store_settings_provider.dart).

### 03. P0 - X/Z workflows and permanent closing records are missing

**Observed:** `TerminalReading` is a date-range aggregate. No X/Z screen, saved closeout table, Z counter, accumulated prior/current totals, business-day closure state, or reading reprint path exists in the inspected Flutter code. Shift state is in memory. The reporting method is not called by a screen.

**Required implementation:** Cashier/terminal X reporting, business-day configuration, atomic Z closeout snapshots and counters, persisted shifts where used, prevention of duplicate closing and posting into a closed day, report history, and reprinting without changing the saved reading.

**Acceptance:** Close once, retry concurrently, restart, reprint, and make a next-day sale. The original closeout must remain identical and its counter must advance only for a new closeout.

Evidence: [reporting](../lib/local/repositories/bir_reporting_repository.dart), [database schema](../lib/local/database.dart), [shift state](../lib/features/cashier/providers/shift_provider.dart).

### 04. P0 - Existing report totals are not stable across adjustments

**Confirmed by probes:** A PHP112 July 11 sale reports PHP112 net. Voiding it on July 12 changes July 11 net to zero; July 12 shows no void because selection uses the original issue date. Separately, a PHP112 line with PHP12 discount reports PHP100 as both gross and net, with no discount total in `TerminalReading`.

**Impact:** The current aggregator cannot serve as a frozen end-of-day record or a complete gross/discount/adjustment reconciliation.

**Required implementation:** Define financial totals precisely; record adjustment events in their effective business period, preserve original sales, and derive reports with separate discounts and adjustment categories. Reconcile to saved Z snapshots.

**Acceptance:** Demonstrate same-day and later-day adjustments, discounted sales, mixed taxes, and backdated requests. Validate original-day and adjustment-day results independently.

Evidence: [date filtering and aggregation](../lib/local/repositories/bir_reporting_repository.dart), audit probes 2 and 6.

### 05. P0 - Synced nonstandard tax categories fail sale issuance

**Observed:** Cloud catalog parsing accepts and stores `vat_exempt`, `zero_rated`, and `non_vat` unchanged. Invoice issuance matches `TaxCategory.values` by Dart names `vatExempt`, `zeroRated`, and `nonVat`. Local inventory writing also retains the underscore values.

**Confirmed by probe:** All three underscore values cause `Invalid tax category` on sale issuance. The probe seeds those importer-accepted values directly; it does not simulate an entire cloud sync.

**Required implementation:** One explicit tax-code mapping across API, local catalog, invoices, and migration of existing rows. Support a configured non-VAT merchant rather than the fixed VAT training seller.

**Acceptance:** Import each supported tax category and sell it through the UI; compare invoice and reading totals. Test mixed VAT/exempt/zero-rated sales and a separate non-VAT seller.

Evidence: [importer](../lib/local/repositories/cloud_catalog_repository.dart), [inventory writer](../lib/local/repositories/inventory_workspace_repository.dart), [sale lookup](../lib/local/repositories/offline_sale_repository.dart), [tax enum](../lib/core/compliance/bir_invoice.dart).

### 06. P0 - Statutory discounts are represented by a generic percentage

**Observed:** Grocery combines Senior/PWD into one option and calculates `base * 0.20` over the post-coupon total. There is no eligible-item classification, beneficiary ID data, distinct discount category, VAT-removal calculation, signature provision, or beneficiary sales report. F&B currently offers a hard-coded `DISC200` promotion. Persisted invoice lines carry only a discount amount.

**Impact:** The software cannot demonstrate differentiated statutory-discount transactions or explain their tax adjustments. The existing grocery calculation must not be assumed valid for every grocery product or beneficiary.

**Required implementation:** Agree supported scenarios with the accountant/BIR, then implement item eligibility, applicable rates and limits, beneficiary capture, tax adjustments, persisted discount reasons, and matching documents/reports.

**Acceptance:** Accountant-approved examples for eligible/ineligible and mixed baskets, quantities, coupons, partial beneficiaries, and rounding. Include other beneficiary categories only where applicable to the supported business scope.

Evidence: [grocery discount](../lib/features/pos/retail/providers/grocery_cart_provider.dart), [checkout promotion](../lib/features/checkout/screens/checkout_screen.dart), [invoice line model](../lib/core/compliance/bir_invoice.dart).

### 07. P1 - Invoice fields and customer capture are incomplete

**Observed:** The common formatter includes invoice title, seller, basic TIN, branch, MIN/PTU, serial, items, and tax totals. It has no supplier accreditation footer, accreditation dates, PTU issue date, beneficiary details, or explicit non-VAT input-tax disclaimer. The seller TIN label does not include the registration wording shown in the current sample annex. Buyer data exists in the domain but checkout never supplies it; choosing a loyalty customer does not populate invoice buyer/TIN/address fields.

The immediate F&B receipt preview uses cart line subtotals without showing their allocated discounts, while the stored formatter uses net lines. The grocery PDF uses a separate hard-coded identity and lacks the common invoice tax/registration details. Long lines in the text formatter are not wrapped.

**Required implementation:** One invoice representation sourced from the persisted record; complete applicable fields and print wording; buyer entry; appropriate training markings; physical layout verification. Do not introduce obsolete receipt-expiry text or copy a manual ATP footer blindly.

**Acceptance:** Print VAT, exempt/mixed, non-VAT, discounted, buyer-requested, original and reprinted invoices with long names/addresses and large amounts. Every displayed total must reconcile to stored data.

Evidence: [formatter](../lib/core/hardware/pos_hardware.dart), [seller model](../lib/core/compliance/bir_invoice.dart), [receipt preview](../lib/features/checkout/widgets/receipt_preview.dart), [grocery output](../lib/features/pos/retail/widgets/grocery_receipt_dialog.dart). Invoice-field comparison: RMC 77-2024 annex A1/A2 linked above.

### 08. P1 - Persistent invoice printing/reprinting is not operational

**Observed:** F&B hardware jobs use `LoggingReceiptPrinterAdapter` with no callback and are then marked completed. `queueInvoiceReprint` exists but has no application UI caller. Grocery has `Printing.layoutPdf`, but it prints the transient grocery receipt from finding 01. Reprint timestamp is the request time; formatter data supplies the requesting actor as cashier rather than a separately preserved original cashier/reprint operator pair.

**Required implementation:** Connect the actual invoice formatter to a supported printer or a validated OS print workflow. Provide authorized invoice-history reprinting, record accurate operator/timing information, and distinguish queued/failed/confirmed delivery. Resolve retry-after-physical-print behavior to avoid unmarked duplicate originals.

**Acceptance:** Successful print, disconnected printer, paper-out, restart/retry, and authorized reprint. Retrying must not allocate a new invoice number. Physical output has not been verified in this audit.

Evidence: [adapter configuration](../lib/local/database_providers.dart), [printer](../lib/core/hardware/pos_hardware.dart), [job processor](../lib/local/repositories/hardware_job_processor.dart), [reprint method](../lib/local/repositories/offline_sale_repository.dart).

### 09. P1 - Journal and supporting report exports are absent

**Observed:** `ElectronicJournalEntry` contains invoice header totals and current status, not full invoice document contents, lines, reprints, reading documents, or separate adjustment documents. No application export caller exists. The Flutter admin Export action is a coming-soon message. No complete sales-summary, beneficiary, return/refund, or void-report pack was found.

**Required implementation:** Daily plain-text document journal, selectable exports, supporting sales/adjustment reports, and a reconciliation manifest. An invoice list or audit hash chain alone is not the full document journal. Add return/refund data and linked documents if those transactions are in the supported scope; current invoice status supports only issued/voided.

**Acceptance:** Export a known day and reconcile each original/reprint/adjustment/reading against the same stored transactions, including a later adjustment and a no-sales day.

Evidence: [journal projection](../lib/local/repositories/bir_reporting_repository.dart), [admin export](../lib/features/admin/screens/admin_dashboard_screen.dart), [invoice statuses](../lib/core/compliance/bir_invoice.dart).

### 10. P1 - Authorization and integrity controls have unprotected boundaries

**Observed:** The order void UI requests supervisor authorization, which is useful. However, issue/void/reprint repository methods do not verify the actor's active staff record, role, or branch permission. The reporting repository also accepts branch/terminal identifiers without a principal.

**Confirmed by probes:** With no staff rows, a sale can be issued and a nonempty nonexistent actor can request reprint and void through the repository. Directly changing an invoice amount to one cent leaves `verifyBranch` valid. Deleting the latest audit event also leaves it valid. These probes require repository/database access; they do not establish a remotely exploitable cashier UI bypass.

**Required implementation:** Enforce permissions at the business-operation boundary, reconcile invoices to audit events, and add independently protected audit checkpoints or equivalent controls. Define database access protections and make verification operational. Review logs for administrative changes, imports/exports, synchronization, and support access; the inspected catalog importer does not append audit records.

**Acceptance:** Wrong-role, inactive, unknown, and wrong-branch actors fail with zero mutation. Detect invoice alterations, removed trailing events, altered audit contents, and missing records. Existing chain tests only cover some of these cases.

Evidence: [authorization policy](../lib/core/auth/pos_authorization.dart), [void UI](../lib/features/orders/screens/orders_screen.dart), [sale repository](../lib/local/repositories/offline_sale_repository.dart), [audit verifier](../lib/local/repositories/audit_trail_repository.dart), probes 3-5.

### 11. P1 - Backup, restoration, and retention are not demonstrable

**Observed:** Native SQLite persistence and browser WASM storage exist. No operator backup/restore flow, scheduled archive, restore verification, retained daily export pack, or tested recovery from storage loss was found in the inspected application. Cloud synchronization is not proof of a complete restorable fiscal backup.

**Required implementation:** Transaction-consistent archives, protected storage, retention policy, restore/replacement-device controls, and an operational recovery runbook. Browser persistence must be assessed for the selected deployment. Restoring an old backup must not enable reuse of already-issued invoice numbers.

**Acceptance:** Restore a backup on a spare installation; reconcile invoice counts, tax totals, reading counters and audit history; prove subsequent serial uniqueness. Test an interrupted transaction and an interrupted print separately.

Evidence: [native connection](../lib/local/database_connection_native.dart), [web connection](../lib/local/database_connection_web.dart), [sync architecture](PREMIUM_SYNC_ARCHITECTURE.md).

### 12. P2 - Reset, release scope, and inspection paperwork need a defined process

**Observed:** No production reset/retirement flow or complete submission packet was found. `docs/BIR_COMPLIANCE_BASELINE.md` is a foundation, not completed inspection evidence. The earlier proposed owner-only reset is insufficient as a live-system design.

**Required planning:** Separate demo disposal, new-customer installation, registered machine retirement/replacement, and fiscal counter rollover. Preserve the old company's records and approval/notification evidence. Decide supported platforms, printer models, payment methods, tax regimes, and application modules. Document software versions and material financial changes.

**External evidence still unverified:** Supplier business registration, eAccReg enrollment, accreditation application/attachments, sworn declarations, authorized representative documents, customer registration/permits, exact Annex F checklist, and the receiving office's requested samples. None should be declared absent merely because it is not in this repository.

**Acceptance:** An agreed submission checklist, architecture/deployment diagram, operator manual, backup/retirement runbook, versioned demo build, and an evidence packet of outputs reconciled to the demonstration data. Confirm the applicable reset/retirement procedure with the receiving office before implementing deletion or rollover controls.

## What already works in the tested layer

- Invoice monetary values use integer centavos; tax categories are separated in the domain calculator.
- F&B repository issuance commits invoice, serial, inventory movements, audit and outbox together.
- Failed issuance rolls back; successful void preserves the invoice number and original financial fields while recording its status and reason.
- Reprint formatting and a durable hardware queue exist below the UI.
- Hash-chain verification detects changed audit payloads and missing middle events.

These are useful foundations, not end-to-end inspection passes.

## Verification performed

Existing focused suite: **21 passed** on 2026-09-26:

```powershell
.\.tools\flutter\bin\flutter.bat test test/bir_invoice_test.dart test/offline_sale_repository_test.dart test/audit_trail_test.dart test/hardware_job_processor_test.dart
```

Additional isolated diagnostic probes: **6 passed by reproducing the gaps**, not by demonstrating compliant behavior:

```powershell
.\.tools\flutter\bin\flutter.bat test tmp/bir-inspection/gap_probes_test.dart
```

The probes use fresh in-memory SQLite databases. Source: `tmp/bir-inspection/gap_probes_test.dart`; generator: `tmp/bir-inspection/build_probes.py`, based on the existing sale fixture. No live records were modified. The full application suite, browser UI and physical hardware were not run for this audit.

## Proposed inspection rehearsal after fixes

| Demonstration | Evidence to retain |
|---|---|
| Register company and two terminals | Approved configuration snapshot and noncolliding invoice series |
| Ordinary cash sale in both F&B and grocery | Stored invoice, printed output, payment, stock and audit records |
| Supported tax categories and mixed basket | Independently calculated expected tax totals |
| Each applicable statutory discount | Eligibility evidence, beneficiary fields, calculation and report entry |
| X reading, restart, Z close, repeated close request | Reconciled outputs, stable Z number and saved snapshot |
| Next-day adjustment to a prior-day sale | Original day preserved; adjustment in correct period |
| Reprint and printer failure/retry | Same invoice number, duplicate markings, operator history |
| Journal and supporting reports | Daily export pack reconciled to invoices and Z |
| Denied operations and tampering probes | Zero unauthorized changes and detected integrity failures |
| Backup and replacement-device restoration | Reconciled totals and uninterrupted unique numbering |
| Business-day boundary and no-sales day | Correct local trading date and reproducible close behavior |
| Large amounts, long text, serial boundary | Untruncated printed totals/identifiers and controlled capacity handling |

Recommended order: fix durable grocery sales and enrollment; normalize tax/discount behavior; implement closeouts and adjustment accounting; complete documents/journals/printing; strengthen authorization and recovery; then rehearse against the exact current BIR checklist.
