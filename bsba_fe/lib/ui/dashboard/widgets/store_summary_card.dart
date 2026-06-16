import 'package:flutter/material.dart';
import 'dashboard_card.dart';
import 'staff_dashboard_tokens.dart';

class StoreSummaryCard extends StatelessWidget {
  const StoreSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 192,
            width: double.infinity,
            child: Image.asset(
              'assets/images/booking/booking_room_dragon.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'The Strategy\nHub',
                        style: TextStyle(
                          color: StaffDashboardColors.text,
                          fontSize: 24,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StatusPill(),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Color(0xFFF5B400), size: 20),
                    SizedBox(width: 6),
                    Text(
                      '4.9',
                      style: TextStyle(
                        color: StaffDashboardColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '(128 reviews)',
                      style: TextStyle(
                        color: StaffDashboardColors.muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Divider(height: 1, color: StaffDashboardColors.border),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _Metric(label: "TODAY'S BOOKINGS", value: '12'),
                    ),
                    Expanded(
                      child: _Metric(label: 'CAPACITY', value: '85%', dark: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 8, height: 8),
          ),
          SizedBox(width: 5),
          Text(
            'Status:\nOpen',
            style: TextStyle(
              color: Color(0xFF166534),
              fontSize: 11,
              height: 1.05,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.dark = false,
  });

  final String label;
  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: StaffDashboardColors.muted,
            fontSize: 12,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: dark ? StaffDashboardColors.text : StaffDashboardColors.primary,
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
