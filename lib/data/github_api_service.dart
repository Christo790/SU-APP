import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GitHubApiService {
  GitHubApiService._();

  static final String _baseUrl =
      dotenv.env['GITHUB_API_BASE_URL'] ??
      'https://api.github.com/repos/christo790/su-notes/contents';
  static final String _token = dotenv.env['GITHUB_API_TOKEN'] ?? '';

  static Map<String, String> get _headers => {
    if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
    'Accept': 'application/vnd.github+json',
  };

  static Future<List<dynamic>> fetchContents(String path) async {
    final uri = Uri.parse('$_baseUrl/$path');
    final response = await http.get(uri, headers: _headers);

    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body) as List<dynamic>;
      case 403:
        throw Exception('API rate limit exceeded. Try again later.');
      case 404:
        throw Exception('Path not found: $path');
      default:
        throw Exception('Unexpected error: ${response.statusCode}');
    }
  }
}
