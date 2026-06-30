import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/inbox/notification_badge_viewmodel.dart';
import 'package:project/ui/inbox/widgets/notification_viewmodel.dart';
import 'package:project/ui/inbox/widgets/notification_card.dart';

class NotificationContent extends StatefulWidget {
  const NotificationContent({super.key, required this.userId});

  final String userId;

  @override
  State<NotificationContent> createState() => _NotificationContentState();
}

class _NotificationContentState extends State<NotificationContent> {
  final NotificationViewModel _viewModel = NotificationViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.start(widget.userId);
  }

  @override
  void didUpdateWidget(covariant NotificationContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _viewModel.start(widget.userId);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  String _formatTime(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _viewModel.hasUnreadNotifications &&
                            !_viewModel.isMarkingAsRead
                        ? _markAllAsRead
                        : null,
                    icon: _viewModel.isMarkingAsRead
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.done_all),
                    label: const Text('Mark as read'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody()),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markAllAsRead() async {
    final success = await _viewModel.markAllAsRead();
    if (!mounted) return;

    if (success) {
      await context.read<NotificationBadgeViewModel>().refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications marked as read.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No unread notifications to update.')),
      );
    }
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(_viewModel.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _viewModel.loadNotifications(widget.userId),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_viewModel.notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text('No notifications yet.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _viewModel.loadNotifications(widget.userId),
      child: ListView.builder(
        itemCount: _viewModel.notifications.length,
        itemBuilder: (context, index) {
          final notification = _viewModel.notifications[index];

          return NotificationCard(
            title: notification.title,
            subtitle: notification.body,
            time: _formatTime(notification.createdAt),
            isRead: notification.isRead,
            icon: notification.type == 'SYSTEM'
                ? Icons.warning_amber
                : Icons.notifications,
          );
        },
      ),
    );
  }
}
