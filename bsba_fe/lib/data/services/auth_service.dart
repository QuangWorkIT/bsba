import 'package:shared_preferences/shared_preferences.dart';

import 'package:project/data/models/auth_session.dart';
import 'package:project/data/services/api_client.dart';

/// Talks to the backend auth endpoints (`/api/v1/auth/*`) and persists the
/// resulting JWT so it survives app restarts.
class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;

  static const String _tokenKey = 'auth_token';
  static const String _userEmailKey = 'auth_user_email';

  /// POST /auth/login — returns the session on success, throws [ApiException]
  /// (with the backend message) on failure.
  Future<AuthSession> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await _apiClient.post('/auth/login', {
      'emailOrPhone': emailOrPhone,
      'password': password,
    });

    final data = response['data'] as Map<String, dynamic>;
    final session = AuthSession.fromJson(data);

    await _persistSession(session);
    return session;
  }

  Future<AuthSession> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String otpCode,
  }) async {
    final response = await _apiClient.post('/auth/register', {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'otpCode': otpCode,
    });

    final data = response['data'] as Map<String, dynamic>;
    final session = AuthSession.fromJson(data);

    await _persistSession(session);
    return session;
  }

  Future<void> sendRegistrationOtp(String email) async {
    await _apiClient.post('/auth/register/send-otp', {
      'email': email,
    });
  }

  Future<AuthSession> loginWithGoogle(String idToken) async {
    final response = await _apiClient.post('/auth/google', {
      'idToken': idToken,
    });

    final data = response['data'] as Map<String, dynamic>;
    final session = AuthSession.fromJson(data);

    await _persistSession(session);
    return session;
  }

  Future<void> _persistSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, session.token);
    await prefs.setString(_userEmailKey, session.user.email);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    await _apiClient.post('/auth/logout', {});
    await clearSession();
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userEmailKey);
  }
}
