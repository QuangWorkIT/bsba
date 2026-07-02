import 'package:flutter/material.dart';
import 'package:project/data/models/booking_summary.dart';
import 'package:project/ui/cart/cart_screen.dart';
import 'package:project/ui/booking/widgets/booking_qr_dialog.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});

  final BookingSummary booking;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BookingImage(booking: booking),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    booking.title,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 24,
                      height: 32 / 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _LocationRow(location: booking.location),
                  const SizedBox(height: 16),
                  _BookingFacts(booking: booking),
                  const SizedBox(height: 16),
                  _BookingActions(booking: booking),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingImage extends StatelessWidget {
  const _BookingImage({required this.booking});

  final BookingSummary booking;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 192,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (booking.imageAsset.isNotEmpty)
            Image.network(
              booking.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _BookingImagePlaceholder(
                color: scheme.secondary.withValues(alpha: 0.5),
              ),
            )
          else
            _BookingImagePlaceholder(
              color: scheme.secondary.withValues(alpha: 0.5),
            ),
          Positioned(top: 11, right: 16, child: _BookingBadge(booking)),
        ],
      ),
    );
  }
}

class _BookingImagePlaceholder extends StatelessWidget {
  const _BookingImagePlaceholder({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.image_outlined, size: 48, color: color),
      ),
    );
  }
}

class _BookingBadge extends StatelessWidget {
  const _BookingBadge(this.booking);

  final BookingSummary booking;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        booking.badgeLabel(),
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 16, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _BookingFacts extends StatelessWidget {
  const _BookingFacts({required this.booking});

  final BookingSummary booking;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _BookingFact(
                  icon: Icons.calendar_today_outlined,
                  label: 'DATE',
                  value: booking.date,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BookingFact(
                  icon: Icons.schedule,
                  label: 'TIME',
                  value: booking.time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _BookingFact(
                  icon: Icons.groups_outlined,
                  label: 'PLAYERS',
                  value: booking.players,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BookingFact(
                  icon: Icons.credit_card_outlined,
                  label: 'TOTAL',
                  value: booking.total,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingFact extends StatelessWidget {
  const _BookingFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 10,
                  height: 1,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingActions extends StatelessWidget {
  const _BookingActions({required this.booking});

  final BookingSummary booking;

  void _showDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(
          bookingId: booking.id,
          bookingStatus: booking.status,
        ),
      ),
    );
  }

  void _showQrCode(BuildContext context) {
    if (booking.qrCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code is not available.')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => BookingQrDialog(
        bookingTitle: booking.title,
        qrCode: booking.qrCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showQrCode = booking.status == BookingStatus.confirmed;

    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () => _showDetails(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('View Details'),
          ),
        ),
        if (showQrCode) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            height: 50,
            child: OutlinedButton(
              onPressed: () => _showQrCode(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.qr_code),
            ),
          ),
        ],
      ],
    );
  }
}
