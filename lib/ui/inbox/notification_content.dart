import 'package:flutter/material.dart';
import 'package:project/ui/inbox/notification_card.dart';

class NotificationContent extends StatelessWidget {
  const NotificationContent({super.key});

  final notifications = const [
    {
      'title': 'Notification 1',
      'subtitle': 'This is the first notification.',
      'time': "2h ago",
      "icon": Icons.notifications,
    },
    {
      'title': 'Notification 2',
      'subtitle': 'This is the second notification.',
      'time': "1h ago",
      "icon": Icons.notifications,
    },

    {
      'title': 'Notification 3',
      'subtitle': 'This is the third notification.',
      'time': "30m ago",
      "icon": Icons.warning_amber,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                'Mark all as read',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              )
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return NotificationCard(
                  title: notification['title'] as String?,
                  subtitle: notification['subtitle'] as String?,
                  time: notification['time'] as String?,
                  icon: notification['icon'] as IconData?,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
