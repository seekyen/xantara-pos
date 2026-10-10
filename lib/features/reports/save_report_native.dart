import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> saveReport(String filename, String csv) async {
  final directory =
      await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  await directory.create(recursive: true);
  final file = File('${directory.path}${Platform.pathSeparator}$filename');
  await file.writeAsString(csv, flush: true);
  return 'Saved to ${file.path}';
}
