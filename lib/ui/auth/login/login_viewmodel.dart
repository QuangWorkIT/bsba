import 'package:flutter/material.dart';
import 'package:project/app/home_screen.dart';
import 'package:project/data/models/login_credentials.dart';

class LoginViewModel extends ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isHoveringGoogle = false;
  bool _isHoveringApple = false;
  bool _isLoading = false;

  // Getters
  String get email => _email;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  bool get isHoveringGoogle => _isHoveringGoogle;
  bool get isHoveringApple => _isHoveringApple;
  bool get isLoading => _isLoading;

  // Mutators & State Controllers
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

  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  void setHoverGoogle(bool isHovering) {
    _isHoveringGoogle = isHovering;
    notifyListeners();
  }

  void setHoverApple(bool isHovering) {
    _isHoveringApple = isHovering;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Core business action: Normal Login
  Future<bool> login(BuildContext context) async {
    if (_email.trim().isEmpty || _password.isEmpty) {
      return false;
    }

    setLoading(true);

    // Create the credentials model representation
    final credentials = LoginCredentials(
      emailOrPhone: _email,
      password: _password,
      rememberMe: _rememberMe,
    );

    // Simulate API Network call latency
    await Future.delayed(const Duration(seconds: 1));
    
    setLoading(false);

    // Demo bypass: "test" / "test" navigates straight into the app
    if (_email.trim() == 'test' && _password == 'test') {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      return true;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text('Welcome back! Successfully logged in as ${credentials.emailOrPhone}'),
            ],
          ),
          backgroundColor: const Color(0xFF0056C6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    return true;
  }

  // Core business action: Social Sign-In
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
