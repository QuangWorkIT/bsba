import 'package:flutter/material.dart';
import '../../data/models/board_game.dart';
import '../../data/repositories/board_game_repository.dart';

enum GameLibraryFilter {
  allGames('All Games'),
  strategy('Strategy'),
  party('Party'),
  family('Family'),
  deckBuilding('Deck Building');

  final String label;
  const GameLibraryFilter(this.label);
}

class GameLibraryViewModel extends ChangeNotifier {
  final BoardGameRepository _repository;

  GameLibraryViewModel(this._repository);

  // ── State ──────────────────────────────────────────────────────────────────
  List<BoardGame> _allGames = [];
  bool _isLoading = false;
  String? _error;
  GameLibraryFilter _activeFilter = GameLibraryFilter.allGames;
  String _searchQuery = '';

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get error => _error;
  GameLibraryFilter get activeFilter => _activeFilter;

  List<BoardGame> get filteredGames {
    return _allGames.where((game) {
      final matchesSearch =
          game.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          game.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter =
          _activeFilter == GameLibraryFilter.allGames ||
          game.category.toLowerCase() == _activeFilter.label.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  Future<void> loadGames({String? storeId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allGames = await _repository.fetchAllGames(storeId: storeId);
    } catch (e) {
      _error = 'Failed to load games. Make sure the backend is running.';
      debugPrint('Error loading games: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void onFilterChanged(GameLibraryFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  Future<bool> addToCart(
    BoardGame game, {
    String? storeId,
    String? slotId,
  }) async {
    // We could add a separate _isAddingToCart state if we wanted specific per-item loading
    try {
      await _repository.addToCart(game.id, storeId: storeId, slotId: slotId);
      return true;
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return false;
    }
  }
}
