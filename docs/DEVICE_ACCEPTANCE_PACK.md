# Xantara POS device and printer acceptance pack

Prepared 10 October 2026 for the current Food & Beverage and Grocery/Retail scope. Restaurant is deferred. This pack can be completed when a target Windows device, supported receipt printer and cash drawer are available. Preparing the pack does not constitute device, printer, production or BIR acceptance.

## Before the session

Record the application/build identifier, database/profile name, Windows version, printer make/model, connection type, driver version, paper width, cash-drawer connection, backend URL/version and tester/reviewer. Use a fictional or authorized test company and test beneficiaries. Never place real beneficiary ID data in screenshots or shared evidence.

Use a fresh acceptance profile. Configure one VAT product at PHP 112.00 for ordinary/F&B tests, one eligible Grocery BNPC product at PHP 100.00, and one excluded product. Enable only the intended statutory scheme. Create owner, manager and cashier accounts. Confirm the matching credit-note backend handler is deployed before testing synchronization.

Record the starting invoice number, credit-note number, Z number, stock quantity, drawer balance and sync queue state. Photograph the printer label and connection without exposing credentials.

## Evidence convention

Create one folder named `YYYY-MM-DD-device-acceptance`. For every scenario use its ID in filenames, for example `AT-04-original.jpg`, `AT-04-reprint.jpg`, `AT-04-journal.txt`, and `AT-04-result.md`. Preserve original files. Record SHA-256 hashes in the evidence register. Redact beneficiary IDs only in shared copies; retain controlled originals according to the approved retention procedure.

## Test sequence

| ID | Scenario | Expected result and evidence |
|---|---|---|
| AT-01 | Startup and registration | Correct company, branch, terminal, TIN/permit particulars, application version and next counters. No production credentials in the evidence copy. |
| AT-02 | Ordinary F&B cash sale | One invoice and payment, stock reduced once, drawer opens once, original prints once, totals and VAT reconcile. Capture screen, paper, invoice record and queue. |
| AT-03 | Ordinary Grocery cash sale | Same controls as AT-02 on the Grocery checkout; correct product, quantity, tax and change. |
| AT-04 | Senior/PWD F&B sale | One beneficiary; eligible exclusive-consumption line; VAT relief and 20% discount shown separately; beneficiary evidence retained; receipt, X and journal agree. |
| AT-05 | Grocery BNPC sale | Eligible items receive 5% discount without VAT relief; excluded items remain ordinary; weekly purchase/discount and booklet evidence agree. |
| AT-06 | Authorized reprint | Reprint says REPRINT ONLY, keeps the original invoice number/content, records operator/time and creates no sale, payment, stock or drawer duplication. |
| AT-07 | Printer disconnected | Financial sale saves once; print job is visibly failed/pending. Reconnect and authorized retry produces the same invoice number without a second sale. Record uncertainty if the first physical outcome cannot be known. |
| AT-08 | Paper-out/restart retry | Saved sale and queued job survive app/device restart. Retry uses the same job/invoice. Confirm no duplicate original is silently treated as first output. |
| AT-09 | Partial cash return with restock | Credit note links the original, uses CN series, records one cash refund, restores selected quantity once, and adjusts current X/journal without changing the invoice. |
| AT-10 | Damaged-item return | Credit note and one cash refund save; restock is off and sellable stock does not increase. A duplicate submission or excess return is rejected. |
| AT-11 | Later-day return after Z | Original Z remains byte-for-byte unchanged; return appears on the new business day and reduces its cash/net/tax/statutory totals. |
| AT-12 | Count, review, Z and sync | Expected cash equals opening + cash sales + cash in - cash out - credit-note refunds. Reviewer signs in separately; Z, CSV and journal reconcile; supported events reach the matching backend once. |

## Required reconciliation

For each invoice: line totals equal amount due; taxable base + VAT + exempt + zero-rated + non-VAT equals net; tender - change equals cash payment. VAT relief and statutory discount remain separate. For each credit note, accumulated returned quantity never exceeds the original quantity and all partial notes together conserve the original line's refundable cents.

For the day: invoice sales - voids - credit notes = net sales. Opening float + cash sales + cash in - cash out - linked credit-note refunds = expected drawer cash. Count variance equals actual count - expected cash. X, saved Z, CSV and electronic journal must use the same supported document set and totals.

## Stop conditions

Stop the session and preserve the database/evidence if an invoice or credit-note number is reused, a saved transaction disappears, a refund is recorded twice, stock changes twice, the original invoice mutates, a closed Z changes, audit verification fails, totals do not reconcile, or retry creates an unmarked duplicate. Do not reset counters or rewrite fiscal/audit history to make a test pass.

## Acceptance gate

Passing requires all applicable scenarios, identified hardware and software versions, readable unclipped paper output, reconciled exports, retained failure evidence, and signatures from the operator and reviewer. Any unsupported printer, driver, settlement or statutory case must be recorded as out of scope. Formal regulatory acceptance remains a separate determination.

The printable interactive version is `output/pdf/Xantara-POS-Device-Acceptance-Pack-2026-10-10.pdf`.
