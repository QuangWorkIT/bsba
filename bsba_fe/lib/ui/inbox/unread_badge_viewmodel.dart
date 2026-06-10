import 'package:flutter/material.dart';

import '../../data/repositories/chat_repository.dart';
import '../../data/services/chat_socket_service.dart';
import '../../data/services/current_user.dart';

/// Drives the unread badge on the Inbox tab. Loads the count once, then
/// re-fetches whenever a conversation row is pushed over the socket (new
/// message, or messages marked read).
class UnreadBadgeViewModel extends ChangeNotifier {
  final ChatRepository _repository;
  final ChatSocketService _socket;
  final String userId;
  final String role;

  UnreadBadgeViewModel(
    this._repository,
    this._socket,
  )   : userId = CurrentUser.instance.id,
        role = CurrentUser.instance.role {
    _socket.subscribeJson(
      '/topic/users/$userId/conversations',
      (_) => refresh(),
    );
  }

  int _count = 0;
  int get count => _count;

  Future<void> start() async {
    await refresh();
    _socket.connect();
  }

  Future<void> refresh() async {
    try {
      _count = await _repository.fetchUnreadCount(userId: userId, role: role);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
