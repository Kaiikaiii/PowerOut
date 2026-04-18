import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://lime-weasel-672604.hostingersite.com';
  static const Duration _timeout = Duration(seconds: 15);

  static Future<Map<String, dynamic>> signup(
    String username,
    String email,
    String password,
  ) {
    return _postJson(
      path: '/signup.php',
      body: <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
      },
    );
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) {
    return _postJson(
      path: '/login.php',
      body: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );
  }

  static Future<Map<String, dynamic>> _postJson({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http
          .post(
            uri,
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final decoded = _safeJsonDecode(response.body);
      if (decoded != null) {
        return decoded;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return <String, dynamic>{
          'success': true,
          'message': 'Request completed.',
        };
      }

      return <String, dynamic>{
        'success': false,
        'message': 'Server returned status ${response.statusCode}.',
      };
    } catch (_) {
      return <String, dynamic>{
        'success': false,
        'message': 'Unable to connect to server. Check internet/API URL.',
      };
    }
  }

  static Map<String, dynamic>? _safeJsonDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}