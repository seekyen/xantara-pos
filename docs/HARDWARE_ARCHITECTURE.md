# Xantara POS printing and cash-drawer architecture

## Durable jobs

Receipt printing and cash-drawer operations are local hardware jobs stored in
SQLite. A cash sale transaction queues the original invoice print and drawer
operation in the same commit as the invoice, payment, inventory, audit, and sync
records. Device failure never rolls back or duplicates the financial sale.

Jobs move through `queued`, `processing`, `completed`, and `failed` states. A
failed operation uses capped backoff. An operation interrupted by an app restart
is re-queued with the same job ID so an adapter that supports idempotency can
avoid duplicate output.

## Invoice content

The receipt formatter currently produces printer-neutral text containing:

- VAT Invoice or Non-VAT Invoice title
- Registered seller name, address, TIN, and branch code
- Invoice number and issue timestamp
- MIN, PTU, machine serial, and registered software version
- Item description, quantity, unit price, discounts, and line totals
- VATable, VAT, zero-rated, VAT-exempt, and non-VAT breakdowns
- Payment method/reference, cash tender, and change
- Buyer details when captured
- Void status/reason when applicable

Reprints are marked `REPRINT ONLY`, include the reprint timestamp, and create an
actor audit event. Reprinting does not create a new invoice or serial.

## Driver boundary

`ReceiptPrinterAdapter` and `CashDrawerAdapter` isolate device-specific code.
Production adapters must be selected and tested against the actual hardware:

- ESC/POS network, USB, Bluetooth, or platform print spooler
- Printer paper width and character encoding
- Drawer pulse through an ESC/POS printer or dedicated USB/serial interface
- Paper-out, cover-open, disconnected, and permission errors
- Idempotency behavior after an uncertain device response

The worker must start only after the local database is open. UI status should
show pending/failed jobs and provide an authorized retry action. Drawer retries
need particular care because many drawers cannot confirm whether a pulse was
physically executed.

## Decisions required

1. First production platform: Windows, Android, or both.
2. Supported printer brands/models, connection types, and paper widths.
3. Whether the drawer connects through the receipt printer or directly.
4. Whether original invoices print automatically or only on customer request,
   subject to the final BIR-approved operating procedure.
