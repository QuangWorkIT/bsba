import 'package:flutter/material.dart';

/// AppBar for the chat screen showing the contact avatar, name and status.
class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  const ChatHeader({
    super.key,
    required this.name,
    required this.subtitle,
    this.isOnline = false,
  });

  final String name;
  final String subtitle;

  /// Whether the other party currently has a live connection (green vs grey dot).
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 44,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF414753)),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        children: [
          _AvatarWithStatus(name: name, isOnline: isOnline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF181C22),
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF414753)),
          onPressed: () {},
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E2EB)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

class _AvatarWithStatus extends StatelessWidget {
  const _AvatarWithStatus({required this.name, required this.isOnline});

  final String name;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: primary.withValues(alpha: 0.12),
            child: Text(
              initial,
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                // Green when the other party is connected, grey when offline.
                color: isOnline
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF9CA3AF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
