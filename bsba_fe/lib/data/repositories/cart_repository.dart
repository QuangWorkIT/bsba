import '../services/cart_service.dart';

class CartRepository {
  final CartService _service;

  CartRepository(this._service);

  Future<Map<String, dynamic>?> fetchCart({String? bookingId}) async {
    return _service.fetchCart(bookingId: bookingId);
  }

  Future<void> createEmptyCartForBooking(String bookingId) async {
    await _service.createEmptyCart(bookingId);
  }

  Future<void> addItemToCart({
    required String bookingCartId,
    required String boardGameId,
    required int quantity,
  }) async {
    await _service.addItemToCart(
      bookingCartId: bookingCartId,
      boardGameId: boardGameId,
      quantity: quantity,
    );
  }

  Future<void> updateItemQuantity({
    required String cartId,
    required String boardGameId,
    required int quantity,
  }) async {
    await _service.updateItemQuantity(
      cartId: cartId,
      boardGameId: boardGameId,
      quantity: quantity,
    );
  }

  Future<void> removeItem({
    required String cartId,
    required String boardGameId,
  }) async {
    await _service.removeItem(cartId: cartId, boardGameId: boardGameId);
  }
}
