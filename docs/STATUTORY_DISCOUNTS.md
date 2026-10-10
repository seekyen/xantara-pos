# Senior / PWD checkout — 10 October 2026

The F&B and Grocery/Retail checkouts now support a scoped, offline beneficiary workflow. Restaurant remains deferred. This is an engineering implementation, not final statutory-output or inspection acceptance.

## Operator workflow

1. The owner opens **Settings → Senior / PWD settings**, reviews business coverage and product eligibility, classifies the catalog, and enables the applicable scheme with their own credentials. New installations and upgraded profiles start with both schemes disabled. Unclassified items block benefit checkout; excluded items remain at their ordinary tax and price treatment.
2. At cash payment, choose **Senior / PWD benefit**. Record the beneficiary name, proof type and ID number. Confirm that valid entitlement was checked and that this is one beneficiary's in-person, exclusive-consumption purchase. Buyer invoice fields and loyalty identity remain separate.
3. Grocery additionally records prior eligible purchases and actual discounts from the booklet across all stores and both IDs when applicable. Confirm four qualifying kinds when using the full weekly purchase allowance. Record the successful purchase in the booklet.
4. Review the recalculated amount, enter cash and confirm. A failed save retains the basket. The receipt shows the beneficiary, discount and VAT removed separately. The committed invoice remains the source for later display and reprints.
5. Use **Senior / PWD settings → Download beneficiary sales CSV** for a selected Philippine business date and terminal. It contains sensitive beneficiary identification; access follows the existing branch and reading permissions. It is an internal supporting register, not an official filing format.

## Calculation and evidence

Food service uses a 20% discount on qualifying lines after applicable VAT removal. A VAT-inclusive PHP112.00 line becomes PHP100.00 before discount, PHP20.00 discount and PHP80.00 due; VAT relief is PHP12.00. Non-VAT lines have no VAT removal. Mixed baskets keep nonqualifying lines unchanged.

BNPC applies 5% while retaining the product's original tax category. It enforces both the PHP2,500 weekly eligible-purchase limit and PHP125 actual-discount limit. The implementation uses Sunday–Saturday in UTC+8, observes booklet evidence, and remembers the highest previously declared total plus that sale's allowance usage. Changing ID punctuation/case cannot bypass the local check. A void does not automatically restore booklet allowance. Actual cross-store and dual-ID verification still depends on operator evidence; there is no central beneficiary registry.

Amounts are integer centavos. Food VAT removal and discount round half-up per line. BNPC rounds once on the eligible basis and distributes discount with the existing stable largest-remainder allocator. The repository recomputes the benefit inside the sale transaction and rejects stacked discounts, stale payment amounts, stale prices, disabled schemes and mismatched checkout types before fiscal mutation.

Schema 12 adds `statutory_policy` and `statutory_product_classes`. Existing invoice tables and historical documents are preserved. Catalog classification is bound to product ID, SKU, name and tax category; identity changes require review, while price-only changes keep classification. Owner changes are audited. Product origin/composition cannot be inferred from a name and must be reviewed by the owner.

Per-sale evidence and VAT relief live in immutable `invoice_particulars`, covered by the existing issue-event particulars hash. Line totals subtract discount and VAT relief separately. Ordinary line discount fields never include VAT relief. Invoice assembly, receipt rendering, durable hardware loading and journal capture restore this evidence. Outbox payloads include the benefit snapshot and per-line VAT relief; cloud report/acceptance testing remains separate.

X/Z and CSV include benefit-kind/scheme discount and VAT-relief totals, net of void events on their posting day. Existing gross means amount due plus actual discount, now labelled **after VAT relief**. New journal checks reconcile statutory line arithmetic and benefit totals against current readings and saved Z. Old snapshots remain readable. The separate beneficiary CSV reports invoices by issue date and includes their current void status, so it is not a posting-day adjustment ledger.

## Supported scope and remaining work

This version supports one personally present beneficiary with identifiable personal items and ordinary prices. Representative purchases, shared/group allocation, bulk/MEMC handling, medicine workflows, LPG/kerosene periodic limits, and promotion-versus-benefit comparison require additional workflows. The app does not decide legal entitlement automatically. These cases must not be described as fully implemented.

Business exemptions and the detailed BNPC product list require owner review. Physical printing, signed-in browser acceptance, cloud-side statutory reporting, official annex/layout approval, retention and historical audit investigation remain open. [Linked cash credit notes](CREDIT_NOTES.md) now support proportional discount/VAT-relief reversals; exceptional settlements remain pending. No real business was enabled, sold to, or closed out for this work. Prior PDF inspection reports remain dated historical artifacts.

## Sources reviewed

- [BIR RR 5-2017, NCDA copy](https://ncda.gov.ph/disability-laws/implementing-rules-and-regulations-irr/revenue-regulations-no-5-2017-rules-and-regulations-implementing-republic-act-no-10754/): qualifying PWD purchases, VAT/discount computation, separate sales records and non-stacking.
- [BIR RR 7-2010, Supreme Court index](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/10/55830) and [Cavite City published clarifications](https://cavitecity.gov.ph/index.php/34-osca/196-question-and-answers-further-clarifying-the-provision-of-revenue-regulation-rr-no-7-2010): senior food-service scope and exclusive consumption. These do not establish acceptance of this software.
- [DTI–DA–DOE JAO 24-02 (2024), NCDA PDF](https://ncda.gov.ph/wp-content/uploads/2024/04/JAO-DTI-DA-DOE-No.-240-02-S2024.pdf): distinct BNPC scheme, coverage, evidence and limits.
- [DSWD older discount FAQ](https://dswd.gov.ph/download/senior_citizens/frequently_asked_questions_on_the_5%25_senior_citizens_discount/srcitizenbooklet_11_07_070001.pdf): Sunday–Saturday calendar-week convention only; its old monetary limit is superseded by the 2024 order.

## Verification

Source checkpoint: `tmp/statutory-work/before.zip` with hash/base commit in `checkpoint.txt`. Tests cover arithmetic, mixed tax, caps and rounding, evidence rejection, owner/report permissions, stale booklet declarations, atomic failure, schema-11 migration, restart, receipt, X/Z, journal, later void, and both cashier forms (including Grocery phone width).

Full regression: **163 passed**. Final checkout regression after selector refinement: **9 passed**. Final `flutter analyze --no-pub lib test`: no issues. Release web build passed with the existing Cupertino-font warning. Verification logs are under `tmp/statutory-work/`. No browser walkthrough or physical printer acceptance was performed.
