import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../database.dart';
import 'audit_trail_repository.dart';

/// An independently retained checkpoint of a quiescent database. Keep it away
/// from the backup being checked. It is evidence, not authorization to resume
/// an old invoice series on a second device.
class RecoveryCheckpoint {
  const RecoveryCheckpoint(this.schemaVersion, this.tables, this.schemaHash);
  final int schemaVersion;
  final Map<String, String> tables;
  final String schemaHash;
}

class RecoveryInspectionRepository {
  RecoveryInspectionRepository(this.db);
  final AppDatabase db;

  Future<RecoveryCheckpoint> checkpoint() => db.transaction(() async {
        final rows = await db
            .customSelect(
                "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name")
            .get();
        final hashes = <String, String>{};
        for (final row in rows) {
          final name = row.read<String>('name');
          // Identifiers originate in SQLite metadata, not a user-supplied path.
          final escaped = name.replaceAll('"', '""');
          final contents =
              await db.customSelect('SELECT * FROM "$escaped"').get();
          final encoded = contents.map((r) {
            final keys = r.data.keys.toList()..sort();
            return jsonEncode({for (final key in keys) key: r.data[key]});
          }).toList()
            ..sort();
          hashes[name] =
              sha256.convert(utf8.encode(jsonEncode(encoded))).toString();
        }
        final version =
            await db.customSelect('PRAGMA user_version').getSingle();
        final schema = await db
            .customSelect(
                "SELECT type,name,sql FROM sqlite_master WHERE name NOT LIKE 'sqlite_%' ORDER BY type,name")
            .get();
        return RecoveryCheckpoint(
            version.data.values.single as int,
            Map.unmodifiable(hashes),
            sha256
                .convert(
                    utf8.encode(jsonEncode(schema.map((r) => r.data).toList())))
                .toString());
      });

  /// Read-only checks. Passing means the copy matches the supplied checkpoint,
  /// not that it is the latest backup or safe to reconnect to production.
  Future<List<String>> inspect({required RecoveryCheckpoint expected}) =>
      db.transaction(() async {
        final failures = <String>[];
        final integrity = await db.customSelect('PRAGMA integrity_check').get();
        if (integrity.length != 1 ||
            integrity.single.data.values.single != 'ok') {
          failures.add('SQLite integrity check failed.');
        }
        if ((await db.customSelect('PRAGMA foreign_key_check').get())
            .isNotEmpty) {
          failures.add('Foreign-key integrity check failed.');
        }
        final actual = await checkpoint();
        if (actual.schemaVersion != expected.schemaVersion) {
          failures.add('Schema version differs from the checkpoint.');
        }
        if (actual.schemaHash != expected.schemaHash) {
          failures.add(
              'Schema definitions or integrity triggers differ from the checkpoint.');
        }
        for (final name in {...expected.tables.keys, ...actual.tables.keys}) {
          if (actual.tables[name] != expected.tables[name]) {
            failures.add('Restored table differs from checkpoint: $name.');
          }
        }
        for (final branch in await db.select(db.branches).get()) {
          final audit = await AuditTrailRepository(db).verifyBranch(branch.id);
          if (!audit.isValid) {
            failures.add(
                'Audit verification failed for ${branch.id} at record ${audit.brokenSequence}.');
          }
        }
        final sequences = await db.select(db.invoiceSequences).get();
        final invoices = await db.select(db.invoices).get();
        if (invoices
            .any((i) => !sequences.any((s) => s.terminalId == i.terminalId))) {
          failures.add('An invoiced terminal has no invoice sequence.');
        }
        for (final sequence in sequences) {
          final issued =
              invoices.where((i) => i.terminalId == sequence.terminalId);
          if (issued.any((i) {
            final serial = int.tryParse(i.invoiceNumber.split('-').last);
            return serial == null || serial >= sequence.nextValue;
          })) {
            failures.add(
                'Next invoice number would reuse an issued serial for ${sequence.terminalId}.');
          }
        }
        return failures;
      });
}
