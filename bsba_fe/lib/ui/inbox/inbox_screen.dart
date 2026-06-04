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
                  userId: "5eba0910-f0d5-4afd-baa5-ab328b71dec8",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
