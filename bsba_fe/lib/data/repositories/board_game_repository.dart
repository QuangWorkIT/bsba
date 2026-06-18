import '../models/board_game.dart';
import '../services/boardgame_service.dart';

class BoardGameRepository {
  final BoardGameService _service;

  BoardGameRepository(this._service);

  Future<List<BoardGame>> fetchAllGames() async {
    // Repository can handle caching or complex sorting logic if needed
    return await _service.getAllBoardGames();
  }

  Future<BoardGame> fetchGameById(String id) async {
    return await _service.getBoardGameById(id);
  }

  Future<void> addToCart(String gameId) async {
    // For now, quantity is hardcoded to 1, and storeId is handled by backend or picked from context
    await _service.addToCart(gameId);
  }

  Future<BoardGame> createGame({
    required String name,
    required String description,
    required int minPlayers,
    required int maxPlayers,
    required int playTimeMinutes,
    required int ageRequirement,
    required int quantity,
    required String category,
    required String imageUrl,
  }) async {
    return await _service.createBoardGame(
      name: name,
      description: description,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      playTimeMinutes: playTimeMinutes,
      ageRequirement: ageRequirement,
      quantity: quantity,
      category: category,
      imageUrl: imageUrl,
    );
  }
}
