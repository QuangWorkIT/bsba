import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/inbox/notification_badge_viewmodel.dart';
import 'package:project/ui/shared/inbox_tabbar.dart';
import 'package:project/ui/inbox/widgets/notification_content.dart';
import 'package:project/ui/inbox/widgets/inbox_content.dart';
import 'package:project/data/services/current_user.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key, required this.active});

  final bool active;

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with SingleTickerProviderStateMixin {
  static const int _notificationsTabIndex = 1;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_syncNotificationVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncNotificationVisibility();
    });
  }

  @override
  void didUpdateWidget(covariant InboxScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _syncNotificationVisibility();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_syncNotificationVisibility);
    _tabController.dispose();
    super.dispose();
  }

  void _syncNotificationVisibility() {
    if (!mounted) return;
    context.read<NotificationBadgeViewModel>().setViewingNotifications(
      widget.active && _tabController.index == _notificationsTabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          return Column(
            children: [
              InboxTabBar(controller: _tabController),
              SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    InboxContent(),
                    NotificationContent(
                      userId: CurrentUser.instance.id,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
