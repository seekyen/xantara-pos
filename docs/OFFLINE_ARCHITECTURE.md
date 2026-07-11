# Xantara POS offline transaction architecture

## Local source of truth

Every terminal writes completed sales to its local Drift/SQLite database. The
cloud is not required to log in locally, browse the catalog, check stock, issue
an invoice, accept a locally supported tender, print, open the drawer, void a
transaction, or produce local audit reports.

The sale transaction commits these records atomically:

1. The immutable invoice and invoice lines.
2. The next branch/terminal invoice serial.
3. The branch-specific inventory balance and inventory movement ledger.
4. The append-only actor audit event.
5. The idempotent Premium synchronization outbox event.
6. A low-stock outbox event when the branch reorder threshold is reached.

If any operation fails, all six operations roll back. The UI must only show
`Payment successful` after this transaction commits.

Voiding preserves the original invoice number, values, and line items. It
marks the invoice void, restores stock through compensating inventory ledger
entries, and adds audit/outbox events in one transaction. Duplicate voids are
rejected.

The local reporting repository derives the terminal electronic sales journal
and X/Z-reading data from this immutable invoice history. Readings include the
beginning and ending invoice numbers, gross sales, void totals, net sales, tax
breakdowns, transaction counts, and payment-method totals.

## Premium synchronization

The outbox is populated for all installations so upgrading to Premium never
requires reconstructing financial history. Only an active Premium entitlement
starts the uploader. Upload behavior must follow these rules:

- Use the outbox `idempotencyKey` so retries cannot create duplicate sales.
- Upload in creation order, but do not block new local transactions.
- Mark `syncedAt` only after the server durably acknowledges the event.
- Use capped exponential retry and preserve rejected events for operator review.
- Never allow the server to renumber, edit, or delete an issued local invoice.
- Treat product/catalog updates as versioned data and surface conflicts.
- Keep branch inventory separate; owner dashboards aggregate server-side.

## Supplier plugin boundary

Checkout only records `inventory.low_stock` locally. A separately authorized
integration worker decides whether to notify a supplier. Each plugin must have
an explicit allow-list for branches, products, fields, recipients, and delivery
channels. Supplier integrations never receive customer, payment, invoice, or
other unrelated business data.

## Remaining implementation gates

- Select the first production platforms and add encrypted file-backed database
  initialization for each platform.
- Connect the existing checkout UI to `OfflineSaleRepository`.
- Add partial return/credit-note transactions where required by the final BIR
  registration design.
- Render, export, and print X/Z readings and the electronic sales journal.
- Add Premium entitlement and authenticated outbox transport.
- Add supplier connector interfaces and consent/configuration screens.
- Add printer and cash-drawer adapters with device certification tests.
