import 'package:flutter/foundation.dart';
import '../../data/models/board_space.dart';
import 'explore_space_filter.dart';

class ExploreViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

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
      // TODO: Replace with real repository call.
      await Future.delayed(const Duration(milliseconds: 600));
      // Data is already seeded in _allSpaces below.
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Seed data (replace with repository later) ──────────────────────────────

  final List<BoardSpace> _allSpaces = const [
    BoardSpace(
      id: '1',
      name: 'The Strategy Hub',
      address: '12 Nguyen Hue, District 1',
      distanceMi: 0.8,
      rating: 4.9,
      imageUrl:
      'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=800&q=80',
      description:
      'Premium large tables. Featuring Twilight Imperium, Scythe, and Terraforming Mars.',
      availableSlots: ['18:00', '19:30', '21:00'],
      featuredGames: ['Twilight Imperium', 'Scythe', 'Terraforming Mars'],
      pricePerHour: 120000,
    ),
    BoardSpace(
      id: '2',
      name: "Dungeon Master's Den",
      address: '88 Le Loi, District 1',
      distanceMi: 1.2,
      rating: 4.7,
      imageUrl:
      'https://images.unsplash.com/photo-1581502806747-71c9cb585e27?w=800&q=80',
      description:
      'Private rooms with digital map screens. Perfect for D&D, Pathfinder, and Call of Cthulhu.',
      availableSlots: ['17:00', '20:00'],
      featuredGames: ['D&D', 'Pathfinder', 'Call of Cthulhu'],
      pricePerHour: 150000,
    ),
    BoardSpace(
      id: '3',
      name: 'The Casual Corner',
      address: '5 Pham Ngu Lao, District 1',
      distanceMi: 2.5,
      rating: 4.5,
      imageUrl:
      'https://images.unsplash.com/photo-1528819622765-d6bcf132f793?w=800&q=80',
      description:
      'Cozy seating and a huge library of party games. Featuring Codenames, Dixit, and Ticket to Ride.',
      availableSlots: ['14:00', '15:30', '17:00', '18:30'],
      featuredGames: ['Codenames', 'Dixit', 'Ticket to Ride'],
      pricePerHour: 90000,
    ),
    BoardSpace(
      id: '4',
      name: 'Euro Games Lounge',
      address: '30 Vo Van Tan, District 3',
      distanceMi: 3.1,
      rating: 4.6,
      imageUrl:
      'https://images.unsplash.com/photo-1559131397-f94da358f7ca?w=800&q=80',
      description:
      'Curated collection of Euro-style games. Featuring Agricola, Wingspan, and Brass: Birmingham.',
      availableSlots: ['16:00', '18:00', '20:00'],
      featuredGames: ['Agricola', 'Wingspan', 'Brass: Birmingham'],
      pricePerHour: 110000,
    ),
  ];
}