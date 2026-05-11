import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfDownloader {
  PdfDownloader._();

  static Future<File> download(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF: ${response.statusCode}');
    }
    final dir  = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }
}