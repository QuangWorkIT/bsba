import 'package:flutter/material.dart';

/// Right-aligned chat bubble for messages sent by the current user.
class ChatUserMessage extends StatelessWidget {
  const ChatUserMessage({
    super.key,
    required this.text,
    this.time,
    this.readReceipt,
  });

  final String text;
  final String? time;
  final String? readReceipt;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                text,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.43,
                  color: Colors.white,
                ),
              ),
              if (time != null && time!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    time!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFE3ECFF),
                    ),
                  ),
                ),
              ],
              if (readReceipt != null) ...[
                const SizedBox(height: 4),
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    readReceipt!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFAAC7FF),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
