import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/data/repositories/cart_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/cart_service.dart';
import 'package:project/data/services/current_user.dart';
import 'package:project/data/services/user_service.dart';
import 'package:project/ui/cart/cart_viewmodel.dart';
import 'package:project/ui/cart/order_summary_card.dart';
import 'package:project/ui/checkout/billing_details_section.dart';
import 'package:project/ui/checkout/checkout_app_bar.dart';
import 'package:project/ui/checkout/checkout_viewmodel.dart';
import 'package:project/ui/checkout/payment_method_section.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const _bodyTextColor = Color(0xFF414753);
  static const _titleColor = Color(0xFF181C22);

  late final CheckoutViewModel _viewModel;
  late final CartViewModel _cartViewModel;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  PaymentMethod _paymentMethod = PaymentMethod.card;

  @override
  void initState() {
    super.initState();
    _viewModel = CheckoutViewModel();
    _cartViewModel = CartViewModel(
      CartRepository(CartService(ApiClient())),
      bookingId: widget.bookingId,
    )
      ..fetchCart();
    _fillBillingDetailsFromCurrentUser();
    _refreshBillingDetails();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _cartViewModel.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  void _fillBillingDetailsFromCurrentUser() {
    final user = CurrentUser.instance;
    _nameController.text = user.fullName;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
  }

  Future<void> _refreshBillingDetails() async {
    try {
      final user = await UserService(ApiClient()).fetchUserProfile();
      CurrentUser.instance.setFrom(user);
      if (!mounted) return;
      setState(_fillBillingDetailsFromCurrentUser);
    } catch (e) {
      debugPrint('[Checkout] Unable to refresh billing details: $e');
    }
  }

  Future<void> _onConfirmBooking() async {
    if (_paymentMethod == PaymentMethod.momo) {
      await _handleMomoPayment();
    } else if (_paymentMethod == PaymentMethod.zalopay) {
      await _handleZaloPayPayment();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking confirmed (demo)')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _handleMomoPayment() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
      const amount =
          64800; // Total 60.0 + 8% tax = 64.8. MoMo uses VND, so usually 64800
      const orderInfo = 'Board Game Booking - Alex Rivers';

      // Call backend to create payment link
      final url =
          '${ApiClient.baseUrl}/payment/momo/create?orderId=$orderId&amount=$amount&orderInfo=$orderInfo';
      debugPrint('[MoMo] Calling: $url');

      final response = await http
          .post(Uri.parse(url))
          .timeout(const Duration(seconds: 45));

      if (!mounted) return;
      Navigator.of(context).pop(); // Hide loading indicator if showing

      debugPrint('[MoMo] Status: ${response.statusCode}');
      debugPrint('[MoMo] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payUrl = data['payUrl'];
        if (payUrl != null) {
          final uri = Uri.parse(payUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);

            if (!mounted) return;
            _showStatusCheckDialog(orderId);
          } else {
            throw 'Could not launch payment URL: $payUrl';
          }
        } else {
          throw 'Payment response missing payUrl';
        }
      } else {
        throw 'Backend Error (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      debugPrint('[MoMo] Error: $e');
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Hide loading
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'RETRY', onPressed: _handleMomoPayment),
        ),
      );
    }
  }

  Future<void> _handleZaloPayPayment() async {
    if (_cartViewModel.totalPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to create payment without total price.')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await _viewModel.handleZaloPayPayment(
      bookingId: widget.bookingId,
      totalPrice: _cartViewModel.totalPrice,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // Hide loading

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${_viewModel.errorMessage}'),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'RETRY',
            onPressed: _handleZaloPayPayment,
          ),
        ),
      );
    }
  }

  void _showStatusCheckDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Initiated'),
        content: const Text(
          'Please complete your payment in the MoMo app/website. After finishing, click the button below to check your status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Call backend to check status
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Status checking is not implemented yet. Please use the demo confirmation flow.',
                  ),
                ),
              );
            },
            child: const Text('CHECK STATUS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CheckoutAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Checkout',
              style: TextStyle(
                color: _titleColor,
                fontSize: 32,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Review your details and complete your booking.',
              style: TextStyle(
                color: _bodyTextColor,
                fontSize: 14,
                height: 1.43,
              ),
            ),
            const SizedBox(height: 24),
            BillingDetailsSection(
              nameController: _nameController,
              emailController: _emailController,
              phoneController: _phoneController,
            ),
            const SizedBox(height: 24),
            PaymentMethodSection(
              selectedMethod: _paymentMethod,
              onMethodSelected: (method) {
                setState(() => _paymentMethod = method);
              },
              cardNumberController: _cardNumberController,
              expiryController: _expiryController,
              cvcController: _cvcController,
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _cartViewModel,
              builder: (context, _) {
                if (_cartViewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_cartViewModel.error != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _cartViewModel.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cartViewModel.fetchCart,
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }

                return OrderSummaryCard(
                  roomTotal: _cartViewModel.chargeFee,
                  gamesTotal: _cartViewModel.retailPrice,
                  serviceFee: 0,
                  totalAmount: _cartViewModel.totalPrice,
                  itemCount: _cartViewModel.items.length,
                  checkoutButtonLabel: 'Confirm Booking',
                  onCheckout: _onConfirmBooking,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
