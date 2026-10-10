# Permanent grocery checkout

Grocery cash checkout now issues invoices through `OfflineSaleRepository`, the same durable path used by Restaurant/F&B. Available in demo and activated company workspaces. Existing registration and staff/branch checks remain enforced.

Confirming cash payment atomically saves the invoice and lines, payment evidence, invoice sequence increment, branch stock deduction and movement, audit entry, sync outbox event, and receipt/drawer jobs. Saved grocery invoices appear in the existing Orders/history and reporting sources. There is no per-session grocery receipt counter anymore.

The receipt preview uses the committed invoice, registered seller and terminal metadata, stored tax breakdown and payment evidence. Print copy produces a PDF marked REPRINT ONLY. Physical printer integration, audited PDF-copy tracking and complete statutory invoice layout remain separate work; receipt/drawer jobs remain in the durable queue for hardware processing. Printing failure never retries or reverses a saved sale.

Basket totals use integer centavos (round each unit price before multiplying quantity). Ordinary custom discounts are rounded once and allocated proportionally across invoice lines, with the allocated total matching exactly. Tax is computed by the shared invoice engine from saved product tax categories. Stale prices, inactive/missing products, insufficient stock/cash, invalid discounts and missing registration prevent the transaction from committing. The cart is retained after failure and cleared only after success. Duplicate clicks and function keys cannot open competing payment dialogs or issue concurrent duplicate sales.

Cash is the only enabled payment method. Typed card/e-wallet references no longer count as payment verification. The unfinished Senior/PWD calculation is disabled. Demo coupons are rejected for registered-company sales. Grocery loyalty selection, statutory discounts, X readings and saved Z closeouts are not implemented by this change.

Verification includes database close/reopen persistence, all saved financial records and queues, duplicate submissions, stock/price/payment failure rollback, centavo allocation across VAT/exempt items, registered seller identity, and the payment UI preserving the cart after failure and clearing it once after a successful retry.
