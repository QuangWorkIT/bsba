import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/data/models/map_store.dart';
import 'package:project/data/repositories/store_repository.dart';

class MapViewModel extends ChangeNotifier {
  MapViewModel(this._repository);

  static const LatLng defaultCenter = LatLng(10.843948, 106.816394);
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: defaultCenter,
    zoom: 14.0,
  );
  static const double _defaultRadiusKm = 5;

  final StoreRepository _repository;

  GoogleMapController? _mapController;
  String _query = '';
  MapStore? _selectedStore;
  LatLng? _userLocation;
  List<MapStore> _allStores = [];
  List<MapStore> _searchResults = [];
  Timer? _searchDebounce;
  bool _searchCommitted = false;
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isLocating = false;
  bool _isRouteVisible = false;
  bool _isLoadingRoute = false;
  List<LatLng> _routePoints = const [];
  String? _locationError;
  String? _loadError;
  String? _routeError;

  String get query => _query;
  MapStore? get selectedStore => _selectedStore;
  LatLng? get userLocation => _userLocation;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isLocating => _isLocating;
  bool get isRouteVisible => _isRouteVisible;
  bool get isLoadingRoute => _isLoadingRoute;
  String? get locationError => _locationError;
  String? get loadError => _loadError;
  String? get routeError => _routeError;
  bool get hasUserLocation => _userLocation != null;
  List<MapStore> get searchResults => _searchResults;
  bool get showSearchSuggestions =>
      _query.trim().isNotEmpty && !_searchCommitted;
  bool get showStoreDetails => _selectedStore != null && !showSearchSuggestions;

  List<MapStore> get stores {
    if (_query.trim().isEmpty) return _allStores;
    return _searchResults;
  }

  List<LatLng> get routePoints => _isRouteVisible ? _routePoints : const [];

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
    _searchCommitted = false;
    _locationError = null;
    _searchDebounce?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      _syncSelectionWithVisibleStores();
      notifyListeners();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(trimmed);
    });
    notifyListeners();
  }

  void submitSearch() {
    _searchDebounce?.cancel();
    final trimmed = _query.trim();
    if (trimmed.isEmpty) return;

    if (!_isSearching && _searchResults.isNotEmpty) {
      selectSearchResult(_searchResults.first);
      return;
    }

    _performSearch(trimmed, selectFirstResult: true);
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    _query = '';
    _searchResults = [];
    _isSearching = false;
    _searchCommitted = false;
    _selectedStore ??= _allStores.isEmpty ? null : _allStores.first;
    notifyListeners();

    final store = _selectedStore;
    if (store != null) {
      focusStore(store);
    }
  }

  void selectSearchResult(MapStore store) {
    _searchCommitted = true;
    _query = store.name;
    _selectedStore = store;
    _clearRoute();
    notifyListeners();
    focusStore(store);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void selectStore(MapStore store) {
    _selectedStore = store;
    _clearRoute();
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
      final position = await _readDevicePosition();
      if (position == null) return;

      _userLocation = LatLng(position.latitude, position.longitude);

      if (position.isMocked) {
        _locationError =
            'Using a simulated GPS location. On an emulator, open '
            'Extended Controls > Location and set your Vietnam coordinates, '
            'or test on a physical device.';
      }

      await _reloadStoresAt(_userLocation!);

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 14),
      );
    } catch (e) {
      _locationError = 'Could not get your current location.';
      debugPrint('Error locating user: $e');
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  Future<void> showRouteToSelectedStore() async {
    if (_selectedStore == null || _isLoadingRoute) return;
    if (_userLocation == null) {
      await locateUser();
    }

    final user = _userLocation;
    final store = _selectedStore;
    if (user == null || store == null) return;

    _isLoadingRoute = true;
    _routeError = null;
    _clearRoute();
    notifyListeners();

    try {
      _routePoints = await _repository.fetchDrivingRoute(
        origin: user,
        destination: LatLng(store.latitude, store.longitude),
      );
      _isRouteVisible = true;
      notifyListeners();
      await _fitRouteBounds();
    } catch (e) {
      _clearRoute();
      _routeError = _routeErrorMessageFor(e);
      debugPrint('Error loading route: $e');
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
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

      _syncSelectionWithVisibleStores();
    } catch (e) {
      _loadError =
          'Failed to refresh nearby stores. Make sure the backend is running.';
      debugPrint('Error refreshing stores: $e');
    }
  }

  Future<LatLng> _resolveSearchCenter() async {
    if (_userLocation != null) return _userLocation!;
    return defaultCenter;
  }

  Future<Position?> _readDevicePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationError = 'Location services are turned off.';
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _locationError = 'Location permission is required to show your position.';
      return null;
    }

    final settings = _locationSettings();
    final position = await Geolocator.getCurrentPosition(
      locationSettings: settings,
    );

    debugPrint(
      'Device location: ${position.latitude}, ${position.longitude} '
      '(accuracy: ${position.accuracy}m, mocked: ${position.isMocked})',
    );

    return position;
  }

  LocationSettings _locationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        timeLimit: const Duration(seconds: 15),
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        timeLimit: const Duration(seconds: 15),
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
      timeLimit: Duration(seconds: 15),
    );
  }

  Future<void> _fitRouteBounds() async {
    if (_routePoints.length < 2) return;

    var minLat = _routePoints.first.latitude;
    var maxLat = minLat;
    var minLng = _routePoints.first.longitude;
    var maxLng = minLng;

    for (final point in _routePoints) {
      minLat = _min(minLat, point.latitude);
      maxLat = _max(maxLat, point.latitude);
      minLng = _min(minLng, point.longitude);
      maxLng = _max(maxLng, point.longitude);
    }

    if (minLat == maxLat && minLng == maxLng) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_routePoints.first, 14),
      );
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    } catch (e) {
      debugPrint('Could not fit route bounds: $e');
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_routePoints.first, 14),
      );
    }
  }

  String _routeErrorMessageFor(Object error) {
    final message = error.toString();
    if (message.contains('Billing') || message.contains('REQUEST_DENIED')) {
      return 'Google Directions requires billing on your Cloud project. '
          'Routing will use the backend/OSRM fallback when available.';
    }
    if (message.contains('Backend returned') ||
        message.contains('API Error') ||
        message.contains('All routing providers failed')) {
      return 'Could not load driving directions. Make sure the backend is running.';
    }
    return 'Could not load driving directions.';
  }

  void _clearRoute() {
    _isRouteVisible = false;
    _routePoints = const [];
    _routeError = null;
  }

  double _min(double a, double b) => a < b ? a : b;
  double _max(double a, double b) => a > b ? a : b;

  Future<void> _performSearch(
    String query, {
    bool selectFirstResult = false,
  }) async {
    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _repository.searchStores(query);
      if (selectFirstResult && _searchResults.isNotEmpty) {
        selectSearchResult(_searchResults.first);
      }
    } catch (e) {
      _searchResults = [];
      debugPrint('Error searching stores: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void _syncSelectionWithVisibleStores() {
    final visibleStores = stores;
    if (!visibleStores.contains(_selectedStore)) {
      _selectedStore = visibleStores.isEmpty ? null : visibleStores.first;
      _clearRoute();
    }
  }
}
