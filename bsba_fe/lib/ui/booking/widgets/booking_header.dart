import 'package:flutter/material.dart';
import 'package:project/ui/cart/cart_screen.dart';

class BookingHeader extends StatelessWidget {
  const BookingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.menu, size: 26, color: scheme.onSurface),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'My Bookings',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.primary,
                fontSize: 24,
                height: 32 / 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
            },
            icon: Icon(
              Icons.shopping_cart_outlined,
              size: 28,
              color: scheme.primary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: scheme.primaryContainer,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }
}
