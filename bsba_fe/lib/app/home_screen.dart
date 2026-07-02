import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/data/repositories/chat_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/chat_service.dart';
import 'package:project/data/services/chat_socket_service.dart';
import 'package:project/data/services/current_user.dart';
import 'package:project/app/staff_home_screen.dart';
import 'package:project/ui/shared/appbar.dart';
import 'package:project/ui/shared/navigation.dart';
import 'package:project/ui/explore/explore_space_screen.dart';
import 'package:project/ui/map/map_screen.dart';
import 'package:project/ui/booking/booking_screen.dart';
import 'package:project/ui/booking/booking_viewmodel.dart';
import 'package:project/ui/inbox/inbox_screen.dart';
import 'package:project/ui/inbox/notification_badge_viewmodel.dart';
import 'package:project/ui/inbox/unread_badge_viewmodel.dart';
import 'package:project/ui/presence/presence_viewmodel.dart';
import 'package:project/data/services/presence_service.dart';
import 'package:project/ui/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialIndex = 0,
    this.initialBookingTab = BookingTab.completed,
  });

  final int initialIndex;
  final BookingTab initialBookingTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _inboxIndex = 3;
  static const int _bookingIndex = 2;
  late int _selectedIndex;
  int _bookingRefreshTrigger = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _select(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final role = CurrentUser.instance.role.toUpperCase();
    final isStaff = role == 'STAFF' || role == 'ADMIN';

    if (isStaff) {
      return const StaffHomeScreen();
    }

    final screens = <Widget>[
      ExploreScreen(onOpenInbox: () => _select(_inboxIndex)),
      const MapScreen(),
      BookingScreen(
        active: _selectedIndex == _bookingIndex,
        refreshTrigger: _bookingRefreshTrigger,
        initialTab: widget.initialBookingTab,
      ),
      InboxScreen(active: _selectedIndex == _inboxIndex),
      const ProfileScreen(),
    ];

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UnreadBadgeViewModel(
            ChatRepository(ChatService(ApiClient())),
            ChatSocketService(),
          )..start(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationBadgeViewModel(
            socket: ChatSocketService(),
          )..start(),
        ),
        ChangeNotifierProvider(
          create: (_) => PresenceViewModel(
            PresenceService(ApiClient()),
            ChatSocketService(),
          )..start(),
        ),
      ],
      child: Scaffold(
        appBar: _selectedIndex == 2 ? null : const BoardNestAppBar(),
        body: IndexedStack(index: _selectedIndex, children: screens),
        bottomNavigationBar: Consumer2<UnreadBadgeViewModel, NotificationBadgeViewModel>(
          builder: (context, badge, notificationBadge, _) => Navigation(
            selectedIndex: _selectedIndex,
            inboxBadgeCount: badge.count,
            inboxHasNotificationBadge:
                notificationBadge.hasUnreadNotification,
            onDestinationSelected: (index) {
              setState(() {
                if (index == _bookingIndex) {
                  _bookingRefreshTrigger++;
                }
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
