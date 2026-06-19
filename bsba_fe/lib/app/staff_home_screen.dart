import 'package:flutter/material.dart';
import 'package:project/ui/boardgame_store/store_screen.dart';
import 'package:provider/provider.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/chat_socket_service.dart';
import 'package:project/data/services/presence_service.dart';
import 'package:project/ui/dashboard/staff_dashboard.dart';
import 'package:project/ui/inbox/widgets/staff_chat_inbox.dart';
import 'package:project/ui/boardgames/staff_games.dart';
import 'package:project/ui/dashboard/templates/staff_store_template.dart';
import 'package:project/ui/presence/presence_viewmodel.dart';
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
      StaffGamesScreen(),
      StaffChatInbox(),
    ];

    return ChangeNotifierProvider(
      create: (_) => PresenceViewModel(
        PresenceService(ApiClient()),
        ChatSocketService(),
      )..start(),
      child: Scaffold(
        backgroundColor: StaffDashboardColors.background,
        appBar: const StaffDashboardHeader(),
        body: IndexedStack(index: _selectedIndex, children: screens),
        bottomNavigationBar: StaffNavigation(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectTab,
        ),
      ),
    );
  }
}
