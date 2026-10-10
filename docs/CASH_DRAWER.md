# Cash drawer reconciliation

Open POS → Settings → End-of-day reports. Restaurant and Grocery share the
selected terminal's drawer; this is a daily terminal count, not separate shifts.

1. Select the business day and save its opening float (zero is allowed).
2. Record actual cash in, cash out/bank deposits, and cash refund payouts with a
   reason or reference. Correct a mistake through a new offsetting movement with
   an explanation; prior records cannot be edited or deleted.
3. Choose Count drawer and enter the actual cash counted. Explain any shortage
   or overage. A new count supersedes the previous count while preserving history.
4. A manager/owner/admin signs in, reviews the totals and explanation, then uses
   their own password to Review drawer count. Cashiers may record and count but
   cannot review or close; auditors have read-only report access.
5. Refresh and review the report, then complete the existing Z closeout workflow.
   Once tracking has started, closing requires a current reviewed count. A new
   sale, void, cash movement or count invalidates the earlier review.

Expected drawer cash is opening float + cash sales + cash in − cash out − cash
refund payouts. Cash sales use the sale's actual invoice total, excluding tendered
cash that is returned as change. Voiding an invoice does not prove cash was handed
back: an actual refund payout must be recorded separately. References are free
text, not automatic matching to refund authorizations or bank evidence.

CSV, PDF and text report copies include drawer totals and recorded history.
Saved Z contains the drawer snapshot and remains immutable. Exporting or reviewing
does not itself close the day. Older saved reports without drawer records remain
readable. Days without an opening float retain the previous closeout behavior and
are explicitly marked not reconciled; starting with a zero float enables checks.

Database schema v8 adds append-only cash_drawer_events. Every command checks
active staff, branch permissions, displayed event/version freshness and closed-day
status, then commits the cash event and audit together. Older cash-only dates
appear in the open-day selector. Existing invoices and Z records are unchanged by
migration. Passwords are never written into cash records or export files.

Current scope: offline terminal records only; no cloud upload, denomination
counting, per-shift handover, physical drawer sensor integration or automatic
refund verification. Cash movements are employee-entered evidence and should be
reviewed against physical cash and supporting documents.
