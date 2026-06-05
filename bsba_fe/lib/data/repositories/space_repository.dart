import '../models/board_space.dart';
import '../services/space_service.dart';

class SpaceRepository {
  final SpaceService _service;

  SpaceRepository(this._service);

  Future<List<BoardSpace>> fetchSpaces({
    double? lat,
    double? lng,
    String sort = 'ALL',
    String? q,
  }) {
    return _service.getSpaces(lat: lat, lng: lng, sort: sort, q: q);
  }
}
