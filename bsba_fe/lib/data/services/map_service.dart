import 'package:project/data/models/map_store.dart';
import 'package:project/data/services/api_client.dart';

class MapService {
  final ApiClient _apiClient;

  MapService(this._apiClient);

  Future<List<MapStore>> getNearbyStores({
    required double lat,
    required double lng,
    double radiusKm = 5,
  }) async {
    final response = await _apiClient.get(
      '/map/nearby?lat=$lat&lng=$lng&radiusKm=$radiusKm',
    );

    final List<dynamic> data = response['data'] ?? [];
    return data
        .map((json) => MapStore.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
