import 'package:flutter/foundation.dart';
import 'package:project/data/models/auth_session.dart';
import 'package:project/data/services/api_client.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<AuthUser> fetchUserProfile() async {
    debugPrint('[USER_SERVICE] fetchUserProfile() called');
    try {
      final response = await _apiClient.get('/users/me');
      
      final data = response['data'] as Map<String, dynamic>;
      
      final user = AuthUser.fromJson(data);
      
      debugPrint('[USER_SERVICE] fetchUserProfile() successfully completed');
      return user;
    } catch (e, stackTrace) {
      debugPrint('[USER_SERVICE] Exception in fetchUserProfile: $e\n$stackTrace');
      rethrow;
    }
  }
}
