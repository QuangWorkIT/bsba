import 'package:flutter/material.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.roomTotal,
    required this.gamesTotal,
    required this.serviceFee,
    required this.onCheckout,
    required this.totalAmount,
    this.itemCount,
    this.showCheckout = true,
    this.checkoutButtonLabel = 'Proceed to Checkout',
    this.paymentSuccess = false,
  });

  final double roomTotal;
  final double gamesTotal;
  final double serviceFee;
  final VoidCallback onCheckout;
  final double totalAmount;
  final int? itemCount;
  final bool showCheckout;
  final String checkoutButtonLabel;
  final bool paymentSuccess;

  static Color _borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.outlineVariant
      : const Color(0xFFE0E2EB);
  static Color _bodyTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.onSurfaceVariant
      : const Color(0xFF414753);
  static Color _titleColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.onSurface
      : const Color(0xFF181C22);
  static Color _cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.surfaceContainer
      : Colors.white;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final buttonLabel = paymentSuccess ? 'Payment success' : checkoutButtonLabel;
    final buttonColor = paymentSuccess ? Colors.green : scheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor(context)),
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
          Text(
            'Order Summary',
            style: TextStyle(
              color: _titleColor(context),
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: _borderColor(context)),
          const SizedBox(height: 16),
          _SummaryRow(label: 'Reservation Fee', amount: roomTotal),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Game Rentals (${itemCount ?? 0} items)',
            amount: gamesTotal,
          ),
          if (serviceFee > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(label: 'Service Fee', amount: serviceFee),
          ],
          const SizedBox(height: 16),
          Divider(height: 1, color: _borderColor(context)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: _titleColor(context),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  '${totalAmount.toStringAsFixed(0)} VND',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          if (showCheckout) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: paymentSuccess ? null : onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  disabledBackgroundColor: buttonColor,
                  foregroundColor: scheme.onPrimary,
                  disabledForegroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      paymentSuccess ? Icons.check_circle_outline : Icons.arrow_forward,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: OrderSummaryCard._bodyTextColor(context),
              fontSize: 14,
              height: 1.43,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            '${amount.toStringAsFixed(0)} VND',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: OrderSummaryCard._bodyTextColor(context),
              fontSize: 14,
              height: 1.43,
            ),
          ),
        ),
      ],
    );
  }
}
