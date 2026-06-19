import 'package:flutter/material.dart';
import 'staff_dashboard_tokens.dart';

class PeakHoursCard extends StatelessWidget {
  const PeakHoursCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StaffDashboardColors.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.white, size: 25),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peak Hours\nApproaching',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Expect higher traffic between 6 PM and 9 PM. Prepare table rotations.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: StaffDashboardColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            child: const Text(
              'View\nSchedule',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}
