# Xantara POS multi-branch inventory

## Inventory ownership

The product catalog is shared, but stock balances and reorder points belong to a
specific branch. A cloud dashboard may aggregate balances for an owner, but it
must never replace branch ledgers with one company-wide quantity.

## Transfer lifecycle

Transfers use explicit `inTransit`, `received`, and `cancelled` states:

1. **Dispatch** validates both branches and available source stock, deducts the
   source balance, and writes a `transfer_out` ledger entry.
2. **Receive** is allowed only at the named destination. It credits destination
   stock once and writes the paired `transfer_in` ledger entry.
3. **Cancel** is allowed only by the source while still in transit. It restores
   source stock through a compensating ledger entry and never credits the
   destination.

Every transition is atomic, actor-audited, versioned, and written to the Premium
sync outbox. A failed transition leaves balances, transfer state, audit events,
and outbox events unchanged.

## Offline behavior

A source branch can dispatch offline. The destination can receive only after it
has obtained the transfer record through an approved local import or Premium
sync. Cloud delivery does not change stock by itself; the receiving branch must
explicitly confirm physical receipt.

Duplicate receipt, wrong-branch receipt, same-branch transfer, insufficient
stock, inactive branch, and missing branch-product configuration are rejected.

## Future controls

- Role permissions for dispatch, receipt, cancellation, and discrepancy approval.
- Barcode/QR transfer documents and shipment labels.
- Partial receipt, damaged/missing quantity, and transfer discrepancy workflows.
- Lot, batch, serial number, and expiry tracking for applicable products.
- In-transit aging, branch reconciliation, and owner exception dashboards.
- Physical count adjustments using separate reason-coded ledger entries.
