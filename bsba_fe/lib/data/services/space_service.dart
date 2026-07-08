import 'package:project/data/models/board_space.dart';
import 'package:project/data/services/api_client.dart';

class SpaceService {
  final ApiClient _apiClient;

  SpaceService(this._apiClient);

  /// GET /api/v1/spaces?lat=..&lng=..&sortBy=..&q=..
  /// Response: { data: { items: [SpaceCardResponse...], ... } }
  Future<List<BoardSpace>> getSpaces({
    double? lat,
    double? lng,
    String sortBy = 'ALL',
    String? q,
    int page = 0,
    int size = 50,
  }) async {
    final params = <String>['sortBy=$sortBy', 'page=$page', 'size=$size'];
    if (lat != null) params.add('lat=$lat');
    if (lng != null) params.add('lng=$lng');
    if (q != null && q.isNotEmpty) {
      params.add('q=${Uri.encodeQueryComponent(q)}');
    }

    final response = await _apiClient.get('/spaces?${params.join('&')}');
    final items = response['data']['items'] as List<dynamic>;

    return items
        .map((json) => BoardSpace.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
