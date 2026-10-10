# X readings and daily Z closeouts

Open **POS → Settings → End-of-day reports** on port 8086. The report covers the selected terminal and combines grocery and Restaurant/F&B invoices. This is implemented in the offline POS, not the port-3000 admin reporting page.

1. Choose an open business date. Dates use Asia/Manila (UTC+08:00).
2. View X to inspect sale counts, invoice range, gross sales before discounts, discounts, sales after discounts, void adjustments, net sales, tax breakdowns and net payment totals. X does not change invoice numbering or close the day. Generating X is recorded in the audit trail.
3. After all sales and adjustments are finished, an owner, admin or manager reviews the report, checks the confirmation box, and enters their own local password to save Z.
4. Z receives a consecutive number per terminal and is stored permanently. Open it from Saved Z readings to view, copy text, or print/save a PDF copy. Output requests are audited; an operating-system print cancellation is not represented as a successful physical print.

**Closing today's date ends posting for that terminal until the next Manila calendar day.** There is no reopen or reset button. Older days with unclosed events must be closed first. If sales change after X was generated, refresh and review X before closing. Retrying the same closeout returns the already saved Z rather than allocating a second number. A day with no sales can be closed with zero totals.

## Accounting and persistence

### Employee daily report and Excel download

Open POS Settings → End-of-day reports. The same screen serves Restaurant and Grocery.
Choose an open date, or select a saved Z below. Summary cards show gross sales,
discounts, voids and net sales; expand Full report for taxes, payments and identity.
Download for Excel (CSV) exports the displayed snapshot, with numeric PHP amounts,
counts, invoice range, void references, branch/terminal and generation time.
Open snapshots are as of their generation time: refresh to include newer sales.
Downloads do not close days, reset counters or change saved Z reports.

Web uses the browser download destination. Native builds save into Downloads (or
application Documents when Downloads is unavailable), and show the saved path.
The file is UTF-8 CSV, not an XLSX workbook. Text cells escape CSV delimiters and
formula prefixes. Export requests use the existing output audit and branch permissions.
Reports include only this terminal; net payment totals are not counted drawer cash.
The separate [cash drawer reconciliation](CASH_DRAWER.md) section records opening
float, cash movements, counts and manager review, and is included in report copies.

Schema v7 adds `fiscal_reading_events` and `fiscal_z_readings` with explicit SQLite migrations; generated Drift tables are unchanged. The upgrade backfills historical sale and void events on their original event dates. These may create earlier open days that require review before today's first closeout.

SQLite triggers record invoice issuance and the first void transition inside the existing sale/void transaction. Reports select by event date, not the invoice's current status. A later-day void appears as a negative adjustment on its own day, including tax and payment reversals, while the earlier saved Z remains unchanged. Void references are listed even when no new invoices were issued that day. Payment totals are net accounting amounts, not a cash-drawer reconciliation or verified refund record.

Z snapshot insertion and its audit event commit together. Database triggers prevent updates/deletion of saved Z snapshots and reading events. Separate triggers reject sales and voids posted on or before the latest closed business date; these failures roll back the existing invoice/stock/payment transaction. Invoice serials are never reset. Reporting totals use integer centavos. The cumulative figure is explicitly cumulative **net** sales, not a claim to implement every statutory accumulated-counter definition.

Cashiers and auditors may view terminal reports for assigned branches; only owners/admins/managers may close. Permissions, active staff and branch access are checked in the repository. Closeout password failures retain the existing authentication lockout counters. Registered terminals must be activated before closeout.

## Current scope and verification

These are internal operational X/Z reports, not a claim of BIR accreditation or final inspection approval. [BIR RMO 24-2023](https://bir-cdn.bir.gov.ph/local/pdf/RMO%20No.%2024-2023.pdf) includes X/Z readings within the electronic-journal requirements. The daily `.txt` journal is now available; see ELECTRONIC_JOURNAL.md for coverage and historical audit limitations. Drawer reconciliation is implemented (CASH_DRAWER.md). Final inspection layouts, statutory discount breakdowns and other audit gaps remain pending. Overnight business days, multiple Z shifts within one date, central Z upload/admin reports and hardware-printer integration are outside this phase. The older arbitrary-range `BirReportingRepository.terminalReading` is not used for these closeouts.

Automated checks cover snapshot persistence across reopening, next-day voids, closed-day posting rollback, stale reviews, chronological closing, permissions/passwords, Manila midnight, concurrent close requests, output audit, v6 backfill, and phone-screen review controls. No live business day is automatically closed when the app is upgraded.
