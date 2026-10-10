# Discount, report and recovery update - 10 October 2026

Later 10 October update: [Senior/PWD checkout](STATUTORY_DISCOUNTS.md) adds a scoped beneficiary workflow, separate VAT relief, catalog eligibility and supporting reports. Its supported scope and remaining exceptional cases supersede the general statutory-gap statement below.

Restaurant development and Restaurant-specific testing are deferred at the user's request. The active scope remains Food & Beverage and Grocery / Retail.

## Completed changes

- Both checkouts allocate commercial basket discounts proportionally in integer centavos using the largest-remainder method. Remaining centavos go to the largest remainder, then product ID for ties. Reordering the same product basket does not move a rounding centavo between tax categories. Previously issued invoices are unchanged.
- Custom percentage inputs use exact decimal arithmetic (up to six decimal places, rounded once to centavos). Peso discounts accept at most two decimal places; exponent notation, negative/out-of-range values and fractional centavos are rejected at save. This preserves the tested 12.345% case without binary floating-point discount arithmetic.
- Registered F&B blocks the training-only DISC200 promotion. Both checkout requests mark demo promotions, and the repository rejects them for registered installations before fiscal mutation. This is a demo-promotion guard, not a statutory discount engine or an approved promotion-management system.
- F&B checks expected unit prices and computes basket totals from centavos. After an invoice commits, the cart clears; a hardware-worker outage cannot report the sale as unrecorded or leave the basket available for duplicate retry. Other post-commit presentation failures identify the saved invoice and direct the operator to history.
- Operational CSV now includes stored seller TIN/address, MIN, PTU/date, machine serial and RDO. It remains an internal report, not an official filing format. Report scope identifies the active business/terminal and retained historical sales. Cash validation messages no longer prepend `Invalid argument(s)` or `Bad state`.

## Restore verification

`RecoveryInspectionRepository` compares an isolated copy against an independently retained checkpoint: schema version and definitions/triggers, hashes of all 30 application tables, SQLite integrity/foreign keys, branch audit chains and invoice sequence high-water checks. It does not repair data, reset counters, restore into the active application or authorize live trading.

The synthetic test closes a registered schema-11 database, copies it to backup, restores to a different file, and verifies identity, fixed profile type, next serial 43 and the identical saved Z #1. The restored journal reconciles. An injected abort while inserting invoice lines rolls back the entire sale; all table hashes return to the checkpoint after removing the test trigger. A later source sale gets serial 43; the older restored copy is detected against the newer independent checkpoint. Setting a restored sequence back to an issued serial is also detected.

This is a closed-file SQLite restore exercise and an inspection utility. It is not a production backup/restore screen, browser-storage export, off-device retention service, encrypted archive or physical power-cut test. A matching checkpoint alone does not prove a backup is the latest one. Retained historical audit/hash failures remain blocked and unresolved.

Evidence: `output/inspection/2026-10-10/restore-check.json`, `restored-journal.txt`, `restored-z.csv`; tests in `test/pending_controls_test.dart` and `test/invoice_buyer_footer_test.dart`.

Full regression run: **150 tests passed**, including the interrupted-sale restore check and F&B hardware outage. Final application/test analysis is clean. Release web build passed with the existing Cupertino font warning; served at the canonical local port 8086 (HTTP 200). This batch does not claim a new browser walkthrough or physical hardware test.

## Still pending

Statutory beneficiary identity and eligibility, product classification, applicable tax treatment and supporting reports; final official field/annex acceptance; linked returns/credit notes; real printer original/reprint and failure/retry; operational backup/retention and device replacement; approved registered-business/cloud acceptance; legacy audit investigation. Restaurant is deferred, not marked completed.

Official sources reviewed for the statutory boundary on 10 October: [DA's JAO announcement](https://www.da.gov.ph/gallery/da-dti-doe-jao-signing-march-21-2024/) describes the special BNPC discount without VAT exemption; [BIR RR 5-2017 on the NCDA site](https://ncda.gov.ph/disability-laws/implementing-rules-and-regulations-irr/revenue-regulations-no-5-2017-rules-and-regulations-implementing-republic-act-no-10754/) records separate qualifying PWD benefits and documentation. A generic discount cannot substitute for these distinct eligibility/tax workflows. Current applicability and final approved implementation still require their own review.
