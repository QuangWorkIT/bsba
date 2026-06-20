import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.draft,
    this.unreadCount = 0,
    this.isOnline = false,
    this.icon,
    this.onTap,
  });

  final String name;
  final String message;
  final String time;

  /// Whether the other party is currently connected (drives the green dot).
  final bool isOnline;

  /// Unsent draft for this thread; when set, it replaces [message] in the
  /// preview with a "Chưa gửi" marker.
  final String? draft;
  final int unreadCount;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = unreadCount > 0;
    final hasDraft = draft != null && draft!.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEBEDF7))),
        ),
        child: Row(
        children: [
          _Avatar(name: name, icon: icon, isOnline: isOnline),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF181C22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isUnread ? FontWeight.bold : FontWeight.w500,
                        color: isUnread
                            ? theme.colorScheme.primary
                            : const Color(0xFF414753),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: hasDraft
                          ? Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Chưa gửi: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.tertiary,
                                    ),
                                  ),
                                  TextSpan(text: draft!.trim()),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF414753),
                              ),
                            )
                          : Text(
                              message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isUnread ? FontWeight.w500 : FontWeight.w400,
                                color: isUnread
                                    ? const Color(0xFF181C22)
                                    : const Color(0xFF414753),
                              ),
                            ),
                    ),
                    if (isUnread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.icon, this.isOnline = false});

  final String name;
  final IconData? icon;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget avatar;
    if (icon != null) {
      avatar = CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFFB6D0FF),
        child: Icon(icon, color: const Color(0xFF3F5881)),
      );
    } else {
      final initial =
          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
      avatar = CircleAvatar(
        radius: 28,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    // Always show the dot: green when connected, grey when offline.
    return Stack(
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF9CA3AF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
