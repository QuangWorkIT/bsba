import 'package:flutter/material.dart';

import '../../data/models/message.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/services/chat_socket_service.dart';
import 'inbox_viewmodel.dart' show kDemoRole;

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository;
  final ChatSocketService _socket;
  final String conversationId;
  final String userId;
  final String role;

  ChatViewModel(
    this._repository,
    this._socket, {
    required this.conversationId,
    required this.userId,
    this.role = kDemoRole,
  }) {
    _socket.subscribeJson(
      '/topic/conversations/$conversationId/messages',
      (json) => _onIncoming(Message.fromJson(json)),
    );
  }

  // ── State (messages kept oldest → newest) ──────────────────────────────────
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  bool get isEmpty => !_isLoading && _error == null && _messages.isEmpty;

  /// The current viewer's own messages sit on the right.
  bool isMine(Message m) {
    final mySenderType = role == 'CUSTOMER' ? 'CUSTOMER' : 'STAFF';
    return m.senderType == mySenderType;
  }

  /// Id of the most recent message I sent that has been read by the other side.
  /// Only this one shows a "Đã xem" receipt, so the thread isn't cluttered.
  String? get lastReadMineId {
    for (final m in _messages.reversed) {
      if (isMine(m) && m.isRead) return m.id;
    }
    return null;
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  Future<void> start() async {
    await loadMessages();
    _socket.connect();
    markRead();
  }

  Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Backend returns newest-first; flip to oldest-first for display.
      final page = await _repository.fetchMessages(
        conversationId: conversationId,
      );
      _messages = page.reversed.toList();
    } catch (e) {
      _error = 'Failed to load messages. Make sure the backend is running.';
      debugPrint('Error loading messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    final text = content.trim();
    if (text.isEmpty || _isSending) return;

    _isSending = true;
    notifyListeners();

    try {
      final sent = await _repository.sendMessage(
        conversationId: conversationId,
        userId: userId,
        content: text,
        role: role,
      );
      // The socket will also echo this; _onIncoming dedupes by id.
      _onIncoming(sent);
    } catch (e) {
      _error = 'Failed to send message.';
      debugPrint('Error sending message: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> markRead() async {
    try {
      await _repository.markRead(
        conversationId: conversationId,
        userId: userId,
        role: role,
      );
    } catch (e) {
      debugPrint('Error marking read: $e');
    }
  }

  // ── Realtime ─────────────────────────────────────────────────────────────
  void _onIncoming(Message message) {
    if (_messages.any((m) => m.id == message.id)) return; // dedupe POST + echo
    _messages.add(message);
    notifyListeners();
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
