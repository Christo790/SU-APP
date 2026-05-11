import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:http/http.dart' as http;

class CodeViewerPage extends StatefulWidget {
  final String fileName;
  final String rawUrl;

  const CodeViewerPage({
    super.key,
    required this.fileName,
    required this.rawUrl,
  });

  @override
  State<CodeViewerPage> createState() => _CodeViewerPageState();
}

class _CodeViewerPageState extends State<CodeViewerPage> {
  String  _code    = '';
  bool    _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCode();
  }

  Future<void> _fetchCode() async {
    try {
      final response = await http.get(Uri.parse(widget.rawUrl));
      setState(() {
        _loading = false;
        if (response.statusCode == 200) {
          _code = response.body;
        } else {
          _error = 'Failed to load file (${response.statusCode})';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Network error: $e';
      });
    }
  }

  static String _detectLanguage(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    const map = {
      'cpp': 'cpp', 'c': 'cpp', 'java': 'java',
      'py': 'python', 'js': 'javascript',
      'html': 'html', 'css': 'css',
    };
    return map[ext] ?? 'plaintext';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1e1e1e),
      appBar: AppBar(
        backgroundColor: const Color(0xff1e1e1e),
        foregroundColor: Colors.white,
        title: Text(widget.fileName),
      ),
      body: Builder(builder: (_) {
        if (_loading) return const Center(child: CircularProgressIndicator());
        if (_error != null) {
          return Center(
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: HighlightView(
            _code,
            language: _detectLanguage(widget.fileName),
            theme: vs2015Theme,
            padding: const EdgeInsets.all(12),
            textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          ),
        );
      }),
    );
  }
}
