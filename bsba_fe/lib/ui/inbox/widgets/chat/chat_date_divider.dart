import 'package:flutter/material.dart';

/// Pill-shaped divider showing the date/time of a group of messages.
class ChatDateDivider extends StatelessWidget {
  const ChatDateDivider({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E8F1),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF414753),
          ),
        ),
      ),
    );
  }
}
