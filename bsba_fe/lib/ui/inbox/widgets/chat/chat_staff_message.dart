import 'package:flutter/material.dart';

import 'chat_staff_bubble.dart';

/// A plain text message sent by the staff member.
class ChatStaffMessage extends StatelessWidget {
  const ChatStaffMessage({
    super.key,
    required this.time,
    required this.message,
  });

  final String time;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ChatStaffBubble(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: Color(0xFF717785)),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.43,
              color: Color(0xFF181C22),
            ),
          ),
        ],
      ),
    );
  }
}
