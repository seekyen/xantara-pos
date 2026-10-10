# Business profiles

Implemented 9 October 2026. Each local business profile has one fixed checkout type: Food & Beverage or Grocery / Retail. Restaurant remains unavailable. Use Settings > business profile, or the profile tile on the sign-in/setup screen, to switch businesses.

## Existing installations

The existing company and training databases keep their original names (`xantara_company` and `xantara_pos`). Schema 11 adds an immutable singleton checkout-type table; it does not split, move or rewrite historical sales. The owner must select the existing profile's type once and authenticate with the owner password. Prior mixed F&B/Grocery history stays in the same legacy database. Cashiers cannot assign a type. Until assignment, the running application blocks checkout.

The database enforces type immutability with update/delete triggers. Both checkout requests identify their type, and the sale repository rejects a mismatch before changing invoices, stock or serials. Navigation also redirects a direct URL for the wrong checkout to the assigned type.

## Creating and switching

After choosing the current business's type, its authenticated owner can create a named profile and select that new business's type. Creation requires the current owner's password. The new profile has a separate UUID-named database and starts at company/terminal registration; existing employees, inventory, permits, invoice numbers and sales are not copied. Register and activate it with its own approved identity before trading.

Switching opens and validates the destination before disposing the current ProviderScope and closing its database. The new scope starts unauthenticated. Staff must sign in using the destination's own credentials and branch permissions. A catalog in device preferences remembers available profiles and the last selection. A failed destination open does not dispose the current business. Failed creation can leave an empty profile available for setup; no existing profile is deleted.

Both checkout carts block switching until finished or explicitly cleared. Cloud sync in progress also blocks switching. Customer-display content is reset on a normal profile switch. Local settings, cloud sessions, sync target and cached branch choice use separate store prefixes; biometric credentials are scoped by profile. Enrollment's device-level completion guard remains global so another profile cannot reuse an already-enrolled terminal's installation identity.

## Boundaries and verification

Profiles are local to this device/browser, not centrally managed cloud accounts. Each business still needs its own valid company/terminal identity and matching cloud business enrollment. Device display preferences are shared. Profile names are visible on the sign-in selector; selecting a name does not authenticate staff or expose its sales. There is no profile deletion, fiscal-record transfer or checkout-type conversion action.

Tests cover persistent catalog selection and isolated settings; legacy schema-10 migration/reopen preserving company and next serial; password rejection and one-time owner assignment; mismatched or missing checkout type rejection before sale mutation; immutable types; separate database identity/records; and both unfinished-cart guards. Existing invoice tests also exercise persisted buyer/footer data through the actual queued reprint loader with a test printer. Physical output remains unverified. See the current report for final test and browser results.

Final verification: 145 tests passed (`tmp/profiles-full-tests-final.log`); application/test analysis and final bootstrap analysis clean; final release web build passed. Isolated browser test persisted the F&B type across restart, redirected a Grocery URL to F&B, created a distinct Grocery profile at its setup gate, switched back with fresh login, and re-exported the original F&B invoice with reconciliation PASS. No new registered-company setup, cloud enrollment or physical print acceptance is claimed. Logs: `tmp/uat-cash-drawer/profiles-browser.log` and `profiles-return-journal.txt`.
