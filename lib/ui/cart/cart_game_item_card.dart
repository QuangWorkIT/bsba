import 'package:flutter/material.dart';

class CartGameItem {
  const CartGameItem({
    required this.name,
    required this.category,
    required this.pricePerHour,
    this.quantity = 1,
  });

  final String name;
  final String category;
  final double pricePerHour;
  final int quantity;
}

class CartGameItemCard extends StatelessWidget {
  const CartGameItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onDecrement,
    required this.onIncrement,
  });

  final CartGameItem item;
  final VoidCallback onRemove;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  static const _borderColor = Color(0xFFE0E2EB);
  static const _imagePlaceholderColor = Color(0xFFEBEDF7);
  static const _bodyTextColor = Color(0xFF414753);
  static const _titleColor = Color(0xFF181C22);
  static const _stepperBackground = Color(0xFFEBEDF7);

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
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: _imagePlaceholderColor,
              alignment: Alignment.center,
              child: Icon(
                Icons.videogame_asset_outlined,
                size: 32,
                color: scheme.secondary.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: _titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.category,
                  style: const TextStyle(
                    color: _bodyTextColor,
                    fontSize: 14,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${item.pricePerHour.toStringAsFixed(2)} / hr',
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    _QuantityStepper(
                      quantity: item.quantity,
                      onDecrement: onDecrement,
                      onIncrement: onIncrement,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: scheme.tertiary),
            onPressed: onRemove,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CartGameItemCard._stepperBackground,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove, onPressed: onDecrement),
          SizedBox(
            width: 16,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CartGameItemCard._titleColor,
                fontSize: 14,
                height: 1.43,
              ),
            ),
          ),
          _StepperButton(icon: Icons.add, onPressed: onIncrement),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(9999),
        child: SizedBox(
          width: 24,
          height: 24,
          child: Icon(icon, size: 16, color: CartGameItemCard._titleColor),
        ),
      ),
    );
  }
}
