import 'package:flutter/material.dart';
import 'package:project/ui/boardgame_store/store_screen.dart';
import 'package:project/ui/dashboard/staff_dashboard.dart';
import 'package:project/ui/dashboard/templates/staff_chat_template.dart';
import 'package:project/ui/dashboard/templates/staff_games_template.dart';
import 'package:project/ui/shared/staff_dashboard_header.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';
import 'package:project/ui/shared/staff_navigation.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const screens = <Widget>[
      StaffDashboard(),
      StoreScreen(),
      StaffGamesTemplate(),
      StaffChatTemplate(),
    ];

    return Scaffold(
      backgroundColor: StaffDashboardColors.background,
      appBar: const StaffDashboardHeader(),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: StaffNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
      ),
    );
  }
}
