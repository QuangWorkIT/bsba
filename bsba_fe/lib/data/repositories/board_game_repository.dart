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
}
