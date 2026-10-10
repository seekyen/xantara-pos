# Daily electronic journal

Review update: see the [7 October 2026 inspection review](INSPECTION_REVIEW_2026-10-07.md). The reset isolated demo profile now passes journal export after restart; retained legacy databases are not repaired by that reset. Step 2's scoped engineering review is complete with material field/layout and workflow gaps still open.

POS > Settings > End-of-day reports > Electronic journal. Select a Manila
calendar date and download the TXT file. Scope is the currently registered
terminal and assigned branch. Reading permission is required. Downloading does
not close the day or allocate invoice numbers. CSV remains a separate summary.

Schema 9 captures immutable, hashed documents atomically with their audit event:
issued invoices, void adjustments, invoice reprint/PDF-copy requests, original
X/Z readings, reading-copy requests, and drawer opening/in/out/refund/count/review.
Invoice documents include stored header, lines, discount/tax amounts, payment,
receipt text, original cashier, requesting actor, time and scope. Amounts in JSON
fields ending in Centavos are integer centavos. Copy records mean requested
output; they do not prove successful physical printing.

Original readings belong to the reading's business date. Copies belong to the
request date. Voids belong to their adjustment date and do not change the
original issue document or earlier saved Z. Drawer events use the selected
drawer day. Dates follow Asia/Manila, not overnight trading shifts.

Export verifies the branch audit chain, document hashes/source/scope, invoice
and void coverage, line/payment totals, tax/discount/gross/net aggregates,
drawer event count, and saved Z totals. Failure stops export. Export requests
are audited with a file hash but are not recursively included as journal
documents. Documents retain stable hashes; the file's export time/operator can
change. An open-day export is explicitly an as-of report.

## Historical data and limitations

Records predating schema 9 are reconstructed once from available stored data
and labelled RECONSTRUCTED FROM STORED RECORDS. This cannot establish the exact
original printed layout, historic staff display name, or absent source records.
No historical audit hashes are rewritten.

An existing audit defect hashed fractional timestamps although SQLite persisted
whole seconds. New audit writes now normalize time before hashing. Historical
chains affected by that defect fail verification and block journal export;
preserve the database for review. Do not reset or delete fiscal data to bypass
the failure. A tested schema-8 migration with valid audits succeeds; this is not
a promise that every historical database can be exported.

Full returns/credit notes, kitchen/open-order documents, shift journals, central
cloud journal reporting, external archival retention and physical printer
verification are outside this implementation. Cash refund payout is drawer
evidence, not an invoice refund/credit note. The separate Restaurant menu is
still not implemented; working Food & Beverage and Grocery share these records.

This is an internal inspection-preparation export. The field-by-field invoice,
tax and report compliance review is the next checklist step. Functional tests
and SHA-256 manifests do not constitute BIR accreditation or a tamper-proof
external archive.

## Verification (6 October 2026)

53 focused tests passed across journal/closeout, audit, Grocery, company setup,
invoice, hardware-job and F&B cash-entry suites. Targeted analysis is clean and
release web preview built successfully (existing Cupertino font warning).
Actual isolated browser download after restart contains the PHP100 demo sale,
tendered150.50/change50.50, its X reading, and reconciliation PASS. Older isolated
demo history correctly blocks export on audit verification failure. Evidence:
`tmp/uat-cash-drawer/JOURNAL-RESULTS.md`, `journal-demo.txt`, `journal-latest.png`
and `journal-legacy.png`. No real company records or closeouts were created.
