import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiClient {
  static String get baseUrl => ApiConfig.restBaseUrl;

  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client.get(Uri.parse('$baseUrl$path'));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, dynamic body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(String path, [dynamic body]) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} ${response.body}');
    }
  }
}
