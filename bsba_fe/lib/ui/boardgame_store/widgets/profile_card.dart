import 'package:flutter/material.dart';
import 'package:project/ui/boardgame_store/widgets/section_title.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.icon,
    required this.title,
    required this.children,
    super.key,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaffDashboardColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                width: 4,
                child: ColoredBox(color: StaffDashboardColors.primary),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            icon,
                            color: StaffDashboardColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: SectionTitle(title: title)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...children,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
