import 'package:flutter/material.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.roomTotal,
    required this.gamesTotal,
    required this.serviceFee,
    required this.onCheckout,
  });

  final double roomTotal;
  final double gamesTotal;
  final double serviceFee;
  final VoidCallback onCheckout;

  static const _borderColor = Color(0xFFE0E2EB);
  static const _bodyTextColor = Color(0xFF414753);
  static const _titleColor = Color(0xFF181C22);

  double get total => roomTotal + gamesTotal + serviceFee;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              color: _titleColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: _borderColor),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Room Reservation (3 hrs)',
            amount: roomTotal,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Game Rentals (2 items)',
            amount: gamesTotal,
          ),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Service Fee', amount: serviceFee),
          const SizedBox(height: 16),
          const Divider(height: 1, color: _borderColor),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: _titleColor,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: OrderSummaryCard._bodyTextColor,
            fontSize: 14,
            height: 1.43,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: OrderSummaryCard._bodyTextColor,
            fontSize: 14,
            height: 1.43,
          ),
        ),
      ],
    );
  }
}
