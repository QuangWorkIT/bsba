import 'package:flutter/material.dart';
import 'package:project/ui/inbox/widgets/chat_item.dart';
import 'package:project/ui/inbox/widgets/chat_screen.dart';

class InboxContent extends StatelessWidget {
  const InboxContent({super.key});

  final chats = const [
    {
      'name': 'Sarah M. (Game Master)',
      'message':
          "Your character sheet for the 'Echoes of Valoria' campaign looks great! Just one small tweak...",
      'time': '12:45 PM',
      'unread': 2,
    },
    {
      'name': 'Alex Rivers',
      'message': "I'll be there by 6 PM. Bringing the custom dice sets!",
      'time': 'Yesterday',
      'unread': 0,
    },
    {
      'name': 'Dungeon Master Joe',
      'message':
          'Are we still on for the Friday night session? We need to finalize the map layouts.',
      'time': 'Tuesday',
      'unread': 0,
    },
    {
      'name': 'Elena (Paladin)',
      'message':
          "That critical hit you landed was legendary! Let's talk about the loot distribution.",
      'time': 'Oct 12',
      'unread': 0,
    },
    {
      'name': 'Tabletop Haven Support',
      'message':
          "Your booking for 'The Crystal Vault' has been confirmed. View details here.",
      'time': 'Oct 10',
      'unread': 0,
      'icon': Icons.support_agent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _SearchField(),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ChatItem(
                    name: chat['name'] as String,
                    message: chat['message'] as String,
                    time: chat['time'] as String,
                    unreadCount: chat['unread'] as int,
                    icon: chat['icon'] as IconData?,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatScreen(name: chat['name'] as String),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 24,
          bottom: 24,
          child: Material(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            elevation: 6,
            shadowColor: Colors.black26,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.add, color: Colors.white, size: 26),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search messages...',
        hintStyle: const TextStyle(color: Color(0xFFC1C6D5), fontSize: 14),
        prefixIcon:
            const Icon(Icons.search, color: Color(0xFF717785), size: 20),
        filled: true,
        fillColor: const Color(0xFFF1F3FC),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC1C6D5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC1C6D5)),
        ),
      ),
    );
  }
}
