import 'package:flutter/material.dart';
import 'package:project/ui/bookings/staff_bookings_screen.dart';
import 'dashboard_card.dart';
import 'staff_dashboard_tokens.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        mainAxisExtent: 132,
      ),
      children: [
        const _ActionTile(icon: Icons.storefront_outlined, label: 'Manage\nStore'),
        const _ActionTile(icon: Icons.extension_outlined, label: 'Manage\nGames'),
        const _ActionTile(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Customer\nChat',
          showBadge: true,
        ),
        _ActionTile(
          icon: Icons.receipt_long_outlined,
          label: 'Bookings',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StaffBookingsScreen()),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    this.showBadge = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool showBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: DashboardCard(
        padding: const EdgeInsets.all(16),
        child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: StaffDashboardColors.primary, size: 27),
                const SizedBox(height: 18),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: StaffDashboardColors.text,
                    fontSize: 18,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (showBadge)
            const Positioned(
              top: 0,
              right: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFBA1A1A),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 12, height: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
