import 'package:flutter/material.dart';
import 'package:project/ui/dashboard/widgets/dashboard_card.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class StaffChatTemplate extends StatelessWidget {
  const StaffChatTemplate({super.key});

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
              DashboardCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.chat_outlined,
                      color: StaffDashboardColors.primary,
                      size: 32,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Chat Template',
                      style: TextStyle(
                        color: StaffDashboardColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Temporary screen for testing the Staff Chat tab.',
                      style: TextStyle(
                        color: StaffDashboardColors.muted,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
