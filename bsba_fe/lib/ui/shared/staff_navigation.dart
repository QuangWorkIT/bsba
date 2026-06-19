import 'package:flutter/material.dart';

class StaffNavigation extends StatelessWidget {
  const StaffNavigation({
    super.key,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.onPrimaryActionPressed,
    this.chatBadgeCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final VoidCallback? onPrimaryActionPressed;
  final int chatBadgeCount;

  static const _primary = Color(0xFF005AB4);
  static const _border = Color(0xFFC1C6D5);
  static const _muted = Color(0xFF414753);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.14),
      child: SizedBox(
        height: 82,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Divider(height: 1, color: _border),
            ),
            Positioned.fill(
              top: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StaffNavItem(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    selected: selectedIndex == 0,
                    onTap: () => onDestinationSelected?.call(0),
                  ),
                  _StaffNavItem(
                    icon: Icons.storefront_outlined,
                    selectedIcon: Icons.storefront_rounded,
                    label: 'Store',
                    selected: selectedIndex == 1,
                    onTap: () => onDestinationSelected?.call(1),
                  ),
                  const SizedBox(width: 72),
                  _StaffNavItem(
                    icon: Icons.videogame_asset_outlined,
                    selectedIcon: Icons.videogame_asset_rounded,
                    label: 'Games',
                    selected: selectedIndex == 2,
                    onTap: () => onDestinationSelected?.call(2),
                  ),
                  _StaffNavItem(
                    icon: Icons.chat_outlined,
                    selectedIcon: Icons.chat_rounded,
                    label: 'Chat',
                    selected: selectedIndex == 3,
                    badgeCount: chatBadgeCount,
                    onTap: () => onDestinationSelected?.call(3),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -28,
              child: _StaffPrimaryActionButton(onPressed: onPrimaryActionPressed),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffPrimaryActionButton extends StatelessWidget {
  const _StaffPrimaryActionButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(6),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: StaffNavigation._primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

class _StaffNavItem extends StatelessWidget {
  const _StaffNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    this.badgeCount = 0,
    this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final int badgeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? StaffNavigation._primary : StaffNavigation._muted;
    final navIcon = Icon(selected ? selectedIcon : icon, color: color, size: 20);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 70,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            badgeCount > 0
                ? Badge(label: Text('$badgeCount'), child: navIcon)
                : navIcon,
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
