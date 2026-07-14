import 'package:flutter/material.dart';

class CartGameItem {
  const CartGameItem({
    required this.id,
    required this.boardGameId,
    required this.name,
    required this.category,
    required this.pricePerHour,
    required this.imageUrl,
    this.quantity = 1,
  });

  final String id;
  final String boardGameId;
  final String name;
  final String category;
  final double pricePerHour;
  final String imageUrl;
  final int quantity;
}

class CartGameItemCard extends StatelessWidget {
  const CartGameItemCard({
    super.key,
    required this.item,
    this.canEdit = true,
    required this.onRemove,
    required this.onDecrement,
    required this.onIncrement,
  });

  final CartGameItem item;
  final bool canEdit;
  final VoidCallback onRemove;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  static Color _borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.outlineVariant
      : const Color(0xFFE0E2EB);
  static Color _imagePlaceholderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.surfaceContainerHighest
      : const Color(0xFFEBEDF7);
  static Color _bodyTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.onSurfaceVariant
      : const Color(0xFF414753);
  static Color _titleColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.onSurface
      : const Color(0xFF181C22);
  static Color _stepperBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.surfaceContainerHighest
      : const Color(0xFFEBEDF7);
  static Color _cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.surfaceContainer
      : Colors.white;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: _imagePlaceholderColor(context),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.videogame_asset_outlined,
                  size: 32,
                  color: scheme.secondary.withValues(alpha: 0.5),
                ),
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
                  style: TextStyle(
                    color: _titleColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.category,
                  style: TextStyle(
                    color: _bodyTextColor(context),
                    fontSize: 14,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${item.pricePerHour.toStringAsFixed(0)} VND / hr',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (canEdit)
                      _QuantityStepper(
                        quantity: item.quantity,
                        onDecrement: onDecrement,
                        onIncrement: onIncrement,
                      )
                    else
                      _QuantityCount(quantity: item.quantity),
                  ],
                ),
              ],
            ),
          ),
          if (canEdit)
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

class _QuantityCount extends StatelessWidget {
  const _QuantityCount({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: CartGameItemCard._stepperBackground(context),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        '$quantity',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: CartGameItemCard._titleColor(context),
          fontSize: 14,
          height: 1.43,
        ),
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
        color: CartGameItemCard._stepperBackground(context),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove, onPressed: onDecrement),
          Container(
            constraints: const BoxConstraints(minWidth: 24),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CartGameItemCard._titleColor(context),
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
          child: Icon(
            icon,
            size: 16,
            color: CartGameItemCard._titleColor(context),
          ),
        ),
      ),
    );
  }
}
