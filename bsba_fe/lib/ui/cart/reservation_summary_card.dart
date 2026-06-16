import 'package:flutter/material.dart';

class ReservationSummaryCard extends StatelessWidget {
  final String? storeName;
  final String? storeImage;
  final String? slotDate;
  final String? startTime;
  final String? endTime;

  const ReservationSummaryCard({
    super.key,
    this.storeName,
    this.storeImage,
    this.slotDate,
    this.startTime,
    this.endTime,
  });

  static Color _borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.outlineVariant
      : const Color(0xFFE0E2EB);
  static Color _imagePlaceholderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.surfaceContainerHighest
      : const Color(0xFFEBEDF7);
  static Color _bodyTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.onSurfaceVariant
      : const Color(0xFF414753);
  static Color _titleColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.onSurface
      : const Color(0xFF181C22);
  static Color _cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.surfaceContainer
      : Colors.white;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 173,
              color: _imagePlaceholderColor(context),
              alignment: Alignment.center,
              child: storeImage != null && storeImage!.isNotEmpty
                  ? Image.network(
                      storeImage!,
                      width: double.infinity,
                      height: 173,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: scheme.secondary.withValues(alpha: 0.5),
                      ),
                    )
                  : Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: scheme.secondary.withValues(alpha: 0.5),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  storeName ?? "Loading Store...",
                  style: TextStyle(
                    color: _titleColor(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Reserved',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.33,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailGrid(
            slotDate: slotDate,
            startTime: startTime,
            endTime: endTime,
          ),
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final String? slotDate;
  final String? startTime;
  final String? endTime;

  const _DetailGrid({this.slotDate, this.startTime, this.endTime});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: ReservationSummaryCard._bodyTextColor(context),
      fontSize: 14,
      height: 1.43,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: slotDate ?? 'Select Date',
                textStyle: textStyle,
              ),
            ),
            Expanded(
              child: _DetailRow(
                icon: Icons.schedule_outlined,
                label: (startTime != null && endTime != null)
                    ? '$startTime - $endTime'
                    : 'Select Time',
                textStyle: textStyle,
              ),
            ),
          ],
        ),
        // (keeps the players/price row for now as static or needs more back-end fields)
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DetailRow(
                icon: Icons.people_outline,
                label: '4 Players',
                textStyle: textStyle,
              ),
            ),
            Expanded(
              child: _DetailRow(
                icon: Icons.payments_outlined,
                label: r'$45.00 Base',
                textStyle: textStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.textStyle,
  });

  final IconData icon;
  final String label;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.secondary),
        const SizedBox(width: 8),
        Flexible(child: Text(label, style: textStyle)),
      ],
    );
  }
}
