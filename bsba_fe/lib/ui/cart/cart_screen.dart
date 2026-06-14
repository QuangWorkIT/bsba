import 'package:flutter/material.dart';
import 'package:project/ui/cart/cart_game_item_card.dart';
import 'package:project/ui/cart/order_summary_card.dart';
import 'package:project/ui/cart/reservation_summary_card.dart';
import 'package:project/ui/checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartGameItem> _games = [
    const CartGameItem(
      name: 'Catan',
      category: 'Resource Management',
      pricePerHour: 5,
    ),
    const CartGameItem(
      name: 'Ticket to Ride',
      category: 'Strategy',
      pricePerHour: 4,
    ),
  ];

  void _updateGame(int index, CartGameItem updated) {
    setState(() {
      _games[index] = updated;
    });
  }

  void _removeGame(int index) {
    setState(() {
      _games.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalGameItems = _games.fold<int>(0, (sum, g) => sum + g.quantity);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Cart'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ReservationSummaryCard(),
            const SizedBox(height: 32),
            _SelectedGamesHeader(itemCount: totalGameItems),
            const SizedBox(height: 16),
            ...List.generate(_games.length, (index) {
              final game = _games[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CartGameItemCard(
                  item: game,
                  onRemove: () => _removeGame(index),
                  onDecrement: () {
                    if (game.quantity > 1) {
                      _updateGame(
                        index,
                        CartGameItem(
                          name: game.name,
                          category: game.category,
                          pricePerHour: game.pricePerHour,
                          quantity: game.quantity - 1,
                        ),
                      );
                    }
                  },
                  onIncrement: () {
                    _updateGame(
                      index,
                      CartGameItem(
                        name: game.name,
                        category: game.category,
                        pricePerHour: game.pricePerHour,
                        quantity: game.quantity + 1,
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
            OrderSummaryCard(
              roomTotal: 45,
              gamesTotal: 27,
              serviceFee: 5.5,
              onCheckout: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CheckoutScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedGamesHeader extends StatelessWidget {
  const _SelectedGamesHeader({required this.itemCount});

  static Color _borderColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.outlineVariant : const Color(0xFFE0E2EB);

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final bodyTextColor = Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurfaceVariant : const Color(0xFF414753);
    final titleColor = Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : const Color(0xFF181C22);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor(context))),
      ),
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Selected Games',
            style: TextStyle(
              color: titleColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
          const Spacer(),
          Text(
            '$itemCount ${itemCount == 1 ? 'Item' : 'Items'}',
            style: TextStyle(
              color: bodyTextColor,
              fontSize: 14,
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }
}
