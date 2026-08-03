# Xantara POS audit integrity

## Per-branch hash chain

Every financially or inventory-material event receives a monotonically
increasing sequence within its branch. Each event stores:

- The previous event hash, or the fixed genesis hash for sequence 1
- Actor, terminal, event, entity, timestamp, and exact JSON payload
- A SHA-256 hash over length-prefixed canonical fields

Sales, invoice voids, invoice reprints, and inventory transfer transitions use
this audit service inside the same local transaction as their business records.
The chain verifier detects changed content, changed identity or timestamps,
missing middle events, reordered events, and invalid previous hashes.

Branches have independent sequences and genesis links so offline operation at
one branch does not depend on another branch or a cloud counter.

## Important boundary

A local hash chain is tamper-evident, not tamper-proof. A privileged attacker
who can rewrite the entire database could recompute all local hashes, and deleting
only the newest tail cannot be detected without an external checkpoint.

Premium synchronization should therefore anchor accepted branch checkpoints on
the server, containing branch ID, last sequence, last hash, terminal identity,
and acceptance timestamp. Standard/offline installations should support signed
checkpoint exports to protected removable media or another owner-controlled
location. BIR audit exports must include both events and checkpoint evidence.

## Operational controls still required

- Restrict direct database access and encrypt the database at rest.
- Sign released application builds and record the registered software version.
- Verify audit chains at startup, before Z-reading, before export, and after restore.
- Surface integrity failures prominently and prevent silent repair or deletion.
- Back up audit data under the applicable retention policy.
- Require privileged, individually identified users for voids, reprints,
  adjustments, transfer cancellation, connector approval, and configuration.
- Document incident handling and BIR notification/escalation procedures with a
  Philippine tax professional before production accreditation.
