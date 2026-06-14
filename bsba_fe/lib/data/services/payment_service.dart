import 'package:project/data/services/api_client.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  Future<String> createZaloPayPayment() async {
    final response = await _apiClient.post('/payment/zalopay/create', {
      "bookingId": "f0000000-0000-0000-0000-000000000003",
    });
    final data = response['data'] as Map<String, dynamic>;
    return data['zpTransToken'] as String;
  }
}
