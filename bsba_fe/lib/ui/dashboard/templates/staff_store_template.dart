import 'package:flutter/material.dart';
import 'package:project/ui/dashboard/widgets/dashboard_card.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class StaffStoreTemplate extends StatelessWidget {
  const StaffStoreTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StaffTemplateScaffold(
      icon: Icons.storefront_outlined,
      title: 'Store Template',
      subtitle: 'Temporary screen for testing the Staff Store tab.',
    );
  }
}

class _StaffTemplateScaffold extends StatelessWidget {
  const _StaffTemplateScaffold({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            children: [
              DashboardCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: StaffDashboardColors.primary, size: 32),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        color: StaffDashboardColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
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
