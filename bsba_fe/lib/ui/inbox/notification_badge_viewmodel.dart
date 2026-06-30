import 'package:flutter/foundation.dart';
import 'package:project/data/models/notification.dart';
import 'package:project/data/services/chat_socket_service.dart';
import 'package:project/data/services/current_user.dart';

class NotificationBadgeViewModel extends ChangeNotifier {
  NotificationBadgeViewModel({ChatSocketService? socket})
    : _socket = socket ?? ChatSocketService() {
    _socket.subscribeJson('/topic/notifications', _onIncomingNotification);
  }

  final ChatSocketService _socket;

  bool _hasUnreadNotification = false;
  bool _isViewingNotifications = false;

  bool get hasUnreadNotification => _hasUnreadNotification;

  Future<void> start() async {
    await _socket.connect();
  }

  void setViewingNotifications(bool isViewing) {
    if (_isViewingNotifications == isViewing) return;

    _isViewingNotifications = isViewing;
    if (isViewing && _hasUnreadNotification) {
      _hasUnreadNotification = false;
      notifyListeners();
    }
  }

  void _onIncomingNotification(Map<String, dynamic> json) {
    try {
      final notification = NotificationModel.fromJson(json);
      if (_normalizeUserId(notification.userId) !=
          _normalizeUserId(CurrentUser.instance.id)) {
        return;
      }

      if (_isViewingNotifications) return;
      if (_hasUnreadNotification) return;

      _hasUnreadNotification = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to parse notification badge payload: $e');
    }
  }

  String _normalizeUserId(String userId) {
    return userId.trim().toLowerCase();
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
