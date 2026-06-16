import 'package:flutter/material.dart';
import 'staff_dashboard_tokens.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: clipBehavior,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: StaffDashboardColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
