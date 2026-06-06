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

  Future<List<MapStore>> searchStores({
    String? name,
    String? description,
    String? address,
  }) async {
    final params = <String, String>{};
    if (name != null && name.trim().isNotEmpty) {
      params['name'] = name.trim();
    }
    if (description != null && description.trim().isNotEmpty) {
      params['description'] = description.trim();
    }
    if (address != null && address.trim().isNotEmpty) {
      params['address'] = address.trim();
    }

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');

    final response = await _apiClient.get(
      query.isEmpty ? '/map/search' : '/map/search?$query',
    );

    final List<dynamic> data = response['data'] ?? [];
    return data
        .map((json) => MapStore.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
