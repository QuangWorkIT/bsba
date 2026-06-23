import 'package:project/data/services/api_client.dart';

class CartService {
  final ApiClient _apiClient;

  CartService(this._apiClient);

  Future<Map<String, dynamic>?> fetchCart({String? bookingId}) async {
    final path = bookingId == null || bookingId.isEmpty
        ? '/carts'
        : '/carts/$bookingId';
    final response = await _apiClient.get(path);

    if (response['success'] == false) {
      throw ApiException(
        400,
        response['message'] as String? ?? 'Unable to fetch cart.',
      );
    }

    return response['data'] as Map<String, dynamic>?;
  }

  Future<void> createEmptyCart(String bookingId) async {
    final response = await _apiClient.post('/carts', {
      'bookingId': bookingId,
    });

    if (response['success'] == false) {
      throw ApiException(
        400,
        response['message'] as String? ?? 'Unable to create cart.',
      );
    }
  }

  Future<void> updateItemQuantity(String gameId, int quantity) async {
    await _apiClient.patch('/carts/items/$gameId', {'quantity': quantity});
  }

  Future<void> removeItem(String gameId) async {
    await _apiClient.delete('/carts/items/$gameId');
  }
}
