import 'package:flutter/foundation.dart';
import '../../data/services/api_client.dart';

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
    return CartItem(
      id: json['id'].toString(),
      boardGameId: json['boardGameId'],
      name: json['boardGameName'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rentalPrice: (json['rentalPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
    );
  }
}

class CartViewModel extends ChangeNotifier {
  final ApiClient _apiClient;

  CartViewModel(this._apiClient);

  List<CartItem> _items = [];
  double _totalPrice = 0.0;
  bool _isLoading = false;
  String? _error;

  String? _storeName;
  String? _storeImage;
  String? _slotDate;
  String? _startTime;
  String? _endTime;

  List<CartItem> get items => _items;
  double get totalPrice => _totalPrice;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get storeName => _storeName;
  String? get storeImage => _storeImage;
  String? get slotDate => _slotDate;
  String? get startTime => _startTime;
  String? get endTime => _endTime;

  Future<void> fetchCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/carts');
      final data = response['data'];

      if (data == null) {
        _items = [];
        _totalPrice = 0.0;
        _storeName = null;
        _storeImage = null;
        _slotDate = null;
        _startTime = null;
        _endTime = null;
        return;
      }

      final List<dynamic> itemsJson = data['items'];
      _items = itemsJson.map((json) => CartItem.fromJson(json)).toList();
      _totalPrice = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;

      _storeName = data['storeName'];
      _storeImage = data['storeImage'];
      _slotDate = data['slotDate'];
      _startTime = data['startTime'];
      _endTime = data['endTime'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String gameId, int quantity) async {
    try {
      await _apiClient.patch('/carts/items/$gameId', {'quantity': quantity});
      await fetchCart();
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> removeItem(String gameId) async {
    try {
      await _apiClient.delete('/carts/items/$gameId');
      await fetchCart();
    } catch (e) {
      debugPrint('Error removing item: $e');
    }
  }
}
