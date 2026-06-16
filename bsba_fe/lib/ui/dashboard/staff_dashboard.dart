import 'package:flutter/material.dart';
import 'package:project/ui/dashboard/widgets/peak_hours_card.dart';
import 'package:project/ui/dashboard/widgets/quick_actions_grid.dart';
import 'package:project/ui/dashboard/widgets/recent_activity_card.dart';
import 'package:project/ui/dashboard/widgets/store_summary_card.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            children: const [
              StoreSummaryCard(),
              SizedBox(height: 24),
              RecentActivityCard(),
              SizedBox(height: 24),
              QuickActionsGrid(),
              SizedBox(height: 28),
              PeakHoursCard(),
            ],
          ),
        ),
      ),
    );
  }
}
