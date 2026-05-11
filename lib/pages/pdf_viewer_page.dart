import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:su/core/constants/app_colors.dart';

class PdfViewerPage extends StatelessWidget {
  final File   file;
  final String title;

  const PdfViewerPage({super.key, required this.file, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(title),
      ),
      body: PDFView(filePath: file.path),
    );
  }
}
