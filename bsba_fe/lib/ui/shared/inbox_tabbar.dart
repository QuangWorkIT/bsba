import 'package:flutter/material.dart';

class InboxTabBar extends StatelessWidget {
  const InboxTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      tabs: [
        Tab(text: 'Inbox'),
        Tab(text: 'Notifications'),
      ],
    );
  }
}
