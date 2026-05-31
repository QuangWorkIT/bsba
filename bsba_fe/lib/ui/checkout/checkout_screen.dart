import 'package:flutter/material.dart';
import 'package:project/ui/checkout/billing_details_section.dart';
import 'package:project/ui/checkout/checkout_app_bar.dart';
import 'package:project/ui/checkout/checkout_order_summary.dart';
import 'package:project/ui/checkout/payment_method_section.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const _bodyTextColor = Color(0xFF414753);
  static const _titleColor = Color(0xFF181C22);

  final _nameController = TextEditingController(text: 'Alex Rivers');
  final _emailController =
      TextEditingController(text: 'alex.rivers@example.com');
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  PaymentMethod _paymentMethod = PaymentMethod.card;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  void _onConfirmBooking() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking confirmed (demo)')),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
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
            CheckoutOrderSummary(onConfirm: _onConfirmBooking),
          ],
        ),
      ),
    );
  }
}
