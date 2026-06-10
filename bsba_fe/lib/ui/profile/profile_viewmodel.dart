import 'package:flutter/foundation.dart';
import 'package:project/data/repositories/auth_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/auth_service.dart';
import 'package:project/data/services/current_user.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({AuthRepository? authRepository})
      : _authRepository =
            authRepository ?? AuthRepository(AuthService(ApiClient()));

  final AuthRepository _authRepository;

  bool _isLoggingOut = false;
  String? _errorMessage;

  bool get isLoggingOut => _isLoggingOut;
  String? get errorMessage => _errorMessage;

  Future<bool> logout() async {
    if (_isLoggingOut) return false;

    _errorMessage = null;
    _isLoggingOut = true;
    notifyListeners();

    try {
      await _authRepository.logout();
      CurrentUser.instance.clear();
      _isLoggingOut = false;
      notifyListeners();
      return true;
    } on ApiException catch (error, stackTrace) {
      debugPrint('[ProfileViewModel] ApiException during logout: $error\n$stackTrace');
      _errorMessage = error.message;
    } catch (error, stackTrace) {
      debugPrint('[ProfileViewModel] Unexpected error during logout: $error\n$stackTrace');
      _errorMessage =
          'Unable to reach the server. Check your connection and try again.';
    }

    _isLoggingOut = false;
    notifyListeners();
    return false;
  }
}
