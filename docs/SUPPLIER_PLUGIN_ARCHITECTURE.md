# Xantara POS supplier plugin architecture

## Privacy and authorization boundary

Supplier alerts are separate from financial cloud synchronization. Checkout
only creates a local `inventory.low_stock` event. It never calls a supplier,
sends customer data, or blocks a sale on internet availability.

An alert can leave the device only when all of these are true:

- The owner approved and enabled the connector for the specific branch.
- The owner approved and enabled the specific product subscription.
- The alert field is present in that subscription's explicit allow-list.
- The installed adapter type matches the approved connector.
- The delivery worker has internet access and successfully claims the job.

Supported allow-list fields are branch code, SKU, product name, on-hand stock,
reorder point, and suggested order quantity. Internal invoice IDs, customer,
payment, tax, sales, cost, margin, and unrelated inventory data are never copied
into supplier payloads.

## Durable delivery

Routing is idempotent per `(connector, low-stock event)`. Each minimized alert
is stored as a separate delivery job with a permanent idempotency key. Delivery
uses time-limited leases, acknowledgements, and capped retry backoff. Disabling
a connector immediately prevents queued jobs from being sent.

Secrets are represented in the database only by a secure-storage reference.
API keys, passwords, signing secrets, and tokens must never be stored in the
connector row, source code, logs, or alert payload.

## Adapter contract

A provider adapter receives only the minimized, owner-authorized map. Production
adapters must authenticate the destination, use TLS, apply the job idempotency
key, validate acknowledgements, redact logs, and define timeout/rate-limit
behavior. An adapter may create an alert, purchase request, draft purchase order,
email, webhook, EDI message, or provider-specific request, but it must not place
a legally binding order unless the owner explicitly enables that workflow.

## Decisions required

1. Which supplier companies and integration methods are first: email, webhook,
   API, EDI, or marketplace plugin.
2. Whether alerts create notifications, draft purchase orders, or automatic
   orders. Draft-only is the safest default.
3. Who may approve connectors, fields, suggested quantities, and purchase orders.
4. Whether product cost, preferred supplier, pack size, minimum order quantity,
   and lead time may be shared for particular suppliers.
5. Supplier contract, data-processing, retention, revocation, and incident
   notification requirements.
