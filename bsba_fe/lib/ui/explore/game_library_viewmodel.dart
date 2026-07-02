import 'package:flutter/material.dart';
import '../../data/models/board_game.dart';
import '../../data/repositories/board_game_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/services/api_client.dart';
import '../../data/services/cart_service.dart';

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
  final CartRepository _cartRepository;

  GameLibraryViewModel(this._repository, {CartRepository? cartRepository})
    : _cartRepository =
          cartRepository ?? CartRepository(CartService(ApiClient()));

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

  Future<String?> addToCart(
    BoardGame game, {
    String? bookingCartId,
    int quantity = 1,
  }) async {
    if (bookingCartId == null || bookingCartId.isEmpty) {
      return 'Please select a booking time first';
    }

    try {
      await _cartRepository.addItemToCart(
        bookingCartId: bookingCartId,
        boardGameId: game.id,
        quantity: quantity,
      );
      return null;
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return 'Failed to add ${game.name} to cart';
    }
  }
}
