import 'package:flutter/material.dart';
import 'package:project/data/repositories/board_game_repository.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

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

  StaffGamesViewModel(this._repository);

  List<GameItem> get games => _games;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
}
