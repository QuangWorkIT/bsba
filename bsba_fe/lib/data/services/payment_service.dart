import 'package:project/data/services/api_client.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  Future<String> createZaloPayPayment({
    required String bookingId,
    required double totalPrice,
  }) async {
    final response = await _apiClient.post('/payment/zalopay/create', {
      'bookingId': bookingId,
      'totalPrice': totalPrice,
    });
    final data = response['data'] as Map<String, dynamic>;
    return data['zpTransToken'] as String;
  }
}
