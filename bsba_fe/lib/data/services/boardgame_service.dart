import 'package:project/data/models/board_game.dart';
import 'package:project/data/services/api_client.dart';

class BoardGameService {
  final ApiClient _apiClient;

  BoardGameService(this._apiClient);

  Future<List<BoardGame>> getAllBoardGames() async {
    final response = await _apiClient.get('/board-games');

    // The backend uses a Page wrapper inside ApiResponse
    // Structure: { success: true, data: { content: [...] }, ... }
    final List<dynamic> content = response['data']['content'];

    return content.map((json) => BoardGame.fromJson(json)).toList();
  }

  Future<BoardGame> getBoardGameById(String id) async {
    final response = await _apiClient.get('/board-games/$id');
    return BoardGame.fromJson(response['data']);
  }

  Future<Map<String, dynamic>> getSpaceDetail(String id) async {
    // Calling the API endpoint defined in StoreController
    final response = await _apiClient.get('/stores/$id');
    return response['data'];
  }
}
