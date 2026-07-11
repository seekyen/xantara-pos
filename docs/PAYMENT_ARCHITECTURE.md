# Xantara POS payment architecture

## Safety rule

An invoice may commit only after it receives validated `PaymentEvidence` whose
captured amount exactly equals the invoice total. The payment record is stored
in the same local database transaction as the invoice, inventory movements,
audit event, and Premium-sync outbox event.

The POS must never treat displaying a QR code, pressing a confirmation button,
or receiving a client-side redirect as proof of payment.

## Offline cash

Cash is fully offline. The local cash gateway validates the tender, calculates
change in integer centavos, and creates a unique local payment reference. After
the invoice transaction commits, the hardware layer may print the invoice and
open the cash drawer.

## Electronic payments

GCash, Maya, bank, and card providers require a configured gateway adapter and
verifiable server/provider authorization. If internet is unavailable, or an
adapter is not configured, checkout fails safely and does not issue an invoice.

A future static-QR/manual-confirmation mode must be treated as a separate risk
decision. It must require explicit merchant configuration, supervisor controls,
reference capture, reconciliation reporting, and acceptance by the selected
payment provider and BIR registration design.

## Provider adapter requirements

- Credentials are stored in platform secure storage, never source code.
- Every request uses the local sale idempotency key.
- Redirect/callback signatures are verified through a trusted backend where the
  provider requires server-held secrets.
- Webhooks and polling are idempotent and cannot create duplicate invoices.
- Provider references, captured amount, timestamps, and final status are retained.
- Sensitive raw payloads are minimized, protected, and excluded from ordinary logs.
- Refunds and reversals create new auditable payment events; captured evidence is
  never overwritten.

## Decisions required before live integration

1. Select the payment service/provider contracts for GCash, Maya, bank, and cards.
   Direct merchant APIs and aggregators have different onboarding and settlement
   requirements.
2. Decide whether static QR/manual confirmation is permitted as a fallback.
3. Define refund authority, partial refund behavior, and reconciliation ownership.
4. Provide sandbox credentials only through approved secret configuration after
   the target backend and production platform are selected.
