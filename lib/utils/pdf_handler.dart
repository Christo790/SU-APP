import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'pdf_viewer_android.dart'
    if (dart.library.html) 'pdf_viewer_stub.dart';

Future<void> openPdf(BuildContext context, String url, String name) async {
  if (kIsWeb) {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } else {
    final response = await http.get(Uri.parse(url));
    if (!context.mounted) return;
    openPdfNative(context, response.bodyBytes, name);
  }
}