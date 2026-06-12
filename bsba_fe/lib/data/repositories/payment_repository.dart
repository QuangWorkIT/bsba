import 'package:project/data/services/payment_service.dart';

class PaymentRepository {
  final PaymentService _service;

  PaymentRepository(this._service);

  Future<String> createZaloPayPayment() => _service.createZaloPayPayment();
}
