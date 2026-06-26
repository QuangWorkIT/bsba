import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project/data/repositories/booking_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/booking_service.dart';
import 'package:project/ui/bookings/staff_bookings_viewmodel.dart';
import 'package:project/ui/bookings/widgets/booking_card.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

/// Staff "Manage Bookings" screen — daily overview, status filter chips, the
/// booking list, an add-walk-in slot, and a peak-hours insight. Reached from the
/// Bookings quick action on the staff dashboard.
class StaffBookingsScreen extends StatelessWidget {
  const StaffBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          StaffBookingsViewModel(BookingRepository(BookingService(ApiClient())))
            ..load(),
      child: const _BookingsView(),
    );
  }
}

class _BookingsView extends StatelessWidget {
  const _BookingsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StaffBookingsViewModel>();
    final bookings = vm.bookings;

    return Scaffold(
      backgroundColor: StaffDashboardColors.background,
      appBar: AppBar(
        backgroundColor: StaffDashboardColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: StaffDashboardColors.primary,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Manage Bookings',
          style: TextStyle(
            color: StaffDashboardColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: StaffDashboardColors.border,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _OverviewSection(confirmedCount: vm.confirmedTodayCount),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              sliver: SliverToBoxAdapter(
                child: _FilterChips(
                  active: vm.filter,
                  onSelected: vm.setFilter,
                ),
              ),
            ),
            if (vm.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (vm.error != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: _ErrorState(message: vm.error!, onRetry: vm.load),
                ),
              )
            else if (bookings.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(child: _EmptyState()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: bookings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 24),
                  itemBuilder: (context, index) => BookingCard(
                    booking: bookings[index],
                    onViewDetails: () {},
                    onMore: () {},
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              sliver: const SliverToBoxAdapter(child: _AddSlotCard()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
              sliver: const SliverToBoxAdapter(child: _InsightCard()),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.confirmedCount});

  final int confirmedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: StaffDashboardColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'You have $confirmedCount confirmed bookings for today.',
          style: const TextStyle(
            fontSize: 14,
            color: StaffDashboardColors.muted,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: _NewBookingButton(onTap: () {}),
        ),
      ],
    );
  }
}

class _NewBookingButton extends StatelessWidget {
  const _NewBookingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StaffDashboardColors.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'New Booking',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.active, required this.onSelected});

  final BookingFilter active;
  final ValueChanged<BookingFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: BookingFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = BookingFilter.values[index];
          return _Chip(
            label: filter.label,
            selected: filter == active,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? StaffDashboardColors.accent : const Color(0xFFE6E8EA),
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        borderRadius: BorderRadius.circular(9999),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            border: selected
                ? null
                : Border.all(color: StaffDashboardColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: selected ? Colors.white : StaffDashboardColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'No bookings in this view.',
          style: TextStyle(fontSize: 14, color: StaffDashboardColors.muted),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Dashed "add a walk-in" slot at the end of the list.
class _AddSlotCard extends StatelessWidget {
  const _AddSlotCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {},
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: StaffDashboardColors.border,
          radius: 12,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFE6E8EA),
                child: Icon(Icons.add, color: StaffDashboardColors.muted),
              ),
              SizedBox(height: 12),
              Text(
                'New Booking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: StaffDashboardColors.muted,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manually enter a customer walk-in',
                style: TextStyle(fontSize: 14, color: Color(0xFF717785)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0873DF), Color(0xFF005AB4)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Peak Hours Approaching',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Evening slots are 90% booked. We recommend opening the '
            'secondary lounge area to accommodate walk-ins.',
            style: TextStyle(fontSize: 15, height: 1.4, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9999),
              child: InkWell(
                borderRadius: BorderRadius.circular(9999),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'Adjust Capacity',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: StaffDashboardColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a rounded-rect dashed border (Flutter has no built-in dashed border).
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;
  final double strokeWidth = 2;
  final double dashLength = 6;
  final double gapLength = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      strokeWidth != oldDelegate.strokeWidth;
}
