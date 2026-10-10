# Invoice buyer and supplier particulars

Implemented 8 October 2026. This updates the buyer/heading/preview findings in the [7 October review](INSPECTION_REVIEW_2026-10-07.md); it does not close overall inspection readiness.

## Cashier workflow

Both Food & Beverage and Grocery payment forms include buyer name, TIN and address. Enable **Business purchase** for a business invoice: all three fields are required, regardless of amount. This deliberately avoids an amount-only rule that would omit business-buyer details. For a personal purchase, details are optional; if any are entered, a buyer name and a valid supplied TIN are required. TIN syntax accepts nine digits plus an optional three- or five-digit branch code, with spaces/hyphens. This is format validation, not verification with BIR.

The repository validates buyer information before invoice-number allocation. Invalid submissions leave the sale, stock and serial unchanged. Fields remain populated after a failed save. Buyer data is distinct from the loyalty customer and is not automatically populated from loyalty records. No new plaintext buyer fields were added to the cloud outbox.

The saved F&B preview now uses the same invoice formatter as Grocery, journal text and hardware receipts, reading the committed invoice and payment. It shows stored quantities, unit prices, discounts, taxes, buyer details and change rather than rebuilding these from the cart. The VAT/non-VAT registration heading includes TIN and branch; invoice time is labelled Asia/Manila. Non-VAT output includes the input-tax disclaimer. Anonymous buyers retain blank buyer lines.

## Owner workflow

Settings > Company & terminal > **Invoice supplier particulars** is available to the registered owner. Enter the approved supplier name, address, TIN with five-digit branch code, accreditation number, issue date and validity date; confirm with the owner's password. All supplied fields are validated together and changes are audited. Registered seller/terminal identifiers remain under the existing activation lock. This local supplier configuration is separate from central enrollment and is not cloud-synchronized.

The existing registration's PTU issue date and configured supplier details are captured with every new invoice. Values are never fabricated: installations without supplier configuration still need the owner to enter their approved particulars. Saving configuration is not validation of accreditation or permission to trade. PTU expiry is not inferred from supplier accreditation expiry.

## Persistence and migration

Schema 10 adds explicit SQL tables `invoice_footer_config` and `invoice_particulars`; the latter rejects update/delete. Invoice snapshots are inserted in the sale transaction, before journal capture. Buyer classification and footer data survive reopening and are used by history, queued printing/reprints and journal capture. The issued audit event binds particulars and buyer fields by SHA-256; journal capture checks that binding. Existing journal snapshots are not rewritten.

The migration creates empty tables and does not infer missing historical particulars from current settings. Old invoices therefore do not acquire new supplier details or PTU dates. Updating the owner configuration applies only to later invoices. The legacy fractional-timestamp/hash limitation remains separate and unresolved for affected historical databases.

## Verification and limits

9 October revision 2 supersedes the earlier incomplete browser status below: F&B and Grocery buyer details were verified in downloaded journals after reopening the isolated browser. F&B was on 8 October and Grocery on 9 October; each day's PHP 100 sale reconciled PASS. The queued hardware reprint loader was also tested after database reopen, preserving the original buyer/supplier snapshot with a test printer. Full suite now passes all 145 tests, including the fixed phone inventory layout/save test and migration. Analysis is clean and release web build passes. Physical output remains pending.

Report revision 9 October 2026: the existing user-test PDF now opens with a two-page current update and preserves the previous ten pages as dated evidence. The new isolated browser run reached the F&B saved-sale dialog but failed its buyer-text assertion against page body text; cause remains unconfirmed. Grocery, restart and export checks for this implementation were not completed. Inspect the already committed demo sale before retrying to avoid duplication. This is not a browser pass.

Buyer/footer and checkout tests verify missing-business-field rejection, serial rollback, TIN/control-character validation, persistence after reopen, later supplier edits, immutable snapshots, invalid supplier credentials/data, schema-9 migration, actual F&B widget issuance and exact preview equality, and Grocery failed-save/retry retention. Targeted analysis is clean. Full suite: 139 passed, two failures: the previously recorded phone inventory editor failure and a schema-v3 migration timeout. The migration test subsequently passed in isolation with a two-minute limit (16 seconds actual). Release web build passed with the existing Cupertino font warning.

Physical printing, actual company/permit documents, final official layout acceptance, statutory discounts, returns/credit notes, report completion and recovery remain pending. Widget and browser checks do not establish those outcomes. The test and build logs are under `tmp/invoice-fields-*` and `tmp/invoice-buyer-tests.log`.

## Sources reviewed

- [RMC 77-2024 invoice samples, A1/A2](https://bir-cdn.bir.gov.ph/BIR/pdf/RMC%20No.%2077-2024%20Annex%20A1-B6.pdf): buyer space, registration headings and non-VAT wording. The business-entry rule above is the application's conservative collection policy; personal-buyer applicability still needs final review for the approved deployment.
- [RMO 24-2023, IV(7)(o), page 13](https://bir-cdn.bir.gov.ph/local/pdf/RMO%20No.%2024-2023.pdf): supplier/accreditation and permit particulars.
- [RMC 72-2025 official digest](https://bir-cdn.bir.gov.ph/BIR/pdf/RMC%20No.%2072-2025%20Digest.pdf): supplier accreditation and PTU validity are distinct. This change does not certify current electronic-invoicing applicability or submission deadlines.

## Next business-profile feature

Implemented 9 October: each business profile permits **one** checkout type (F&B or Grocery/Retail; Restaurant remains unavailable). Switching to another type requires switching to its business profile. Separate databases/settings and fresh authentication preserve business boundaries, and unfinished carts block switching. See [Business profiles](BUSINESS_PROFILES.md). Browser checks verified type persistence, wrong-route redirection, new Grocery setup and switch-back login with original records preserved.
