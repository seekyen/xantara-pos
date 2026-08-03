import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the on-device SQLite file backing [AppDatabase]. Desktop/mobile only
/// (Windows/macOS/Linux/Android/iOS), matching CLAUDE.md's supported targets
/// — web needs a separate wasm-backed executor that isn't set up.
Future<QueryExecutor> openAppDatabaseExecutor() async {
  final directory = await getApplicationSupportDirectory();
  final file = File(p.join(directory.path, 'xantara_pos.sqlite'));
  return NativeDatabase.createInBackground(file);
}
