import 'package:project/data/models/auth_session.dart';
import 'package:project/data/services/api_client.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<AuthUser> fetchUserProfile() async {
    final response = await _apiClient.get('/users/me');
    final data = response['data'] as Map<String, dynamic>;
    return AuthUser.fromJson(data);
  }
}
