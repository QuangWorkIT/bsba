import 'package:flutter/material.dart';

class Navigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final int inboxBadgeCount;
  final bool inboxHasNotificationBadge;

  const Navigation({
    super.key,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.inboxBadgeCount = 0,
    this.inboxHasNotificationBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surfaceContainer
            : const Color(0xE0E2EBFF),
        indicatorColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.secondaryContainer
            : const Color(0xFFB6D0FF),
        elevation: 0,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: _InboxIcon(
              badgeCount: inboxBadgeCount,
              hasNotificationBadge: inboxHasNotificationBadge,
            ),
            label: 'Inbox',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _InboxIcon extends StatelessWidget {
  const _InboxIcon({
    required this.badgeCount,
    required this.hasNotificationBadge,
  });

  final int badgeCount;
  final bool hasNotificationBadge;

  @override
  Widget build(BuildContext context) {
    final icon = const Icon(Icons.chat_outlined);

    if (badgeCount > 0) {
      return Badge(label: Text('$badgeCount'), child: icon);
    }

    if (hasNotificationBadge) {
      return const Badge(
        smallSize: 8,
        child: Icon(Icons.chat_outlined),
      );
    }

    return icon;
  }
}
