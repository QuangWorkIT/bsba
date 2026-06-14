import 'package:flutter/material.dart';

import '../../data/models/message.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/services/chat_socket_service.dart';
import '../../data/services/current_user.dart';
import '../../data/services/draft_store.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository;
  final ChatSocketService _socket;
  final DraftStore _draftStore;
  final String conversationId;
  final String userId;
  final String role;

  ChatViewModel(
    this._repository,
    this._socket, {
    required this.conversationId,
    DraftStore? draftStore,
  })  : userId = CurrentUser.instance.id,
        role = CurrentUser.instance.role,
        _draftStore = draftStore ?? DraftStore() {
    _socket.subscribeJson(
      '/topic/conversations/$conversationId/messages',
      (json) => _onIncoming(Message.fromJson(json)),
    );
    // Live read receipts: the other side read messages of this sender type.
    _socket.subscribeJson(
      '/topic/conversations/$conversationId/read',
      _onReadReceipt,
    );
    // Reflect connection status in the UI and resync after a dropped link.
    _socket.onStateChange = (connected) {
      if (connected && _wasConnected) {
        loadMessages(); // pull anything missed while offline
      }
      _wasConnected = _wasConnected || connected;
      notifyListeners();
    };
  }

  bool _wasConnected = false;
  bool get isLive => _socket.isConnected;

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

  // ── Drafts ───────────────────────────────────────────────────────────────
  /// Restore the unsent draft for this conversation, if any is still fresh.
  Future<String?> loadDraft() => _draftStore.read(conversationId);

  /// Persist the current draft (passing empty text clears it).
  void saveDraft(String text) => _draftStore.save(conversationId, text);

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

    // Optimistic message so the bubble and its sent-time show up instantly,
    // before the server round-trip completes.
    final tempId = 'temp-${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = Message(
      id: tempId,
      conversationId: conversationId,
      senderId: userId,
      senderType: role == 'CUSTOMER' ? 'CUSTOMER' : 'STAFF',
      content: text,
      createdAt: DateTime.now(),
    );
    _messages.add(optimistic);
    notifyListeners();

    try {
      final sent = await _repository.sendMessage(
        conversationId: conversationId,
        userId: userId,
        content: text,
        role: role,
      );
      // Reconcile the placeholder with the server's message (real id + time).
      // Fall back to the optimistic timestamp if the server omits createdAt.
      var reconciled = sent.createdAt == null
          ? sent.withCreatedAt(optimistic.createdAt)
          : sent;
      final idx = _messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        // The socket echo may have already delivered the real message.
        if (_messages.any((m) => m.id == sent.id)) {
          _messages.removeAt(idx);
        } else {
          // A "read" receipt may have landed on the placeholder before the POST
          // returned — keep it so the "Đã xem" doesn't flicker back off.
          if (_messages[idx].isRead) reconciled = reconciled.asRead();
          _messages[idx] = reconciled;
        }
      } else {
        _onIncoming(reconciled);
      }
      // Message is on its way — drop any saved draft for this thread.
      _draftStore.clear(conversationId);
    } catch (e) {
      // Drop the placeholder so a failed send doesn't linger in the thread.
      _messages.removeWhere((m) => m.id == tempId);
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

    // I'm sitting in this conversation, so a message from the other party is
    // seen immediately — ack it now so their "Đã xem" updates in real time.
    if (!isMine(message)) {
      markRead();
    }
  }

  /// The other party opened the chat and read messages of [readSenderType];
  /// flag those locally so the "Đã xem" receipt appears without a refresh.
  void _onReadReceipt(Map<String, dynamic> json) {
    final readSenderType = json['readSenderType'] as String?;
    if (readSenderType == null) return;

    var changed = false;
    for (var i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      if (m.senderType == readSenderType && !m.isRead) {
        _messages[i] = m.asRead();
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
