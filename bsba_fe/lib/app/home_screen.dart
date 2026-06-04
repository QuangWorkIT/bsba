import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/data/repositories/chat_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/chat_service.dart';
import 'package:project/data/services/chat_socket_service.dart';
import 'package:project/ui/cart/cart_app_bar.dart';
import 'package:project/ui/shared/appbar.dart';
import 'package:project/ui/shared/navigation.dart';
import 'package:project/ui/explore/explore_space_screen.dart';
import 'package:project/ui/map/map_screen.dart';
import 'package:project/ui/cart/cart_screen.dart';
import 'package:project/ui/inbox/inbox_screen.dart';
import 'package:project/ui/inbox/unread_badge_viewmodel.dart';
import 'package:project/ui/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ExploreScreen(),
    MapScreen(),
    CartScreen(),
    InboxScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UnreadBadgeViewModel(
        ChatRepository(ChatService(ApiClient())),
        ChatSocketService(),
      )..start(),
      child: Scaffold(
        appBar: _selectedIndex == 2
            ? CartAppBar(onBack: () => setState(() => _selectedIndex = 0))
            : const BoardNestAppBar(),
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: Consumer<UnreadBadgeViewModel>(
          builder: (context, badge, _) => Navigation(
            selectedIndex: _selectedIndex,
            inboxBadgeCount: badge.count,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
