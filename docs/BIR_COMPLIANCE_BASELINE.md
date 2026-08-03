# Xantara POS - BIR compliance baseline

This document is an engineering control list, not a claim of BIR approval.
Formal use requires the taxpayer, branches, terminals, software version, and
applicable machines to complete the current BIR registration/accreditation and
Permit to Use processes.

## Controls the product must enforce

- Issue an **Invoice**, not an Official Receipt, as the primary sales document.
- Preserve an immutable invoice serial once issued. Voids, returns, discounts,
  and reprints must create auditable events; they must not delete or renumber the
  original sale.
- Use a separate registered serial range for each branch/terminal where required.
- Store money as integer centavos and preserve VAT, zero-rated, VAT-exempt, and
  non-VAT totals separately.
- Capture registered seller name, address, TIN and branch code, MIN, PTU number,
  machine serial, and registered software name/version for printed invoices and
  audit exports as applicable.
- Capture quantity, unit price, description, discounts, totals, invoice date/time,
  and buyer details when required or requested.
- Generate an electronic sales journal and per-terminal X/Z readings from the
  append-only transaction journal.
- Disable production training/no-sale modes. Any future training environment must
  be isolated from production data and clearly mark documents as non-invoices.
- Mark duplicate invoice output as `REPRINT ONLY` and log reprint date/time and user.
- Retain records for the legally required period and support BIR audit extraction.
- Never provide a feature that suppresses, overwrites, or silently deletes sales.
- Record every financially material software release because major enhancements
  may require a BIR registration update and minor changes may require notice.

## Offline-first invariants

1. A completed sale is committed locally before the UI reports success.
2. Invoice numbering never depends on internet access and never changes during sync.
3. Inventory and accounting changes are written in the same local transaction as
   the sale or reversal.
4. Cloud synchronization is an optional Premium replication layer, not the system
   of record for an offline terminal.
5. Every sync mutation carries business, branch, terminal, entity, version, and
   idempotency identifiers. Conflicts never rewrite issued financial documents.
6. Supplier alerts expose only explicitly authorized inventory data.

## Registration information still needed

Before production invoice generation can be enabled for a customer, collect and
validate their registered name, TIN, branch code, registered address, VAT status,
RDO, MIN, PTU, registered machine serial, approved invoice serial starting point,
software registration/accreditation details, and retention/export requirements.

## Primary references checked

- BIR RR No. 7-2024 and RR No. 11-2024 (EOPT invoicing changes)
- BIR RMC No. 77-2024 (invoicing clarification)
- BIR RMO No. 9-2021 (CAS/CBA/system registration and records)
- BIR RMO No. 15-2018 (POS post-evaluation, e-journal, Z-reading, PTU)

These requirements must be rechecked against current BIR issuances before every
production accreditation or material financial release.
