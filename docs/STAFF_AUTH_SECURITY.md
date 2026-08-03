# Xantara POS staff authentication and authorization

## Offline credentials

Production staff passwords are stored as unique salted PBKDF2-HMAC-SHA256
digests, never plaintext or reversible encryption. The production default is
600,000 iterations with a 128-bit salt and 256-bit derived key. Algorithm, salt,
and work factor are stored per account so parameters can be upgraded after a
successful login.

Single-factor passwords require at least 15 characters, permit long passphrases,
and do not impose arbitrary character-composition rules. Shorter activation
secrets must not be enabled unless they are part of a properly designed
multi-factor/biometric flow. New passwords are checked against an offline local
blocklist; production enrollment should use a maintained compromised/common
password dataset without transmitting the password.

Five consecutive failures cause a 15-minute local lock. Both values are
configurable, and login failures persist even though authentication fails.
Account recovery must require an individually authenticated owner/admin process;
there is no shared master PIN or security-question fallback.

## Roles and branch scope

Supported roles are owner, admin, manager, cashier, inventory clerk, and auditor.
Permissions cover sales, voids, reprints, inventory, transfers, supplier
connectors, reports, settings, staff, and Premium monitoring. Permission alone
is insufficient: the staff member must also be explicitly assigned to the branch.

Cashiers can create sales and view stock but cannot void invoices. Managers can
void/reprint and manage branch operations but cannot manage staff, global
settings, supplier connectors, or Premium ownership. Auditors are read-only.
Owner/admin permissions remain branch-scoped unless access to that branch is
explicitly granted.

Staff creation and branch grants are written to the tamper-evident branch audit
chain. Future changes to roles, access, activation, and credentials must also be
audited without storing secret material.

## Migration boundary

The existing Flutter demo `auth_provider.dart` still contains sample accounts,
and legacy screens still use a demonstration shared void code. They must be
removed when the application bootstrap is connected to the file-backed database.
Until that integration is complete, the demo login and supervisor dialogs are
not approved for production use.

## References and remaining controls

- NIST SP 800-63B-4 password length, blocklist, salted hashing, and throttling
- OWASP Password Storage Cheat Sheet work-factor guidance

Production work still requires secure database encryption/keys, an owner
enrollment ceremony, password recovery, session timeout/lock-screen behavior,
biometric binding, protected input, full blocklist updates, and penetration
testing on the selected Windows/Android hardware.
