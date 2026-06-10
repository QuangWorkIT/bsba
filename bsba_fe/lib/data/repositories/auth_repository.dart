import 'package:project/data/models/auth_session.dart';
import 'package:project/data/services/auth_service.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<AuthSession> login({
    required String emailOrPhone,
    required String password,
  }) {
    return _service.login(emailOrPhone: emailOrPhone, password: password);
  }

  Future<AuthSession> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String otpCode,
  }) {
    return _service.register(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
      otpCode: otpCode,
    );
  }

  Future<void> sendRegistrationOtp(String email) {
    return _service.sendRegistrationOtp(email);
  }

  Future<AuthSession> loginWithGoogle(String idToken) {
    return _service.loginWithGoogle(idToken);
  }

  Future<String?> currentToken() => _service.getToken();

  Future<void> logout() => _service.clearSession();
}
