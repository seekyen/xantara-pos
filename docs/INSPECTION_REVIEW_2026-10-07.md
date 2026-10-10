# Xantara POS - invoice, tax and report review

10 October: [commercial-discount/report controls and isolated restore rehearsal](PENDING_CONTROLS_2026-10-10.md) supersede the promo/allocation/employee-wording findings below. Restaurant is deferred by request. Statutory discounts, physical printing and full operational recovery remain pending; the historical findings below are not the current status for completed items.

9 October revision 2: [business profiles](BUSINESS_PROFILES.md) implemented; invoice browser verification completed and inventory test fixed. Full suite 145 passed. Updated report/checklist distinguish these completed changes from the remaining gaps below.

Implementation update: the [8 October buyer and invoice-field update](INVOICE_BUYER_FIELDS.md) supersedes the buyer-entry, heading and F&B preview gaps below. Supplier fields are now configurable and snapshotted, but actual approved particulars and final inspection acceptance remain pending. This dated review is retained as the baseline.

7 October 2026, Asia/Manila. **Step 2 scoped engineering review completed; material gaps remain. Not production inspection-ready.** This is not an accreditation certificate or a completed official Annex F.

## Reviewed build and evidence

Flutter working tree, version1.0.0+1, schema9, base commit `dde1af410337aee5fa7d9837f2ada697f9718395`, with substantial uncommitted changes. The commit alone does not identify the tested code. Source and served preview hashes are recorded separately in `output/inspection/2026-10-07/evidence-manifest.json`. Existing release preview ran on8086; no new application build or production deployment. No application financial behavior was changed.

- **60 existing focused tests passed:** invoice, sale repository, audit, hardware jobs, closeout/journal, Grocery, registration and F&B cash entry (`tmp/step2-tests.log`).
- **3 new review tests passed:** seven centavo boundary cases, line-versus-aggregate rounding, and registered mixed-tax invoice/X/Z/CSV/journal reconciliation (`test/inspection_review_test.dart`, `tmp/step2-review-tests.log`). Targeted Dart analysis passed.
- **Browser reset/restart passed:** fresh F&B sale100.00, tender150.50, change50.50; invoice MAIN-POS01-00000001. X CSV: one sale, zero voids, net100.00, VATable89.29, VAT10.71. Journal reconciliation PASS. A second browser process reopened the profile and downloaded without another sale. New browser scenario did not close Z or reconcile a drawer.
- Browser used a dedicated demo profile with backend API traffic blocked. Registered samples were generated in an isolated in-memory test with fictional identity/permit data and buyer fields supplied by the harness, not cashier UI. They are not valid business invoices.
- New headless screenshots lacked readable text despite successful semantic UI interactions and downloads. They are not visual acceptance evidence; final browser visual sign-off remains pending. The report uses the verified downloaded data instead.
- The original6 October report remains evidence for the earlier two-sale, shortage, manager review and Z scenario; those were not all rerun today.

## Reset disposition

User-authorized reset affected only `tmp/uat-cash-drawer/profile`. Prior state remains in `profile-before-reset-20261007-034223`; prior CSVs/screenshots remain. Fresh profile now holds the new demo sale. Other profiles and real company databases were untouched.

The legacy fractional-timestamp/hash defect remains unresolved in retained old data. New normalized writes pass. Affected retained databases must still fail journal verification and be investigated. This reset is not a migration or a production fiscal-data deletion procedure.

## Field and control register

PASS means only the stated layer/scenario passed. PARTIAL means present with limitations. GAP means missing/inconsistent in inspected code. UNVERIFIED means insufficient evidence. These are engineering ratings.

| ID | Field/control | Evidence and finding | Closure evidence |
|---|---|---|---|
| I01 | Seller name/address/TIN/branch | PASS, repository: registration overrides caller identity; synthetic output contains fields. | Actual registered UI and approved particulars. |
| I02 | VAT status/TIN heading | GAP: VAT INVOICE/NON-VAT INVOICE present; heading is only TIN, branch separate. | Final approved tax-registration label and identifier layout. |
| I03 | Machine/permit/software | PARTIAL: MIN/PTU/serial/software/version printed. Invoice model lacks PTU date and supplier/accreditation details; X/Z stores PTU date/RDO. | Confirm and snapshot applicable footer particulars. |
| I04 | Number/time | PASS, scoped: padded8-digit serial, transactional allocation, rollback/reopen. Time is ISO text; timezone depends on input DateTime. | Maximum-width print, timezone convention and device/series proof. |
| I05 | Buyer name/TIN/address | GAP at UI: model/storage/formatter support fields; both checkout calls omit buyer; issuer does not validate required-buyer cases. Loyalty identity is separate. | Cashier entry, applicable validation and reprint persistence. |
| I06 | Description/quantity/unit/discount/net | PASS in formatter and repository. F&B preview is a separate simplified output. | Common saved-invoice output; long-name/large-value print. |
| I07 | Tax categories | PASS, scoped: integer inclusive VAT, zero/exempt/non-VAT separation, mixed sample. Non-VAT has a single bucket. | Applicable non-VAT/percentage-tax/exempt cases; no universal coverage claim. |
| I08 | Original/copy/void | PASS, scoped: reprint label/time, audit request, preserved original and later-day reversal. | Physical original/reprint, failure/retry, permissions. |
| R01 | X/Z scope, dates, counts, range | PASS, repository: terminal/day snapshot, immutable Z, role/password, idempotency and closed-day rejection. | Official-layout crosswalk and print. |
| R02 | Gross/discount/sales/void/net/tax | PASS for tested reconciliation. Cumulative values explicitly represent NET. | Confirm accumulator meaning, width and rollover/reset counter. |
| R03 | Supporting reports | GAP: no demonstrated complete statutory-beneficiary books, return/credit notes or full sales-summary/void-report pack. | Applicable reports and linked adjustment samples. |
| R04 | Employee CSV | PARTIAL: operational summary omits TIN/address/MIN/PTU/serial and detailed cash events. Scope says restaurant although standalone Restaurant is unavailable. | Correct F&B/Grocery wording; distinguish official fiscal outputs. |
| J01 | Journal | PASS for supported documents: snapshot/hash/source/scope/totals validation and reset/restart download. Legacy failures remain. | Official layout and archival retention controls. |
| C01 | Cash payout vs invoice adjustment | PASS distinction: payout does not void/refund the invoice. Full returns/credit notes GAP. | Linked documents and cash reconciliation. |
| C02 | Recovery/physical output | UNVERIFIED in this review. Logging adapter completion is not paper output. | Restore, serial protection, outage, print retry and off-device archives. |

## Reproducible arithmetic

All amounts PHP; persisted values are integer centavos.

| Synthetic item | Gross | Discount | Net | VAT base | VAT | Zero-rated | Exempt |
|---|---:|---:|---:|---:|---:|---:|---:|
| VAT |112.00|11.20|100.80|90.00|10.80|0.00|0.00|
| Zero-rated |50.00|5.00|45.00|0.00|0.00|45.00|0.00|
| Exempt |30.00|3.00|27.00|0.00|0.00|0.00|27.00|
| Total |192.00|19.20|172.80|90.00|10.80|45.00|27.00|

Cash200.00 minus total172.80 = change27.20. X/Z net172.80; saved Z1; invoice42 and next serial43. Journal reconciliation PASS. No counted drawer was started in this synthetic example; the report correctly says not reconciled.

VAT rounds the exclusive base per line, then VAT is net minus base. Seven explicit boundary cases pass. Two distinct PHP0.05 VAT lines yield base0.08/VAT0.02; one PHP0.10 line yields base0.09/VAT0.01. Both conserve money. Obtain acceptance of the rounding policy; the test is not a regulatory ruling.

Grocery allocates generic basket discounts proportionally using cumulative integer rounding. F&B allocates DISC200 to earlier lines first and has no registered-installation guard in `_applyPromo`. Mixed-tax allocation can therefore depend on item order. Agree a common commercial-discount policy and disable demo-only promotions for registered use. Generic discounts are not statutory SC/PWD discounts; Grocery explicitly rejects Senior/PWD and no complete statutory engine is evidenced.

## Correction order and inspector acceptance

1. Buyer entry and final invoice heading/footer; align previews with saved invoices. Demonstrate real identity and permits without inventing particulars.
2. Registered promo guard, mixed-tax allocation/rounding, applicable statutory identity/eligibility/VAT treatment and beneficiary reports.
3. Official Annex D/E/F crosswalk, cumulative totals/counter handling and supporting reports. Separate annex files were not retrieved in this review: final field-by-field sign-off remains pending.
4. Linked returns/credit notes, actual original/reprint, printer failure/retry, restore and serial protection. Continue Step3 after material Step2 gaps are addressed.
5. Employee wording: technical Invalid argument(s) prefix on shortage validation and CSV restaurant wording remain identified, not corrected in this review.

Rehearsal: record reviewer/operator, date, exact build hash, platform/printer, registration/terminal and starting serial. Issue applicable tax cases; capture buyer/discount evidence; reconcile invoice and payment; reprint without a second sale; generate X/journal; count/review drawer and close Z; restart and retrieve; show closed-day protection, later adjustment and isolated restore. Preserve originals and all error evidence.

Reviewer/signature, receiving office/filing route, final build/printer and official acceptance: **pending**. Supplier/customer paperwork is **not verified**, not declared absent.

## Regulatory references and limits

- [RMO24-2023](https://bir-cdn.bir.gov.ph/local/pdf/RMO%20No.%2024-2023.pdf), sectionIV(5)-(7), pages7-13: baseline machine controls/output review, including accumulators, activity logs, journal, readings, supporting reports, numbering, reprints, retention and invoice particulars. AnnexF guides evaluation. Above findings describe observed code, not a completed annex.
- [RMC77-2024 official digest](https://bir-cdn.bir.gov.ph/BIR/pdf/RMC%20No.%2077-2024%20Digest.pdf), pages1-3: invoice terminology and clarification that buyer/seller business style need not appear. Missing business style alone is not marked a defect. Historical conversion rules are not instructions to reset this POS series.
- [RR11-2025 official digest](https://bir-cdn.bir.gov.ph/BIR/pdf/RR%2011-2025.pdf): electronically reportable structured invoices differ from computer-generated paper output. A TXT journal is not evidence of EIS transmission.
- Official indices surfaced RR26-2025 and RMC98-2026, but full texts were not successfully retrieved. Electronic-invoicing applicability, amended deadlines and2026 filing rules remain **unresolved** and require receiving-office confirmation. Sources checked7 October2026.

## Evidence and reproduction

`output/inspection/2026-10-07/`: fictional registered invoice/X/Z/CSV/journal, browser demo journal/CSV, test/analysis logs and SHA-256 manifest. Hashes identify files; they are not external notarization. Updated user-test PDF retains original 6 October results as historical appendix; work checklist records review completion separately from unresolved compliance gaps.

Source anchors: `lib/core/compliance/bir_invoice.dart`, `lib/core/hardware/pos_hardware.dart`, `lib/features/checkout/screens/checkout_screen.dart`, `lib/features/checkout/widgets/receipt_preview.dart`, `lib/features/pos/retail/providers/grocery_checkout_provider.dart`, `lib/local/repositories/terminal_closeout_repository.dart`, `lib/local/repositories/daily_journal_repository.dart`, `lib/features/reports/daily_report_csv.dart`.

Tests: run the8 existing suites listed in `tmp/step2-tests.log`, then `flutter test test/inspection_review_test.dart --reporter expanded`. Set `INSPECTION_EVIDENCE_DIR` only to emit samples. Browser: `tmp/uat-cash-drawer/step2-reset-check.cjs` without arguments checks existing data; **do not rerun --sale on the populated profile**.
