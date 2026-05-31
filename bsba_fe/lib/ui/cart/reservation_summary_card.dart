import 'package:flutter/material.dart';

class ReservationSummaryCard extends StatelessWidget {
  const ReservationSummaryCard({super.key});

  static const _borderColor = Color(0xFFE0E2EB);
  static const _imagePlaceholderColor = Color(0xFFEBEDF7);
  static const _bodyTextColor = Color(0xFF414753);
  static const _titleColor = Color(0xFF181C22);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
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
              color: _imagePlaceholderColor,
              alignment: Alignment.center,
              child: Icon(
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
              const Expanded(
                child: Text(
                  "The Dragon's Lair -\nVIP Room",
                  style: TextStyle(
                    color: _titleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          const _DetailGrid(),
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid();

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: ReservationSummaryCard._bodyTextColor,
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
                label: 'Sat, Oct 28',
                textStyle: textStyle,
              ),
            ),
            Expanded(
              child: _DetailRow(
                icon: Icons.schedule_outlined,
                label: '2:00 PM - 5:00 PM',
                textStyle: textStyle,
              ),
            ),
          ],
        ),
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
