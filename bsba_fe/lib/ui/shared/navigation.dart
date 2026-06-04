import 'package:flutter/material.dart';

class Navigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final int inboxBadgeCount;

  const Navigation({
    super.key,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.inboxBadgeCount = 0,
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
        backgroundColor: const Color(0xE0E2EBFF),
        indicatorColor: const Color(0xFFB6D0FF),
        elevation: 0,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.search), label: 'Explore'),
          const NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
          const NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: inboxBadgeCount > 0
                ? Badge(
                    label: Text('$inboxBadgeCount'),
                    child: const Icon(Icons.chat_outlined),
                  )
                : const Icon(Icons.chat_outlined),
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
