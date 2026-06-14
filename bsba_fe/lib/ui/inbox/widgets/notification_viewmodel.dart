import 'package:flutter/foundation.dart';
import 'package:project/data/models/notification.dart';
import 'package:project/data/repositories/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  NotificationViewModel({NotificationRepository? repository})
    : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;

  List<NotificationModel> _notifications = const [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;
  int _requestId = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNotifications(String userId) async {
    final requestId = ++_requestId;

    _isLoading = true;
    _errorMessage = null;
    _notifyListeners();

    try {
      final notifications = await _repository.getNotifications(userId);
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

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
