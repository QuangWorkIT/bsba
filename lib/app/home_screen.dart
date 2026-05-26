import 'package:flutter/material.dart';
import 'package:project/ui/shared/appbar.dart';
import 'package:project/ui/shared/navigation.dart';
import 'package:project/ui/home/explore_screen.dart';
import 'package:project/ui/map/map_screen.dart';
import 'package:project/ui/cart/cart_screen.dart';
import 'package:project/ui/inbox/inbox_screen.dart';
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
    return Scaffold(
      appBar: const BoardNestAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Navigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
