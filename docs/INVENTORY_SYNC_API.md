# Xantara inventory synchronization API v1

This is the upload-side interoperability boundary between the offline-first
Flutter client and the existing Xantara cloud application. The cloud stores
immutable device events and projects the supported sale, void, and transfer
events into the mapped legacy branch inventory.

## Upload an event

`POST /api/v1/sync/events/`

Required headers:

- `Authorization: Bearer <short-lived access token>`
- `Idempotency-Key: <permanent event key>`
- `X-Xantara-Installation-Id: <registered installation ID>`
- `X-Xantara-Terminal-Id: <registered terminal ID>`
- `Content-Type: application/json`

Request body:

```json
{
  "schemaVersion": 1,
  "localEventId": "event-1",
  "businessId": "business-1",
  "branchId": "branch-1",
  "aggregateType": "inventory",
  "aggregateId": "product-1",
  "eventType": "inventory.adjusted",
  "idempotencyKey": "inventory.adjusted:event-1",
  "payload": {
    "productId": "product-1",
    "quantityDelta": -2
  },
  "createdAt": "2026-08-21T10:30:00.000Z"
}
```

Successful response (`200`, `201`, or `202`):

```json
{
  "serverEventId": "server-event-1",
  "acceptedAt": "2026-08-21T10:30:01.000Z",
  "inventoryProjected": false
}
```

Re-uploading the same `(businessId, idempotencyKey)` must return the original
acknowledgement and must not apply inventory twice.

## Server validation

Before accepting an event, the server must:

1. Validate the token and derive the authenticated business from it.
2. Verify the installation, terminal, and branch are active and belong to that
   business.
3. Reject a body `businessId` or `branchId` that conflicts with the authenticated
   identities.
4. Verify that cloud synchronization is enabled for the account.
5. Enforce a unique database constraint on `(businessId, idempotencyKey)`.
6. Store the original event append-only and apply supported projections in the
   same database transaction.
7. Reject unknown schema versions. Unknown event types remain append-only and
   return `inventoryProjected: false`; they do not mutate stock.

Supported inventory projections are `invoice.issued`, `invoice.voided`,
`inventory.transfer_dispatched`, `inventory.transfer_received`, and
`inventory.transfer_cancelled`. Their branch and integer-quantity payloads are
validated inside the same transaction as event acceptance. Missing products,
unmapped branches, insufficient stock, duplicate voids, or malformed payloads
roll back both the event and the stock change.

Do not place a permanent API secret in a Flutter web build. Browser clients
must obtain short-lived credentials through an authenticated enrollment or
login flow.

## Next increment

Add authenticated Flutter enrollment/login and a manual queue-drain action,
then add a cursor-based pull endpoint for catalog and branch-inventory changes.
The pull protocol needs explicit version and conflict rules before it is
allowed to update local stock.
