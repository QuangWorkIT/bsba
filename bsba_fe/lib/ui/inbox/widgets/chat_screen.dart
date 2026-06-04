import 'package:flutter/material.dart';

import 'chat/chat_date_divider.dart';
import 'chat/chat_header.dart';
import 'chat/chat_input_area.dart';
import 'chat/chat_staff_message.dart';
import 'chat/chat_staff_message_with_card.dart';
import 'chat/chat_typing_indicator.dart';
import 'chat/chat_user_message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    this.name = 'Sarah M.',
    this.subtitle = 'Game Master • Online',
  });

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3FC),
      appBar: ChatHeader(name: name, subtitle: subtitle),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                ChatDateDivider(text: 'Today, 2:14 PM'),
                SizedBox(height: 24),
                ChatStaffMessage(
                  time: 'Sarah • 2:14 PM',
                  message:
                      'Hi there! I see you have a reservation for a table of 4 at 7:00 PM tonight. Would you like me to pre-load any specific board games at your table so they are ready when you arrive?',
                ),
                SizedBox(height: 24),
                ChatUserMessage(
                  text: "Yes, please! We definitely want to play 'Settlers of Catan'.",
                ),
                SizedBox(height: 24),
                ChatStaffMessageWithCard(
                  time: 'Sarah • 2:18 PM',
                  message:
                      "Great choice. I've placed the base game at Table 4 for you. We also have the 'Seafarers' expansion available right now. Shall I add that to your reservation for an extra \$5?",
                ),
                SizedBox(height: 24),
                ChatUserMessage(
                  text: "Actually, let's just stick to the base game for now. Thanks!",
                  readReceipt: 'Read • 2:20 PM',
                ),
                SizedBox(height: 24),
                ChatTypingIndicator(),
              ],
            ),
          ),
          const ChatInputArea(),
        ],
      ),
    );
  }
}
