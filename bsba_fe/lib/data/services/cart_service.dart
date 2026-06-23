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

  Future<void> addItemToCart({
    required String bookingCartId,
    required String boardGameId,
    required int quantity,
  }) async {
    final response = await _apiClient.post('/carts/items', {
      'bookingCartId': bookingCartId,
      'boardGameId': boardGameId,
      'quantity': quantity,
    });

    if (response['success'] == false) {
      throw ApiException(
        400,
        response['message'] as String? ?? 'Unable to add game to cart.',
      );
    }
  }

  Future<void> updateItemQuantity({
    required String cartId,
    required String boardGameId,
    required int quantity,
  }) async {
    final response = await _apiClient.patch('/carts/items/quantity', {
      'cartId': cartId,
      'boardgameId': boardGameId,
      'quantity': quantity,
    });

    if (response['success'] == false) {
      throw ApiException(
        400,
        response['message'] as String? ?? 'Unable to update item quantity.',
      );
    }
  }

  Future<void> removeItem({
    required String cartId,
    required String boardGameId,
  }) async {
    final response = await _apiClient.delete('/carts/items', {
      'cartId': cartId,
      'boardgameId': boardGameId,
    });

    if (response['success'] == false) {
      throw ApiException(
        400,
        response['message'] as String? ?? 'Unable to remove game from cart.',
      );
    }
  }
}
