import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

void openPdfNative(BuildContext context, Uint8List bytes, String name) async {
  final dir  = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(bytes);

  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(name)),
        body: PDFView(filePath: file.path),
      ),
    ),
  );
}