import 'package:project/data/models/board_game.dart';
import 'package:project/data/services/api_client.dart';

class BoardGameService {
  final ApiClient _apiClient;

  BoardGameService(this._apiClient);

  Future<List<BoardGame>> getAllBoardGames({String? storeId}) async {
    final queryParams = storeId != null ? '?storeId=$storeId' : '';
    final response = await _apiClient.get('/board-games$queryParams');

    // The backend uses a Page wrapper inside ApiResponse
    // Structure: { success: true, data: { content: [...] }, ... }
    final List<dynamic> content = response['data']['content'];

    return content.map((json) => BoardGame.fromJson(json)).toList();
  }

  Future<List<BoardGame>> getStaffBoardGames() async {
    final response = await _apiClient.get('/stores/staff/board-games');
    // Expected response data: List of board games
    final List<dynamic> data = response['data'];
    return data.map((json) => BoardGame.fromJson(json)).toList();
  }

  Future<BoardGame> getBoardGameById(String id) async {
    final response = await _apiClient.get('/board-games/$id');
    return BoardGame.fromJson(response['data']);
  }

  Future<void> addToCart(
    String gameId, {
    int quantity = 1,
    String? storeId,
    String? slotId,
  }) async {
    await _apiClient.post('/carts/items', {
      'boardGameId': gameId,
      'quantity': quantity,
      if (storeId != null) 'storeId': storeId,
      if (slotId != null) 'slotId': slotId,
    });
  }

  Future<BoardGame> createBoardGame({
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
    final response = await _apiClient.post('/board-games', {
      'name': name,
      'description': description,
      'minPlayers': minPlayers,
      'maxPlayers': maxPlayers,
      'playTimeMinutes': playTimeMinutes,
      'ageRequirement': ageRequirement,
      'quantity': quantity,
      'category': category,
      'imageUrl': imageUrl,
    });
    return BoardGame.fromJson(response['data']);
  }
}
