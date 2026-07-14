import 'package:flutter/foundation.dart';
import 'package:project/data/repositories/cart_repository.dart';

class CartItem {
  final String id;
  final String boardGameId;
  final String name;
  final String category;
  final String imageUrl;
  final double rentalPrice;
  final int quantity;

  CartItem({
    required this.id,
    required this.boardGameId,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.rentalPrice,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';

    return CartItem(
      id: id,
      boardGameId: json['boardGameId']?.toString() ?? id,
      name: json['boardGameName'] ?? json['name'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rentalPrice: (json['rentalPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
    );
  }
}

class CartViewModel extends ChangeNotifier {
  final CartRepository _repository;
  final String? bookingId;

  CartViewModel(this._repository, {this.bookingId});

  List<CartItem> _items = [];
  int _participants = 0;
  double _chargeFee = 0.0;
  double _retailPrice = 0.0;
  double _totalPrice = 0.0;
  bool _isLoading = false;
  String? _error;

  String? _cartId;
  String? _storeName;
  String? _storeImage;
  String? _slotDate;
  String? _startTime;
  String? _endTime;

  List<CartItem> get items => _items;
  int get participants => _participants;
  double get chargeFee => _chargeFee;
  double get retailPrice => _retailPrice;
  double get totalPrice => _totalPrice;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get cartId => _cartId;
  String? get storeName => _storeName;
  String? get storeImage => _storeImage;
  String? get slotDate => _slotDate;
  String? get startTime => _startTime;
  String? get endTime => _endTime;

  Future<void> fetchCart({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final data = await _repository.fetchCart(bookingId: bookingId);

      if (data == null) {
        _items = [];
        _participants = 0;
        _chargeFee = 0.0;
        _retailPrice = 0.0;
        _totalPrice = 0.0;
        _cartId = null;
        _storeName = null;
        _storeImage = null;
        _slotDate = null;
        _startTime = null;
        _endTime = null;
        return;
      }

      final List<dynamic> gamesJson = data['boardGames'] ?? data['items'] ?? [];
      _items = gamesJson
          .whereType<Map<String, dynamic>>()
          .map(CartItem.fromJson)
          .toList();
      _participants = (data['participants'] as num?)?.toInt() ?? 0;
      _chargeFee = (data['chargeFee'] as num?)?.toDouble() ?? 0.0;
      _retailPrice = (data['retailPrice'] as num?)?.toDouble() ?? 0.0;
      _totalPrice = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;

      _cartId = data['id']?.toString();
      _storeName = data['storeName']?.toString();
      _storeImage = data['storeImage']?.toString();
      _slotDate = data['slotDate']?.toString();
      _startTime = data['startTime']?.toString();
      _endTime = data['endTime']?.toString();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String gameId, int quantity) async {
    final cartId = _cartId;
    if (cartId == null || cartId.isEmpty) {
      debugPrint('Error updating quantity: Cart id is missing.');
      return;
    }

    // Optimistic local update – reflect change immediately.
    final oldItems = List<CartItem>.from(_items);
    final oldRetail = _retailPrice;
    final oldTotal = _totalPrice;

    final idx = _items.indexWhere((i) => i.boardGameId == gameId);
    if (idx != -1) {
      final old = _items[idx];
      final diff = quantity - old.quantity;
      _items[idx] = CartItem(
        id: old.id,
        boardGameId: old.boardGameId,
        name: old.name,
        category: old.category,
        imageUrl: old.imageUrl,
        rentalPrice: old.rentalPrice,
        quantity: quantity,
      );
      _retailPrice += diff * old.rentalPrice;
      _totalPrice += diff * old.rentalPrice;
      notifyListeners();
    }

    try {
      await _repository.updateItemQuantity(
        cartId: cartId,
        boardGameId: gameId,
        quantity: quantity,
      );
      // Silently sync with server to get authoritative totals.
      await fetchCart(silent: true);
    } catch (e) {
      // Rollback on failure.
      _items = oldItems;
      _retailPrice = oldRetail;
      _totalPrice = oldTotal;
      notifyListeners();
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> removeItem(String gameId) async {
    final cartId = _cartId;
    if (cartId == null || cartId.isEmpty) {
      debugPrint('Error removing item: Cart id is missing.');
      return;
    }

    // Optimistic local removal.
    final oldItems = List<CartItem>.from(_items);
    final oldRetail = _retailPrice;
    final oldTotal = _totalPrice;

    final idx = _items.indexWhere((i) => i.boardGameId == gameId);
    if (idx != -1) {
      final removed = _items.removeAt(idx);
      final cost = removed.rentalPrice * removed.quantity;
      _retailPrice -= cost;
      _totalPrice -= cost;
      notifyListeners();
    }

    try {
      await _repository.removeItem(cartId: cartId, boardGameId: gameId);
      await fetchCart(silent: true);
    } catch (e) {
      // Rollback on failure.
      _items = oldItems;
      _retailPrice = oldRetail;
      _totalPrice = oldTotal;
      notifyListeners();
      debugPrint('Error removing item: $e');
    }
  }
}
