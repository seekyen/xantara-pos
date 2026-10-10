# Isolated recovery rehearsal

The automated demonstration is `test/pending_controls_test.dart`. It uses only synthetic company data and temporary SQLite files. Run `flutter test test/pending_controls_test.dart --timeout 2m`. Set `RECOVERY_EVIDENCE_DIR` to an evidence directory to retain the result JSON, restored journal and CSV; normal tests clean up temporary databases.

For a deployment rehearsal, an authorized operator must identify the business/profile and terminal, stop sales and background writers, and retain a trusted current checkpoint independently of the backup. Record invoice-series and Z high-water values. Keep the original fiscal database and backup untouched.

For native SQLite, use a supported consistent backup procedure; this test uses a fully closed database before copying. Copying only a live `.sqlite` file can miss WAL data. Restore into a new isolated path with cloud and physical hardware disconnected. Do not overwrite the active database. Preserve profile/catalog mapping and the separately scoped settings through an approved credential-handling procedure. The current exercise does not export browser storage or restore device preferences.

Inspect the copy using `RecoveryInspectionRepository.inspect(expected: checkpoint)`, then reconcile its saved Z, invoice counts/tax totals, journal, stock and queues. A mismatch, missing schema trigger, broken audit or reused serial must fail review. Journal export records an export event, so perform the exact checkpoint comparison before any operation that intentionally appends to the restored database.

Do not reconnect an older copy and resume its series merely because its internal records are consistent. Compare with the latest independent source/cloud/printed evidence and prevent two devices from issuing the same terminal's sequence. Production replacement, permitted recovery actions, off-device retention, encryption and final sign-off remain separate acceptance work. This rehearsal never modifies historical hashes or treats a reset as recovery.
