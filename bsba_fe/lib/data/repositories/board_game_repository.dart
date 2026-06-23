import '../models/board_game.dart';
import '../services/boardgame_service.dart';

class BoardGameRepository {
  final BoardGameService _service;

  BoardGameRepository(this._service);

  Future<List<BoardGame>> fetchAllGames({String? storeId}) async {
    // Repository can handle caching or complex sorting logic if needed
    return await _service.getAllBoardGames(storeId: storeId);
  }

  Future<List<BoardGame>> fetchStaffGames() async {
    return await _service.getStaffBoardGames();
  }

  Future<BoardGame> fetchGameById(String id) async {
    return await _service.getBoardGameById(id);
  }

  Future<void> addToCart(
    String gameId, {
    String? storeId,
    String? slotId,
  }) async {
    await _service.addToCart(gameId, storeId: storeId, slotId: slotId);
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
