import 'package:flutter/material.dart';
import 'package:project/app/home_screen.dart';
import 'package:project/data/repositories/auth_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/auth_service.dart';
import 'package:project/data/services/current_user.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({AuthRepository? authRepository})
      : _authRepository =
            authRepository ?? AuthRepository(AuthService(ApiClient()));

  final AuthRepository _authRepository;

  String _fullName = '';
  String _phone = '';
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _isHoveringGoogle = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get fullName => _fullName;
  String get phone => _phone;
  String get email => _email;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  bool get isHoveringGoogle => _isHoveringGoogle;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mutators & State Controllers
  void setFullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setHoverGoogle(bool isHovering) {
    _isHoveringGoogle = isHovering;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Core registration action
  Future<bool> register(BuildContext context) async {
    print('RegisterViewModel.register: fullName="$_fullName", phone="$_phone", email="$_email", passwordLength=${_password.length}');
    if (_fullName.trim().isEmpty ||
        _phone.trim().isEmpty ||
        _email.trim().isEmpty ||
        _password.isEmpty) {
      print('RegisterViewModel.register: local validation failed (some fields are empty)');
      return false;
    }

    _errorMessage = null;
    setLoading(true);

    try {
      final session = await _authRepository.register(
        fullName: _fullName.trim(),
        phone: _phone.trim(),
        email: _email.trim(),
        password: _password,
      );

      print('RegisterViewModel.register: success, user id: ${session.user.id}');
      // Make the signed-in user available to the rest of the app
      CurrentUser.instance.setFrom(session.user);

      setLoading(false);

      if (context.mounted) {
        final name = session.user.fullName?.isNotEmpty == true
            ? session.user.fullName!
            : session.user.email;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Welcome, $name! Account created successfully.')),
              ],
            ),
            backgroundColor: const Color(0xFF0056C6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      return true;
    } on ApiException catch (e) {
      print('RegisterViewModel.register: ApiException: $e');
      _errorMessage = e.message;
      setLoading(false);
      if (context.mounted) _showError(context, e.message);
      return false;
    } catch (e) {
      print('RegisterViewModel.register: General error: $e');
      _errorMessage =
          'Unable to reach the server. Check your connection and try again.';
      setLoading(false);
      if (context.mounted) _showError(context, _errorMessage!);
      return false;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Social Sign-In (Stubbed, similar to Login screen)
  Future<void> loginWithSocial(String provider, BuildContext context) async {
    setLoading(true);

    // Simulate API Network call latency
    await Future.delayed(const Duration(milliseconds: 800));

    setLoading(false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                provider == 'Google' ? Icons.g_mobiledata : Icons.apple,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text('Successfully connected with $provider!'),
            ],
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
