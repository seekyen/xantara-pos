# Xantara POS - BIR pre-assessment package

Prepared 10 October 2026 for a preliminary discussion with the responsible Revenue District Office or other BIR office. This is a request for classification and requirements confirmation. It is not an application, sworn statement, accreditation certificate, Permit to Use, or representation that Xantara POS has been approved by the BIR.

## 1. Requested outcome

Please confirm in writing:

1. The applicable registration/accreditation route for Xantara POS: supplier/developer POS software, taxpayer-developed or pseudo-supplier POS, CAS component/other invoicing software, standalone POS, POS with server, or another classification.
2. Which office receives the application and which current forms, annexes, demonstrations and technical documents apply.
3. Whether separate accreditation, registration or PTU action is required for each software version, taxpayer, branch, terminal, platform, printer model or checkout type.
4. The invoice, credit-note, X/Z, electronic-journal, monthly eSales and structured electronic-invoice requirements applicable to the intended taxpayer.

## 2. Applicant and taxpayer information to complete

- Developer/supplier legal name, TIN, address, RDO and authorized representative
- Business model: internal taxpayer-developed system, distributed software, subscription, or other
- Pilot taxpayer legal/trade name, TIN/branch code, registered address, RDO and VAT status
- Head office, branches, terminals and intended MIN/PTU arrangement
- Intended platforms, printer models, paper widths and cash-drawer connection
- Taxpayer classification, e-commerce/LTS/RBE/export status and electronic-invoicing applicability

Do not submit fictional registration particulars as real. The current engineering evidence uses controlled test data.

## 3. Proposed product classification and architecture

Xantara POS is an offline-first point-of-sale application. Each registered business profile uses an isolated local SQLite database. A sale is committed locally before success is shown. Invoice numbering does not depend on internet access. Inventory, payment, invoice, audit, journal, hardware queue and synchronization evidence are committed in the same transaction. Optional cloud synchronization carries business, branch, terminal, entity, version and idempotency identifiers; it does not renumber issued documents.

The current proposed release supports Food & Beverage and Grocery/Retail. Restaurant is deferred. Cash is the accepted fiscal settlement in the verified scope. The application contains owner/manager/cashier/auditor roles, immutable invoice and credit-note documents, invoice/CN/Z sequences, X/Z readings, cash-drawer reconciliation, electronic journal, statutory beneficiary support and append-only audit evidence.

## 4. Proposed frozen release scope

Included:

- VAT and non-VAT cash invoices
- Buyer details when supplied or required
- Original and authorized `REPRINT ONLY` output
- Voids preserving the original invoice
- Linked partial/full cash credit notes, with optional sellable-stock restoration
- X and Z readings and cumulative totals
- Daily electronic journal and CSV operational reports
- Scoped Senior/PWD food-service and Grocery BNPC workflows
- Offline operation, durable hardware jobs and optional cloud replication

Excluded or pending:

- Restaurant, reservations, kitchen routing and split/partial restaurant payments
- Card/e-wallet refunds, loyalty reversals and cross-terminal returns
- Physical printer/cash-drawer certification and target-device acceptance
- Representative/group/bulk, medicine, LPG/kerosene and benefit-versus-promotion cases
- Production backup/retention and registered-device replacement approval
- Final eSales/EIS format, certification and transmission
- Formal BIR field/layout/annex acceptance

## 5. Fiscal document controls

Invoice output currently includes seller registered name/address, VAT status, TIN/branch, invoice title, serial, Manila transaction date/time, cashier, MIN, PTU, machine serial, software/version, buyer fields, item description/quantity/unit price, discounts, VAT relief, totals, VATable/VAT/zero-rated/exempt/non-VAT breakdown, payment/reference and tender/change. Non-VAT output carries the input-tax warning. Training output is clearly marked. Reprints retain the original serial and are marked `REPRINT ONLY` with a reprint timestamp.

Credit notes use a separate CN sequence and identify the original invoice, issue date/business day, reason, operator, supervisor, returned quantities, restock decisions, cash refund and tax/discount/VAT-relief reversals. The original invoice remains unchanged.

X/Z readings identify taxpayer, branch, terminal, MIN/PTU/serial, business date, operator, invoice range/counts, gross/discount/sales/void/credit/net totals, tax classes, statutory totals, cash reconciliation and cumulative net. A saved Z is immutable.

## 6. Field and output review matrix

| Output | Implemented engineering evidence | Confirmation requested |
|---|---|---|
| VAT/non-VAT invoice | Seller, buyer, serial/date, line, tax and payment fields | Final labels, ordering, footer, paper and taxpayer-specific requirements |
| Reprint | Same invoice; `REPRINT ONLY`; actor/time audit | Required duplicate wording and treatment after uncertain printer outcome |
| Void | Original preserved; reason/actor/time; adjustment-day reports | Required customer document and reporting treatment |
| Credit note | Separate CN series; original link; line/tax/refund evidence | Required title, numbering, content, signatures and eSales/EIS treatment |
| X reading | Current non-closing totals and cash state | Required fields, accumulator definitions and print/export form |
| Z reading | Immutable closeout, invoice range, cumulative net | Required reset/accumulator behavior and retention |
| Electronic journal | Supported full documents/events with reconciliation | Required file structure, naming, period, media and inspection access |
| Beneficiary register | Authorized internal CSV with invoice/benefit evidence | Official book/report format and retention requirements |
| Monthly sales | Internal totals can reconcile per terminal/MIN | Current eSales file, submission and correction requirements |
| Structured invoice data | Outbox contains structured invoice/line/tax evidence | Current RR 11-2025/RR 26-2025/RMC 98-2026 schema, certification and transmission |

## 7. Registration and evidence inventory

Prepared or available:

- System architecture and control descriptions
- Test documentation: 170 Flutter tests and 22 matching backend sync tests at the current engineering checkpoint
- Interactive device/printer acceptance pack with 12 scenarios
- Fictional sample invoices, X/Z, journal and recovery evidence from prior engineering reviews
- Work checklist and known-limitations register

Still required for a formal submission:

- Applicant/taxpayer registration records and authorized representative documents
- Confirmed current application form, sworn statement and annex checklist
- Frozen release build, version, source identifier and checksums
- Actual approved seller/MIN/PTU/accreditation particulars
- Target hardware specification/brochure and physical sample outputs
- Final system description/design, user/technical/installation/operations manuals
- Controlled inspection or master-access procedure
- Production backup, retention, recovery and terminal replacement procedure
- Final eSales/EIS structured data and certification/transmission evidence, if applicable
- Completed demonstration record and signed acceptance evidence

## 8. Security, integrity and operations

Implemented controls include role/branch authorization, manager approval for sensitive actions, immutable fiscal documents, transaction rollback, audit hash chains, per-terminal sequences, idempotent sync keys and read-only reconciliation. Passwords are not included in fiscal exports.

Before final review, document beneficiary-ID minimization/access/retention; encrypted off-device backup; restore authorization; lost-device response; terminal retirement/replacement; administrator inspection access; dependency/secret review; incident response; production monitoring; and release/change notification. Historical audit failures in retained legacy test databases must be disclosed rather than rewritten.

## 9. Electronic reporting questions

The package relies on current official materials stating that invoices are the primary sales document, POS/PTU and CAS/components have registration processes, POS machines report monthly sales per MIN through eSales, and covered systems may need structured electronic invoice data and transmission readiness. Applicability depends on taxpayer/system classification and later rules.

Request confirmation of:

- Whether this offline-first POS must register through eAccReg, CAS registration, both, or another route
- Whether RR 11-2025 as amended by RR 26-2025 applies immediately to the pilot taxpayer
- Required structured invoice schema and whether certification/Permit to Transmit applies
- Interaction among monthly eSales, EIS/electronic sales reporting and local X/Z/journal records
- Treatment of offline issuance followed by later transmission
- Correction/rejection/retransmission and contingency procedures

## 10. Questions for the meeting

1. What is Xantara's correct classification and responsible processing office?
2. May one accredited version support both F&B and Grocery/Retail, or are separate models/configurations required?
3. What constitutes a major enhancement requiring reaccreditation versus a minor change requiring notice?
4. What records and credentials must an examiner be able to access, and how should access be controlled?
5. What invoice/footer fields and exact labels apply after RR 7-2024 and later issuances?
6. What is the required credit-note title, serial scheme, printed content and reporting treatment?
7. What X/Z fields, grand-total accumulators and reset controls are required?
8. What electronic-journal format, naming, media, retention and extraction method are required?
9. What monthly eSales file/submission applies, and how are returns/credit notes reported?
10. What structured electronic-invoice/EIS obligations apply to this taxpayer and POS architecture?
11. Are separate PTUs/MINs required per terminal, platform, printer model, branch and database profile?
12. Which Senior/PWD details belong on the invoice versus a separate supporting record?
13. What retention, backup, disaster recovery and terminal-replacement evidence is required?
14. Which forms, annexes, manuals, samples, brochures and demonstration scripts must accompany the formal filing?
15. Can BIR provide or confirm an official written checklist for this case?

## 11. Requested written meeting record

Record the BIR office, date, attending officials, taxpayer/applicant representatives, classification decision, forms/annexes, required changes, electronic-reporting decision, hardware/sample requirements, responsible next action and target follow-up. Attach or reference written guidance. Verbal guidance should be documented and confirmed before implementation is treated as final.

## Official sources reviewed

- BIR RR 7-2024: https://bir-cdn.bir.gov.ph/BIR/pdf/RR%20No.%207-%202024.pdf
- BIR RMO 24-2023 listing and annexes: https://www.bir.gov.ph/2023-Revenue-Memorandum-Order
- BIR registration requirements: https://www.bir.gov.ph/registration-requirements-details
- BIR eAccReg portal: https://eaccreg.bir.gov.ph/ACCREG/help.html
- BIR eSales: https://www.bir.gov.ph/esales
- BIR RR 11-2025: https://bir-cdn.bir.gov.ph/BIR/pdf/RR%2011-2025.pdf
- BIR RR 26-2025 digest: https://bir-cdn.bir.gov.ph/BIR/pdf/RR%20No.%2026-2025%20Digest.pdf
- BIR 2026 RMC listing, including RMC 98-2026: https://www.bir.gov.ph/2026-Revenue-Memorandum-Circulars?label=2026&type=PAGE

Recheck all sources, forms and office instructions immediately before filing. The responsible BIR office determines applicability and acceptance.
