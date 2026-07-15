import 'package:flutter/material.dart';
import 'package:project/app/home_screen.dart';
import 'package:project/data/repositories/auth_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/auth_service.dart';
import 'package:project/data/services/current_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({AuthRepository? authRepository})
      : _authRepository =
            authRepository ?? AuthRepository(AuthService(ApiClient()));

  final AuthRepository _authRepository;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: dotenv.env['GOOGLE_CLIENT_ID'],
  );

  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isHoveringGoogle = false;
  bool _isHoveringApple = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get email => _email;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  bool get isHoveringGoogle => _isHoveringGoogle;
  bool get isHoveringApple => _isHoveringApple;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

    _errorMessage = null;
    setLoading(true);

    // Demo bypass: "test" / "test" navigates straight into the app
    // without hitting the backend.
    if (_email.trim() == 'test' && _password == 'test') {
      CurrentUser.instance.clear();
      setLoading(false);
      if (context.mounted) {
        _navigateToHome(context);
      }
      return true;
    }

    try {
      final session = await _authRepository.login(
        emailOrPhone: _email.trim(),
        password: _password,
      );

      // Make the signed-in user available to the rest of the app (chat, inbox…).
      CurrentUser.instance.setFrom(session.user);

      setLoading(false);

      if (context.mounted) {
        _showWelcomeAndNavigate(
          context,
          session.user.fullName,
          session.user.email,
        );
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      setLoading(false);
      if (context.mounted) _showError(context, e.message);
      return false;
    } catch (_) {
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

  // Core business action: Social Sign-In
  Future<bool> loginWithSocial(String provider, BuildContext context) async {
    if (provider == 'Google') {
      _errorMessage = null;
      setLoading(true);
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          setLoading(false);
          return false; // User cancelled
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final String? idToken = googleAuth.idToken;

        if (idToken == null) {
          throw Exception('Failed to obtain Google ID Token.');
        }

        print('Google Sign-In: obtained ID Token. Sending to backend...');
        final session = await _authRepository.loginWithGoogle(idToken);
        CurrentUser.instance.setFrom(session.user);
        setLoading(false);

        if (context.mounted) {
          _showWelcomeAndNavigate(
            context,
            session.user.fullName,
            session.user.email,
          );
        }
        return true;
      } catch (e) {
        print('Google Sign-in failed: $e');
        _errorMessage = e.toString();
        setLoading(false);
        if (context.mounted) _showError(context, 'Google Sign-in failed: $e');
        return false;
      }
    }

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
    return true;
  }

  void _showWelcomeAndNavigate(
    BuildContext context,
    String? fullName,
    String email,
  ) {
    final name = fullName?.isNotEmpty == true ? fullName! : email;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Welcome back, $name!')),
          ],
        ),
        backgroundColor: const Color(0xFF0056C6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    _navigateToHome(context);
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}
