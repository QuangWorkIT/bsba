import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Thrown on a non-2xx response. [message] carries the backend's
/// `ApiResponse.message` when present, so screens can show a friendly reason.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl = 'http://10.0.101.8:8080/api/v1';

  // ws://<host>:<port>/ws derived from baseUrl, so there's only one place to edit.
  static final String wsUrl = baseUrl
      .replaceFirst('http', 'ws')
      .replaceFirst('/api/v1', '/ws');

  // Must match the key AuthService persists the JWT under.
  static const String _tokenKey = 'auth_token';

  final http.Client _client = http.Client();

  /// JSON headers + the bearer token when the user is logged in.
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, dynamic body) async {
    print('--- ApiClient POST Request ---');
    print('Url: $baseUrl$path');
    print('Body: ${jsonEncode(body)}');
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-----------------------------');
      return _handleResponse(response);
    } catch (e) {
      print('ApiClient POST Error: $e');
      print('-----------------------------');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patch(String path, [dynamic body]) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    // Try to pull the backend's ApiResponse.message for a readable error.
    String message = 'Something went wrong. Please try again.';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        message = decoded['message'] as String;
      }
    } catch (_) {
      // Body wasn't JSON; keep the default message.
    }
    throw ApiException(response.statusCode, message);
  }
}
