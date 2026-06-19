import 'package:project/data/services/api_client.dart';

/// Reads the online-users snapshot from the backend. Live changes after this
/// come over the `/topic/presence` socket topic (see [PresenceViewModel]).
class PresenceService {
  final ApiClient _apiClient;

  PresenceService(this._apiClient);

  /// GET /api/v1/presence → list of user ids currently connected.
  Future<Set<String>> fetchOnlineUserIds() async {
    final response = await _apiClient.get('/presence');
    final list = response['data'] as List<dynamic>? ?? const [];
    return list.map((e) => e.toString()).toSet();
  }
}
