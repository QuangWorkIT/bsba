import 'package:flutter/foundation.dart';
import 'package:project/data/repositories/notification_repository.dart';
import 'package:project/data/services/chat_socket_service.dart';
import 'package:project/data/services/current_user.dart';

class NotificationBadgeViewModel extends ChangeNotifier {
  NotificationBadgeViewModel({
    ChatSocketService? socket,
    NotificationRepository? repository,
  })  : _socket = socket ?? ChatSocketService(),
        _repository = repository ?? NotificationRepository() {
    _socket.subscribeJson('/topic/notifications', _onIncomingNotification);
  }

  final ChatSocketService _socket;
  final NotificationRepository _repository;

  bool _hasUnreadNotification = false;
  int _requestId = 0;
  bool _isDisposed = false;

  bool get hasUnreadNotification => _hasUnreadNotification;

  Future<void> start() async {
    await refresh();
    await _socket.connect();
  }

  void setViewingNotifications(bool _) {
    refresh();
  }

  Future<void> refresh() async {
    final requestId = ++_requestId;

    try {
      final notifications = await _repository.getNotifications(
        CurrentUser.instance.id,
      );
      if (_isDisposed || requestId != _requestId) return;

      final hasUnread = notifications.any((notification) {
        return !notification.isRead;
      });
      if (_hasUnreadNotification != hasUnread) {
        _hasUnreadNotification = hasUnread;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading notification unread badge: $e');
    }
  }

  void _onIncomingNotification(Map<String, dynamic> json) {
    final payload = _unwrapPayload(json);
    final notificationUserId = _extractUserId(payload);
    final currentUserId = _normalizeUserId(CurrentUser.instance.id);

    if (notificationUserId == null) {
      debugPrint('Notification badge payload missing userId: $json');
      return;
    }

    if (_normalizeUserId(notificationUserId) != currentUserId) return;

    final isRead = payload['isRead'];
    if (isRead == false && !_hasUnreadNotification) {
      _hasUnreadNotification = true;
      notifyListeners();
    }

    refresh();
  }

  Map<String, dynamic> _unwrapPayload(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    return json;
  }

  String? _extractUserId(Map<String, dynamic> json) {
    final userId = json['userId'];
    if (userId != null) return userId.toString();

    final user = json['user'];
    if (user is Map<String, dynamic>) {
      final nestedId = user['id'] ?? user['userId'];
      if (nestedId != null) return nestedId.toString();
    }

    return null;
  }

  String _normalizeUserId(String userId) {
    return userId.trim().toLowerCase();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _socket.disconnect();
    super.dispose();
  }
}
