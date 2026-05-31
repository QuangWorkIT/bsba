import 'package:flutter/material.dart';

class CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CartAppBar({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: scheme.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: scheme.onSurface),
        onPressed: onBack,
      ),
      title: Text(
        'Cart',
        style: TextStyle(
          color: scheme.primary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.6,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: scheme.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
