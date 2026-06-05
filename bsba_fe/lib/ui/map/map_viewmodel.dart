import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/data/models/map_store.dart';
import 'package:project/data/repositories/store_repository.dart';

class MapViewModel extends ChangeNotifier {
  MapViewModel(this._repository);

  static const LatLng defaultCenter = LatLng(16.0471, 108.2068);
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: defaultCenter,
    zoom: 5.6,
  );
  static const double _defaultRadiusKm = 5;

  final StoreRepository _repository;

  GoogleMapController? _mapController;
  String _query = '';
  MapStore? _selectedStore;
  LatLng? _userLocation;
  List<MapStore> _allStores = [];
  bool _isLoading = false;
  bool _isLocating = false;
  bool _isRouteVisible = false;
  String? _locationError;
  String? _loadError;

  String get query => _query;
  MapStore? get selectedStore => _selectedStore;
  LatLng? get userLocation => _userLocation;
  bool get isLoading => _isLoading;
  bool get isLocating => _isLocating;
  bool get isRouteVisible => _isRouteVisible;
  String? get locationError => _locationError;
  String? get loadError => _loadError;
  bool get hasUserLocation => _userLocation != null;

  List<MapStore> get stores {
    if (_query.trim().isEmpty) return _allStores;

    final q = _query.toLowerCase();
    return _allStores.where((store) {
      return store.name.toLowerCase().contains(q) ||
          store.address.toLowerCase().contains(q) ||
          store.description.toLowerCase().contains(q);
    }).toList();
  }

  List<LatLng> get routePoints {
    final user = _userLocation;
    final store = _selectedStore;
    if (!_isRouteVisible || user == null || store == null) return const [];
    return [user, LatLng(store.latitude, store.longitude)];
  }

  Future<void> load() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final center = await _resolveSearchCenter();
      _allStores = await _repository.fetchNearbyStores(
        lat: center.latitude,
        lng: center.longitude,
        radiusKm: _defaultRadiusKm,
      );
      _selectedStore = _allStores.isEmpty ? null : _allStores.first;
    } catch (e) {
      _loadError =
          'Failed to load nearby stores. Make sure the backend is running.';
      _allStores = [];
      _selectedStore = null;
      debugPrint('Error loading stores: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final store = _selectedStore;
    if (store != null) {
      focusStore(store);
    }
  }

  void onSearchChanged(String query) {
    _query = query;
    _locationError = null;
    final visibleStores = stores;
    if (!visibleStores.contains(_selectedStore)) {
      _selectedStore = visibleStores.isEmpty ? null : visibleStores.first;
      _isRouteVisible = false;
    }
    notifyListeners();
  }

  void submitSearch() {
    final visibleStores = stores;
    if (visibleStores.isEmpty) return;
    selectStore(visibleStores.first);
  }

  void clearSearch() {
    _query = '';
    _selectedStore ??= _allStores.isEmpty ? null : _allStores.first;
    notifyListeners();
  }

  void selectStore(MapStore store) {
    _selectedStore = store;
    _isRouteVisible = false;
    notifyListeners();
    focusStore(store);
  }

  Future<void> focusStore(MapStore store) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(store.latitude, store.longitude), 14),
    );
  }

  Future<void> zoomIn() async {
    final controller = _mapController;
    if (controller == null) return;
    final zoom = await controller.getZoomLevel();
    await controller.animateCamera(CameraUpdate.zoomTo(zoom + 1));
  }

  Future<void> zoomOut() async {
    final controller = _mapController;
    if (controller == null) return;
    final zoom = await controller.getZoomLevel();
    await controller.animateCamera(CameraUpdate.zoomTo(zoom - 1));
  }

  Future<void> locateUser() async {
    if (_isLocating) return;

    _isLocating = true;
    _locationError = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Location services are turned off.';
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _locationError = 'Location permission is required to show your position.';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _userLocation = LatLng(position.latitude, position.longitude);

      await _reloadStoresAt(_userLocation!);

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 14),
      );
    } catch (_) {
      _locationError = 'Could not get your current location.';
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  Future<void> showRouteToSelectedStore() async {
    if (_selectedStore == null) return;
    if (_userLocation == null) {
      await locateUser();
    }
    if (_userLocation == null || _selectedStore == null) return;

    _isRouteVisible = true;
    notifyListeners();
    await _fitRouteBounds();
  }

  String distanceLabelFor(MapStore store) {
    final user = _userLocation;
    if (user != null) {
      final meters = Geolocator.distanceBetween(
        user.latitude,
        user.longitude,
        store.latitude,
        store.longitude,
      );
      return MapStore.formatDistanceKm(meters / 1000);
    }

    final distanceKm = store.distanceKm;
    if (distanceKm != null) {
      return MapStore.formatDistanceKm(distanceKm);
    }

    return '';
  }

  Future<void> _reloadStoresAt(LatLng center) async {
    try {
      _allStores = await _repository.fetchNearbyStores(
        lat: center.latitude,
        lng: center.longitude,
        radiusKm: _defaultRadiusKm,
      );
      _loadError = null;

      final visibleStores = stores;
      if (_selectedStore == null ||
          !visibleStores.any((store) => store.id == _selectedStore!.id)) {
        _selectedStore = visibleStores.isEmpty ? null : visibleStores.first;
        _isRouteVisible = false;
      }
    } catch (e) {
      _loadError =
          'Failed to refresh nearby stores. Make sure the backend is running.';
      debugPrint('Error refreshing stores: $e');
    }
  }

  Future<LatLng> _resolveSearchCenter() async {
    if (_userLocation != null) return _userLocation!;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return defaultCenter;

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return defaultCenter;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
      _userLocation = LatLng(position.latitude, position.longitude);
      return _userLocation!;
    } catch (_) {
      return defaultCenter;
    }
  }

  Future<void> _fitRouteBounds() async {
    final user = _userLocation;
    final store = _selectedStore;
    if (user == null || store == null) return;

    final storePosition = LatLng(store.latitude, store.longitude);
    final bounds = LatLngBounds(
      southwest: LatLng(
        _min(user.latitude, storePosition.latitude),
        _min(user.longitude, storePosition.longitude),
      ),
      northeast: LatLng(
        _max(user.latitude, storePosition.latitude),
        _max(user.longitude, storePosition.longitude),
      ),
    );

    await _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  double _min(double a, double b) => a < b ? a : b;
  double _max(double a, double b) => a > b ? a : b;
}
