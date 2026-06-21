import 'package:flutter/material.dart';

import 'package:project/data/models/staff_booking.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

/// One booking row on the staff "Manage Bookings" screen: time + customer, a
/// status badge, party/table info, and a details/overflow footer. A coloured
/// strip down the leading edge encodes the status at a glance.
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.onViewDetails,
    this.onMore,
  });

  final StaffBooking booking;
  final VoidCallback? onViewDetails;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final visual = _StatusVisual.of(booking.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaffDashboardColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: visual.strip),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderRow(booking: booking, visual: visual),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.group_outlined,
                        text: '${booking.partySize} People',
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: _tableIcon(booking.tableInfo),
                        text: booking.tableInfo,
                      ),
                      _FooterRow(onViewDetails: onViewDetails, onMore: onMore),
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

  static IconData _tableIcon(String info) {
    final lower = info.toLowerCase();
    if (lower.contains('deposit') || lower.contains('payment')) {
      return Icons.payments_outlined;
    }
    if (lower.contains('needs') || lower.contains('await')) {
      return Icons.error_outline;
    }
    if (lower.contains('room') || lower.contains('library')) {
      return Icons.meeting_room_outlined;
    }
    return Icons.table_restaurant_outlined;
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.booking, required this.visual});

  final StaffBooking booking;
  final _StatusVisual visual;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.timeRange.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: visual.strip,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                booking.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: StaffDashboardColors.text,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _StatusBadge(visual: visual),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.visual});

  final _StatusVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: visual.badgeBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(visual.icon, size: 12, color: visual.badgeFg),
          const SizedBox(width: 4),
          Text(
            visual.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: visual.badgeFg,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: StaffDashboardColors.muted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: StaffDashboardColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({this.onViewDetails, this.onMore});

  final VoidCallback? onViewDetails;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: StaffDashboardColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onViewDetails,
            child: const Row(
              children: [
                Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: StaffDashboardColors.primary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    size: 16, color: StaffDashboardColors.primary),
              ],
            ),
          ),
          InkWell(
            onTap: onMore,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.more_vert,
                  size: 18, color: StaffDashboardColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Per-status colours/icon used across the card (strip, time text, badge).
class _StatusVisual {
  final Color strip;
  final Color badgeBg;
  final Color badgeFg;
  final IconData icon;
  final String label;

  const _StatusVisual({
    required this.strip,
    required this.badgeBg,
    required this.badgeFg,
    required this.icon,
    required this.label,
  });

  static _StatusVisual of(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return const _StatusVisual(
          strip: StaffDashboardColors.primary, // #005AB4
          badgeBg: Color(0xFFD5E3FC),
          badgeFg: Color(0xFF00458D),
          icon: Icons.check_circle,
          label: 'Confirmed',
        );
      case BookingStatus.pending:
        return const _StatusVisual(
          strip: Color(0xFF964400),
          badgeBg: Color(0xFFFFDBC9),
          badgeFg: Color(0xFF763400),
          icon: Icons.schedule,
          label: 'Pending',
        );
      case BookingStatus.completed:
        return const _StatusVisual(
          strip: Color(0xFF3F7D58),
          badgeBg: Color(0xFFD7EFE0),
          badgeFg: Color(0xFF1B5E3A),
          icon: Icons.task_alt,
          label: 'Completed',
        );
      case BookingStatus.cancelled:
        return const _StatusVisual(
          strip: Color(0xFFBA1A1A),
          badgeBg: Color(0xFFFFDAD6),
          badgeFg: Color(0xFFBA1A1A),
          icon: Icons.cancel,
          label: 'Cancelled',
        );
    }
  }
}
