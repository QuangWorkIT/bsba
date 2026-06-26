import 'package:flutter/material.dart';
import 'package:project/app/home_screen.dart';
import 'package:project/ui/booking/booking_viewmodel.dart';

class CheckoutAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CheckoutAppBar({super.key, this.paymentSuccess = false});

  final bool paymentSuccess;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: scheme.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: scheme.onSurface),
        onPressed: () {
          if (paymentSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (_) => const HomeScreen(
                  initialIndex: 2,
                  initialBookingTab: BookingTab.confirmed,
                ),
              ),
              (route) => false,
            );
          } else {
            Navigator.of(context).maybePop();
          }
        },
      ),
      title: Text(
        'BoardNest ',
        style: TextStyle(
          color: scheme.primary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.6,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E8F1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC1C6D5)),
            ),
            child: Icon(Icons.person_outline, size: 20, color: scheme.secondary),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
