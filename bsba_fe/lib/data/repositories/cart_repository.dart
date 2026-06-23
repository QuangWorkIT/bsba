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

  Future<void> updateItemQuantity(String gameId, int quantity) async {
    await _service.updateItemQuantity(gameId, quantity);
  }

  Future<void> removeItem(String gameId) async {
    await _service.removeItem(gameId);
  }
}
