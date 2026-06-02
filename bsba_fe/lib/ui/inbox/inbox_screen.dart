import 'package:flutter/material.dart';
import 'package:project/ui/shared/inbox_tabbar.dart';
import 'package:project/ui/inbox/widgets/notification_content.dart';
import 'package:project/ui/inbox/widgets/inbox_content.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          InboxTabBar(),
          SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              children: [
                InboxContent(),
                NotificationContent(
                  userId: "fcc547c8-c843-4d46-9dc0-61630b9d8f5f",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
