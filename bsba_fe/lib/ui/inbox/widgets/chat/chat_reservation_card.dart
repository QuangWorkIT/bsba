import 'package:flutter/material.dart';

/// Card advertising an add-on (e.g. a game expansion) inside a staff message.
class ChatReservationCard extends StatelessWidget {
  const ChatReservationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC1C6D5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              border: Border.all(color: const Color(0xFFE0E2EB)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.extension, color: primary),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catan: Seafarers Expansion',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.33,
                    color: Color(0xFF181C22),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '+ 5.00 VND table fee',
                  style: TextStyle(fontSize: 13, color: Color(0xFF414753)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _AddButton(primary: primary),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {},
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 12, color: Color(0xFFFEFCFF)),
              SizedBox(width: 4),
              Text(
                'Add',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFEFCFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
