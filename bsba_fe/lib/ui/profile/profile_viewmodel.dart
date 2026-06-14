import 'package:flutter/foundation.dart';
import 'package:project/data/models/auth_session.dart';
import 'package:project/data/repositories/auth_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/auth_service.dart';
import 'package:project/data/services/current_user.dart';
import 'package:project/data/services/user_service.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    AuthRepository? authRepository,
    UserService? userService,
  })  : _authRepository = authRepository ?? AuthRepository(AuthService(ApiClient())),
        _userService = userService ?? UserService(ApiClient()) {
    fetchProfile();
  }

  final AuthRepository _authRepository;
  final UserService _userService;

  bool _isLoggingOut = false;
  String? _errorMessage;

  bool _isLoadingProfile = false;
  AuthUser? _user;

  bool get isLoggingOut => _isLoggingOut;
  String? get errorMessage => _errorMessage;
  bool get isLoadingProfile => _isLoadingProfile;
  AuthUser? get user => _user;

  Future<void> fetchProfile() async {
    _isLoadingProfile = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.fetchUserProfile();
    } catch (e) {
      debugPrint('[ProfileViewModel] Error fetching profile: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

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
