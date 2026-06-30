import 'package:flutter/material.dart';

class InboxTabBar extends StatelessWidget {
  const InboxTabBar({super.key, this.controller});

  final TabController? controller;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      tabs: [
        Tab(text: 'Inbox'),
        Tab(text: 'Notifications'),
      ],
    );
  }
}
