import 'package:flutter/foundation.dart';
import 'package:project/data/repositories/payment_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/payment_service.dart';
import 'package:project/data/services/zalopay_gateway_service.dart';

class CheckoutViewModel extends ChangeNotifier {
  final PaymentRepository _paymentRepository;
  final ZaloPayGatewayService _zaloPayGatewayService;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CheckoutViewModel({
    PaymentRepository? paymentRepository,
    ZaloPayGatewayService? zaloPayGatewayService,
  })  : _paymentRepository = paymentRepository ??
            PaymentRepository(PaymentService(ApiClient())),
        _zaloPayGatewayService =
            zaloPayGatewayService ?? ZaloPayGatewayService();

  Future<bool> handleZaloPayPayment() async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = await _paymentRepository.createZaloPayPayment();
      await _zaloPayGatewayService.openPaymentUrl(url);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
