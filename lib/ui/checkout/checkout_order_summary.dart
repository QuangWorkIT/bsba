import 'package:flutter/material.dart';

class CheckoutOrderSummary extends StatelessWidget {
  const CheckoutOrderSummary({super.key, this.onConfirm});

  final VoidCallback? onConfirm;

  static const _summaryBackground = Color(0xFFF1F3FC);
  static const _separatorColor = Color(0xFFC1C6D5);
  static const _bodyTextColor = Color(0xFF414753);
  static const _titleColor = Color(0xFF181C22);

  static const _subtotal = 60.0;
  static const _taxRate = 0.08;

  double get tax => _subtotal * _taxRate;
  double get total => _subtotal + tax;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: _summaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
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
          const _OrderLineItem(
            title: 'Premium Table Reservation',
            subtitle: 'Sat, Oct 28 • 18:00 (3 hours)',
            amount: 45,
          ),
          const SizedBox(height: 12),
          const _OrderLineItem(
            title: 'Board Game Rental Add-on',
            subtitle: 'Twilight Imperium (4th Ed)',
            amount: 15,
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: _separatorColor),
          const SizedBox(height: 8),
          _AmountRow(label: 'Subtotal', amount: _subtotal),
          const SizedBox(height: 4),
          _AmountRow(label: 'Tax (8%)', amount: tax),
          const SizedBox(height: 8),
          const Divider(height: 1, color: _separatorColor),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: _titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14),
                  SizedBox(width: 8),
                  Text(
                    'CONFIRM BOOKING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_outlined, size: 12, color: _bodyTextColor),
              SizedBox(width: 4),
              Text(
                'Secure transaction',
                style: TextStyle(
                  color: _bodyTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderLineItem extends StatelessWidget {
  const _OrderLineItem({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final String title;
  final String subtitle;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: CheckoutOrderSummary._titleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: CheckoutOrderSummary._bodyTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: CheckoutOrderSummary._titleColor,
            fontSize: 14,
            height: 1.43,
          ),
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.amount});

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
            color: CheckoutOrderSummary._bodyTextColor,
            fontSize: 14,
            height: 1.43,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: CheckoutOrderSummary._titleColor,
            fontSize: 14,
            height: 1.43,
          ),
        ),
      ],
    );
  }
}
