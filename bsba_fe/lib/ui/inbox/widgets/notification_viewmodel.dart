import 'package:flutter/foundation.dart';
import 'package:project/data/models/notification.dart';
import 'package:project/data/repositories/notification_repository.dart';
import 'package:project/data/services/chat_socket_service.dart';
import 'package:project/data/services/current_user.dart';

class NotificationViewModel extends ChangeNotifier {
  NotificationViewModel({
    NotificationRepository? repository,
    ChatSocketService? socket,
  })  : _repository = repository ?? NotificationRepository(),
        _socket = socket ?? ChatSocketService();

  final NotificationRepository _repository;
  final ChatSocketService _socket;

  List<NotificationModel> _notifications = const [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;
  int _requestId = 0;
  String? _activeUserId;
  bool _wasConnected = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLive => _socket.isConnected;

  Future<void> start(String userId) async {
    final currentUserId = _verifiedCurrentUserId(userId);

    if (_activeUserId != currentUserId) {
      _activeUserId = currentUserId;
      _wasConnected = false;
      _socket.disconnect();
      _socket.subscribeJson('/topic/notifications', _onIncomingNotification);
      _socket.onStateChange = (connected) {
        if (_isDisposed) return;
        if (connected && _wasConnected && _activeUserId != null) {
          loadNotifications(_activeUserId!);
        }
        _wasConnected = _wasConnected || connected;
        _notifyListeners();
      };
    }

    await loadNotifications(currentUserId);
    await _socket.connect();
  }

  Future<void> loadNotifications(String userId) async {
    final verifiedUserId = _verifiedCurrentUserId(userId);
    final requestId = ++_requestId;

    _isLoading = true;
    _errorMessage = null;
    _notifyListeners();

    try {
      final notifications = await _repository.getNotifications(verifiedUserId);
      if (_isDisposed || requestId != _requestId) return;

      _notifications = notifications;
    } catch (_) {
      if (_isDisposed || requestId != _requestId) return;

      _errorMessage = 'Failed to load notifications. Please try again.';
    } finally {
      if (!_isDisposed && requestId == _requestId) {
        _isLoading = false;
        _notifyListeners();
      }
    }
  }

  void _onIncomingNotification(Map<String, dynamic> json) {
    if (_isDisposed) return;

    try {
      final notification = NotificationModel.fromJson(json);
      final notificationUserId = _normalizeUserId(notification.userId);
      final currentUserId = _normalizeUserId(CurrentUser.instance.id);
      if (notificationUserId != currentUserId ||
          currentUserId != _activeUserId) {
        return;
      }

      final index = _notifications.indexWhere((item) {
        return item.id == notification.id;
      });
      if (index >= 0) {
        _notifications = [
          ..._notifications.take(index),
          notification,
          ..._notifications.skip(index + 1),
        ];
      } else {
        _notifications = [notification, ..._notifications];
      }

      _notifications = [..._notifications]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _notifyListeners();
    } catch (e) {
      debugPrint('Failed to parse notification payload: $e');
    }
  }

  String _verifiedCurrentUserId(String requestedUserId) {
    final currentUserId = _normalizeUserId(CurrentUser.instance.id);
    final normalizedRequestedUserId = _normalizeUserId(requestedUserId);
    if (normalizedRequestedUserId != currentUserId) {
      debugPrint(
        'Notification userId mismatch: requested=$normalizedRequestedUserId, '
        'current=$currentUserId',
      );
    }
    return currentUserId;
  }

  String _normalizeUserId(String userId) {
    return userId.trim().toLowerCase();
  }

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _socket.disconnect();
    super.dispose();
  }
}
