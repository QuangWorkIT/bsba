import 'package:flutter/material.dart';
import 'dashboard_card.dart';
import 'staff_dashboard_tokens.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    color: StaffDashboardColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.history_rounded,
                color: StaffDashboardColors.muted,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 16),
          _ActivityRow(
            icon: Icons.calendar_today_outlined,
            iconColor: StaffDashboardColors.primary,
            backgroundColor: Color(0xFFD6E3FF),
            title: 'New Booking',
            time: '2m ago',
          ),
          _ActivityRow(
            icon: Icons.check_circle_outline_rounded,
            iconColor: StaffDashboardColors.primary,
            backgroundColor: Color(0xFFD5E3FC),
            title: 'Customer Checked-in',
            time: '15m ago',
          ),
          _ActivityRow(
            icon: Icons.message_outlined,
            iconColor: Color(0xFF8E3F22),
            backgroundColor: Color(0xFFFFDBC9),
            title: 'New Message',
            time: '1h ago',
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.time,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: backgroundColor,
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: StaffDashboardColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: StaffDashboardColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: StaffDashboardColors.muted,
          ),
        ],
      ),
    );
  }
}
