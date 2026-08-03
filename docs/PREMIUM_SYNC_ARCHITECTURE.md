# Xantara POS Premium synchronization architecture

## Product boundary

Standard accounts remain fully functional offline. Their local outbox records
events but no network worker runs. A currently valid Premium entitlement with
sync explicitly enabled is required before any business event leaves the device.

Premium synchronization replicates local records for multi-branch owner
monitoring. It does not become the authority for invoice numbers, completed
sales, local inventory deductions, printing, or cash-drawer operation.

## Reliable upload

Each outbox event includes a permanent idempotency key, business and branch
scope, aggregate identity, event type, creation time, and JSON payload. The sync
processor:

1. Verifies the Premium entitlement at processing time.
2. Claims one event with a time-limited worker lease.
3. Uploads it using the permanent idempotency key.
4. Stores the server acknowledgement without deleting local history.
5. Releases failed events with capped backoff and an operator-visible error.
6. Reclaims leases after an interrupted process or device restart.

Multiple workers cannot actively claim the same event. The cloud endpoint must
also enforce uniqueness on `(businessId, idempotencyKey)` because the device can
lose connectivity after server acceptance but before saving the acknowledgement.

## Server responsibilities

- Authenticate the business, installation, branch, and terminal independently.
- Verify that the entitlement is active server-side; local entitlement alone is
  not sufficient authorization.
- Accept events append-only and return the same acknowledgement for duplicates.
- Preserve original local invoice IDs/numbers and never send renumber commands.
- Build owner dashboards from accepted events with branch and role filtering.
- Detect missing event ranges, clock anomalies, conflicting product versions,
  and terminals using unregistered branch or machine identities.
- Encrypt traffic and stored tenant data and maintain security/audit logs.
- Provide export, retention, backup, incident response, and account-offboarding
  procedures consistent with Philippine tax and data-privacy obligations.

## Multi-branch inventory

Inventory remains a separate balance per branch. The cloud may aggregate and
display balances but must not overwrite a branch from an aggregate total.
Transfers will use paired outbound/inbound ledger events with a shared transfer
ID and explicit receiving confirmation.

## Supplier alerts

`inventory.low_stock` events may feed supplier connectors only after the owner
grants a field- and recipient-specific authorization. Customer, payment, and
unrelated sales details are excluded from supplier notifications.

## Decisions required before connecting a live backend

1. Cloud hosting region, backend stack, and tenant isolation model.
2. Premium pricing, grace period, offline entitlement duration, and cancellation
   behavior.
3. Owner roles and which branch-level information each role may access.
4. Data retention, deletion, and export policy reviewed for BIR and Philippine
   Data Privacy Act obligations.
5. Device enrollment, recovery, revocation, and credential-rotation process.
