import 'package:flutter/foundation.dart';
import '../../data/models/board_space.dart';
import '../../data/repositories/space_repository.dart';
import '../../data/services/location_service.dart';
import 'explore_space_filter.dart';

class ExploreViewModel extends ChangeNotifier {
  final SpaceRepository _repository;
  final LocationService _locationService;

  ExploreViewModel(this._repository, this._locationService);

  // ── State ──────────────────────────────────────────────────────────────────

  List<BoardSpace> _allSpaces = [];
  String _searchQuery = '';
  ExploreFilter _activeFilter = ExploreFilter.allSpaces;
  bool _isLoading = false;
  String? _error;

  // ── Getters ────────────────────────────────────────────────────────────────

  String get searchQuery => _searchQuery;
  ExploreFilter get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BoardSpace> get spaces {
    List<BoardSpace> result = List.from(_allSpaces);

    // Apply search
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.description.toLowerCase().contains(q) ||
            s.featuredGames.any((g) => g.toLowerCase().contains(q));
      }).toList();
    }

    // Apply filter
    switch (_activeFilter) {
      case ExploreFilter.nearby:
        result.sort((a, b) => a.distanceMi.compareTo(b.distanceMi));
        break;
      case ExploreFilter.topRated:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ExploreFilter.allSpaces:
        break;
    }

    return result;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void onFilterChanged(ExploreFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  Future<void> loadSpaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loc = await _locationService.getCurrentLatLng();
      _allSpaces = await _repository.fetchSpaces(lat: loc?.$1, lng: loc?.$2);
    } catch (e) {
      _error = 'Failed to load spaces. Make sure the backend is running.';
      debugPrint('Error loading spaces: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
