import 'package:project/data/models/map_store.dart';
import 'package:project/data/services/map_service.dart';

class StoreRepository {
  final MapService _service;

  StoreRepository(this._service);

  Future<List<MapStore>> fetchNearbyStores({
    required double lat,
    required double lng,
    double radiusKm = 5,
  }) {
    return _service.getNearbyStores(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
    );
  }
}
