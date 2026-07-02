import 'package:flutter/material.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';
import 'package:project/ui/qr_scan/qr_scan_viewmodel.dart';

class RecentCheckIns extends StatelessWidget {
  const RecentCheckIns({super.key, required this.isEmpty, required this.logs});

  final bool isEmpty;
  final List<CheckInLog> logs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: StaffDashboardColors.disabledField,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaffDashboardColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Check-ins',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: StaffDashboardColors.text,
                          fontSize: 18,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        isEmpty ? 'No check-ins yet' : 'Last 5 minutes',
                        style: const TextStyle(
                          color: StaffDashboardColors.muted,
                          fontSize: 12,
                          height: 1.33,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
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
            if (!isEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: StaffDashboardColors.border),
              const SizedBox(height: 10),
              ListView.separated(
                itemCount: logs.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _RecentCheckInRow(log: log);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentCheckInRow extends StatelessWidget {
  const _RecentCheckInRow({required this.log});

  final CheckInLog log;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: StaffDashboardColors.primary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${log.customerName} - ${log.bookingCode}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: StaffDashboardColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          _formatTime(log.checkedInAt),
          style: const TextStyle(
            color: StaffDashboardColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
