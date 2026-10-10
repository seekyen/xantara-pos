// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

Future<String> saveReport(String filename, String csv) async {
  final blob = html.Blob(
      [utf8.encode(csv)],
      filename.endsWith('.txt')
          ? 'text/plain;charset=utf-8'
          : 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final link = html.AnchorElement(href: url)..download = filename;
  html.document.body!.append(link);
  link.click();
  link.remove();
  Future<void>.delayed(
      const Duration(seconds: 30), () => html.Url.revokeObjectUrl(url));
  return 'Download requested. Check your browser downloads.';
}
