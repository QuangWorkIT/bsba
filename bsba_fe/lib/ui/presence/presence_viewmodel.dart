import 'package:flutter/material.dart';

import '../../data/services/chat_socket_service.dart';
import '../../data/services/current_user.dart';
import '../../data/services/presence_service.dart';

/// App-wide online presence: announces the logged-in user as online over the
/// socket and tracks which other users are connected, so chat lists can show a
/// real online dot. Provide one high in the tree (per home screen) so it stays
/// alive while the user is in the app.
class PresenceViewModel extends ChangeNotifier {
  final PresenceService _service;
  final ChatSocketService _socket;
  final String _userId;

  final Set<String> _online = {};

  PresenceViewModel(this._service, this._socket)
      : _userId = CurrentUser.instance.id {
    _socket.subscribeJson('/topic/presence', _onPresenceEvent);
    // Re-announce on every (re)connect so a dropped socket doesn't leave us
    // looking offline to everyone else after it comes back.
    _socket.onStateChange = (connected) {
      if (connected) _announceSelf();
    };
  }

  /// Is this single user online?
  bool isOnline(String? userId) => userId != null && _online.contains(userId);

  /// Is *any* of these users online? Used for "the store is online" (any staff).
  bool anyOnline(Iterable<String>? userIds) =>
      userIds != null && userIds.any(_online.contains);

  Future<void> start() async {
    try {
      _online.addAll(await _service.fetchOnlineUserIds());
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading presence snapshot: $e');
    }
    await _socket.connect();
  }

  void _announceSelf() => _socket.send('/app/presence', {'userId': _userId});

  void _onPresenceEvent(Map<String, dynamic> json) {
    final id = json['userId']?.toString();
    if (id == null) return;
    final isOnline = json['online'] == true;
    final changed = isOnline ? _online.add(id) : _online.remove(id);
    if (changed) notifyListeners();
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
