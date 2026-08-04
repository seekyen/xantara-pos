import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens the browser-side SQLite database backing [AppDatabase], using
/// drift's WASM executor. Requires web/sqlite3.wasm and web/drift_worker.js
/// (downloaded from the sqlite3.dart and drift GitHub releases matching the
/// pinned package versions) to be present.
Future<QueryExecutor> openAppDatabaseExecutor() async {
  final result = await WasmDatabase.open(
    databaseName: 'xantara_pos',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return result.resolvedExecutor;
}
