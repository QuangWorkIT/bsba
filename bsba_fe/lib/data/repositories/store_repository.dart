import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/data/models/map_store.dart';
import 'package:project/data/models/staff_store.dart';
import 'package:project/data/services/directions_service.dart';
import 'package:project/data/services/map_service.dart';
import 'package:project/data/services/store_service.dart';

class StoreRepository {
  final MapService _service;
  final DirectionsService _directionsService;
  final StoreService? _storeService;

  StoreRepository(
    this._service, [
    DirectionsService? directionsService,
    StoreService? storeService,
  ]) : _directionsService = directionsService ?? DirectionsService(),
       _storeService = storeService;

  Future<List<MapStore>> fetchNearbyStores({
    required double lat,
    required double lng,
    double radiusKm = 5,
  }) {
    return _service.getNearbyStores(lat: lat, lng: lng, radiusKm: radiusKm);
  }

  Future<List<MapStore>> searchStores(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final batches = await Future.wait([
      _service.searchStores(name: trimmed),
      _service.searchStores(description: trimmed),
      _service.searchStores(address: trimmed),
    ]);

    final byId = <String, MapStore>{};
    for (final batch in batches) {
      for (final store in batch) {
        byId[store.id] = store;
      }
    }

    return byId.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<LatLng>> fetchDrivingRoute({
    required LatLng origin,
    required LatLng destination,
  }) {
    return _directionsService.getDrivingRoute(
      origin: origin,
      destination: destination,
    );
  }

  Future<StaffStore> fetchStoreByStaffId(String staffId) {
    final storeService = _storeService;
    if (storeService == null) {
      throw StateError('StoreService is required to fetch a staff store.');
    }
    return storeService.getStoreByStaffId(staffId);
  }

  Future<StaffStore> updateStaffStore(StaffStoreUpdateRequest request) {
    final storeService = _storeService;
    if (storeService == null) {
      throw StateError('StoreService is required to update a staff store.');
    }
    return storeService.updateStaffStore(request);
  }
}
