import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the on-device SQLite file backing [AppDatabase]. Desktop/mobile only
/// (Windows/macOS/Linux/Android/iOS) — see database_connection_web.dart for
/// the browser counterpart, selected via database_connection.dart.
Future<QueryExecutor> openAppDatabaseExecutor() async {
  final directory = await getApplicationSupportDirectory();
  final file = File(p.join(directory.path, 'xantara_pos.sqlite'));
  return NativeDatabase.createInBackground(file);
}
