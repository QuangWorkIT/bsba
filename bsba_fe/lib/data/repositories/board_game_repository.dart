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
}
