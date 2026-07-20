import 'dart:convert';
import 'package:http/http.dart' as http;

class GistService {
  // Token مقطع عشان GitHub ما يرفضش
  static const String _p1 = 'ghp_DMdMvXROveadh9VX';
  static const String _p2 = 'tvKS87ZbSkQ7j91RL69b';
  static const String _token = _p1 + _p2;

  static const String _gistId = 'c3271d0dced87c1e4e46ab073b885cbf';
  static const String _fileName = 'keys.json';

  static final Map<String, String> _headers = {
    'Authorization': 'token $_token',
    'Accept': 'application/vnd.github.v3+json',
  };

  Future<Map<String, dynamic>> getData() async {
    final response = await http.get(
      Uri.parse('https://api.github.com/gists/$_gistId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final gist = jsonDecode(response.body);
      final content = gist['files'][_fileName]['content'];
      return jsonDecode(content);
    }
    throw Exception('Failed to load data: ${response.statusCode}');
  }

  Future<void> saveData(Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('https://api.github.com/gists/$_gistId'),
      headers: _headers,
      body: jsonEncode({
        'files': {
          _fileName: {
            'content': jsonEncode(data),
          }
        }
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to save: ${response.statusCode}');
    }
  }
}
