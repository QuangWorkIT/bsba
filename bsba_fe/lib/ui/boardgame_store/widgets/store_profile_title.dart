import 'package:flutter/material.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class StoreProfileTitle extends StatelessWidget {
  const StoreProfileTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Text(
            'Edit Store Profile',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: StaffDashboardColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
