import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'current_user.dart';

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
  static const String baseUrl = 'http://192.168.101.114:8080/api/v1';

  // ws://<host>:<port>/ws derived from baseUrl, so there's only one place to edit.
  static final String wsUrl = baseUrl
      .replaceFirst('http', 'ws')
      .replaceFirst('/api/v1', '/ws');

  // Must match the key AuthService persists the JWT under.
  static const String _tokenKey = 'auth_token';

  final http.Client _client = http.Client();

  /// JSON headers + the bearer token when the user is logged in.
  Future<Map<String, String>> _headers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final headers = {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'X-User-Id': CurrentUser.instance.id,
      };
      return headers;
    } catch (e, stackTrace) {
      debugPrint('[API_CLIENT] Exception in _headers: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _headers();
      final response = await _client.get(uri, headers: headers);

      return _handleResponse(response);
    } catch (e, stackTrace) {
      debugPrint('[API_CLIENT] Exception in get($path): $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(String path, dynamic body) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _headers();
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e, stackTrace) {
      debugPrint('[API_CLIENT] Exception in post($path): $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patch(String path, [dynamic body]) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _headers();
      final response = await _client.patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e, stackTrace) {
      debugPrint('[API_CLIENT] Exception in patch($path): $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _headers();
      final response = await _client.delete(uri, headers: headers);

      return _handleResponse(response);
    } catch (e, stackTrace) {
      debugPrint('[API_CLIENT] Exception in delete($path): $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.trim();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return {};
      try {
        final decoded = jsonDecode(body);
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } catch (e, stackTrace) {
        debugPrint('[API_CLIENT] Exception decoding JSON: $e\n$stackTrace');
        return {}; // Or throw if essential
      }
    }

    // Try to pull the backend's ApiResponse.message for a readable error.
    String message = 'Something went wrong. Please try again.';
    if (body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic> && decoded['message'] is String) {
          message = decoded['message'] as String;
        }
      } catch (e) {
        debugPrint('[API_CLIENT] Exception extracting error message: $e');
        // If not JSON, use a generic message or the status code
        message = 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
    } else {
      message = 'Error ${response.statusCode}: Empty response from server';
    }

    debugPrint('[API_CLIENT] Throwing ApiException: $message');
    throw ApiException(response.statusCode, message);
  }
}
