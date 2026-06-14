import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/booking/booking_viewmodel.dart';
import 'package:project/ui/booking/widgets/booking_card.dart';

class BookingContentState extends StatelessWidget {
  const BookingContentState({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BookingViewModel>();

    return switch (viewModel.state) {
      BookingLoadState.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      BookingLoadState.error => _BookingError(
        message: viewModel.errorMessage ?? 'Unable to load bookings.',
        onRetry: viewModel.retry,
      ),
      BookingLoadState.loaded =>
        viewModel.visibleBookings.isEmpty
            ? const _EmptyBookings()
            : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: viewModel.visibleBookings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 24),
                itemBuilder: (context, index) =>
                    BookingCard(booking: viewModel.visibleBookings[index]),
              ),
    };
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined, size: 48, color: scheme.primary),
            const SizedBox(height: 12),
            Text(
              'No bookings in this category',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingError extends StatelessWidget {
  const _BookingError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
