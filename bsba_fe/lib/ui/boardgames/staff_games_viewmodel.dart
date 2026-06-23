import 'package:flutter/material.dart';
import 'package:project/data/repositories/board_game_repository.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

enum SortOption {
  nameAsc,
  nameDesc,
  stockAsc,
  stockDesc,
}

class GameItem {
  final String title;
  final String imageUrl;
  final String players;
  final String playtime;
  final int stock;
  final String? tag;
  final Color? tagColor;

  GameItem({
    required this.title,
    required this.imageUrl,
    required this.players,
    required this.playtime,
    required this.stock,
    this.tag,
    this.tagColor,
  });

  GameItem copyWith({
    String? title,
    String? imageUrl,
    String? players,
    String? playtime,
    int? stock,
    String? tag,
    Color? tagColor,
  }) {
    return GameItem(
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      players: players ?? this.players,
      playtime: playtime ?? this.playtime,
      stock: stock ?? this.stock,
      tag: tag ?? this.tag,
      tagColor: tagColor ?? this.tagColor,
    );
  }
}

class StaffGamesViewModel extends ChangeNotifier {
  final BoardGameRepository _repository;

  List<GameItem> _games = [];
  bool _isLoading = true;
  String? _error;

  String _searchQuery = '';
  String? _selectedCategory;
  SortOption _sortOption = SortOption.nameAsc;

  StaffGamesViewModel(this._repository);

  List<GameItem> get games => _games;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  SortOption get sortOption => _sortOption;

  List<String> get availableCategories {
    final categories = _games.map((g) => g.tag).whereType<String>().toSet().toList();
    categories.sort();
    return categories;
  }

  List<GameItem> get filteredAndSortedGames {
    var result = _games.where((game) {
      final matchesSearch = game.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || game.tag == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    switch (_sortOption) {
      case SortOption.nameAsc:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.nameDesc:
        result.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.stockAsc:
        result.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case SortOption.stockDesc:
        result.sort((a, b) => b.stock.compareTo(a.stock));
        break;
    }

    return result;
  }

  Future<void> loadGames() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final gamesData = await _repository.fetchStaffGames();
      _games = gamesData.map((game) {
        return GameItem(
          title: game.name,
          imageUrl: game.imageUrl.isNotEmpty
              ? game.imageUrl
              : 'https://via.placeholder.com/150', // fallback image
          players: game.playerRange,
          playtime: game.playDuration,
          stock: game.stock ?? 0,
          tag: game.category,
          tagColor: StaffDashboardColors.primary, // Determine color dynamically if needed
        );
      }).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateStock(GameItem game, int change) {
    final index = _games.indexOf(game);
    if (index == -1) return;

    final newStock = game.stock + change;
    if (newStock >= 0) {
      _games[index] = game.copyWith(stock: newStock);
      // Depending on backend, you would also call repository to update stock
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }
}
