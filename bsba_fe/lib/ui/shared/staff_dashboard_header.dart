import 'package:flutter/material.dart';
import '../dashboard/widgets/staff_dashboard_tokens.dart';

class StaffDashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  const StaffDashboardHeader({super.key, this.title = 'BoardNest'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: StaffDashboardColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: StaffDashboardColors.muted),
        onPressed: () {},
      ),
      titleSpacing: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: StaffDashboardColors.primary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: StaffDashboardColors.primary,
            child: CircleAvatar(
              radius: 17,
              backgroundImage: AssetImage('assets/images/booking/profile.png'),
            ),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: StaffDashboardColors.border),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
