import 'package:flutter/material.dart';

import 'chat_staff_bubble.dart';

/// Animated-looking "staff is typing" bubble with three dots.
class ChatTypingIndicator extends StatelessWidget {
  const ChatTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Opacity(
      opacity: 0.7,
      child: ChatStaffBubble(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(),
            SizedBox(width: 4),
            _Dot(),
            SizedBox(width: 4),
            _Dot(),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Color(0xFF717785),
        shape: BoxShape.circle,
      ),
    );
  }
}
