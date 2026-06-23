import 'package:project/data/services/payment_service.dart';

class PaymentRepository {
  final PaymentService _service;

  PaymentRepository(this._service);

  Future<String> createZaloPayPayment({
    required String bookingId,
    required double totalPrice,
  }) {
    return _service.createZaloPayPayment(
      bookingId: bookingId,
      totalPrice: totalPrice,
    );
  }
}
