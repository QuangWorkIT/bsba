import 'package:flutter/material.dart';

class BoardNestAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BoardNestAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appBarTheme = Theme.of(context).appBarTheme;

    return AppBar(
      backgroundColor: appBarTheme.backgroundColor,
      elevation: appBarTheme.elevation,
      centerTitle: appBarTheme.centerTitle,
      title: Text('BoardNest', style: appBarTheme.titleTextStyle),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
