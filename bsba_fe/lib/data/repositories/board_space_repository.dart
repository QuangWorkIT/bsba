import '../models/board_space_detail.dart';
import '../services/api_client.dart';

class BoardSpaceRepository {
  final ApiClient _apiClient;

  BoardSpaceRepository(this._apiClient);

  Future<BoardSpaceDetail> fetchSpaceById(String id) async {
    final response = await _apiClient.get('/stores/$id');
    return BoardSpaceDetail.fromJson(response['data']);
  }
}

