import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ZaloPayGatewayService {
  static const MethodChannel platform = MethodChannel(
    'flutter.native/channelPayOrder',
  );

  Future<void> openPaymentUrl(String zpToken) async {
    try {
      final String result = await platform.invokeMethod('payOrder', {
        "zptoken": zpToken,
      });
      if (result == "User Canceled") {
        throw Exception('User Canceled Payment');
      } else if (result == "Payment failed") {
        throw Exception('Payment Failed');
      }
      // If result == "Payment Success", it will just return normally
      debugPrint("payment result $result");
    } on PlatformException catch (e) {
      throw Exception('Lỗi thanh toán ZaloPay: ${e.message}');
    }
  }
}