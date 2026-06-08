import 'package:flutter/material.dart';

import '../../data/models/conversation.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/services/chat_socket_service.dart';
import '../../data/services/draft_store.dart';

/// TODO: replace with the authenticated user's id once login is wired up.
/// Use a UUID that exists in the `users` table (seed one for the demo).
const String kDemoUserId = 'a0000000-0000-0000-0000-000000000007';

/// Single knob for the demo role. Flip between 'CUSTOMER' / 'STAFF' / 'ADMIN'
/// here to test each side — used by both the inbox and the chat screen.
const String kDemoRole = 'STAFF';

class InboxViewModel extends ChangeNotifier {
  final ChatRepository _repository;
  final ChatSocketService _socket;
  final DraftStore _draftStore;
  final String userId;
  final String role;

  InboxViewModel(
    this._repository,
    this._socket, {
    this.userId = kDemoUserId,
    this.role = kDemoRole,
    DraftStore? draftStore,
  }) : _draftStore = draftStore ?? DraftStore() {
    _socket.subscribeJson(
      '/topic/users/$userId/conversations',
      (json) => _applyRealtimeUpdate(Conversation.fromJson(json)),
    );
  }

  // ── State ──────────────────────────────────────────────────────────────────
  List<Conversation> _conversations = [];
  Map<String, String> _drafts = {};
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  /// Unsent draft for a conversation, if one is still saved (else null).
  String? draftFor(String conversationId) => _drafts[conversationId];

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => !_isLoading && _error == null && _conversations.isEmpty;
  bool get isLive => _socket.isConnected;

  List<Conversation> get conversations {
    if (_searchQuery.isEmpty) return _conversations;
    final q = _searchQuery.toLowerCase();
    return _conversations
        .where(
          (c) =>
              c.displayNameFor(role).toLowerCase().contains(q) ||
              c.preview.toLowerCase().contains(q),
        )
        .toList();
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────
  /// Initial REST load, then open the live socket for incremental updates.
  Future<void> start() async {
    await loadConversations();
    _socket.connect();
  }

  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _repository.fetchConversations(
        userId: userId,
        role: role,
      );
      await _refreshDrafts();
    } catch (e) {
      _error =
          'Failed to load conversations. Make sure the backend is running.';
      debugPrint('Error loading conversations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Re-read the saved drafts for the current conversations. Call this when the
  /// inbox regains focus (e.g. after returning from a chat) so a draft typed
  /// there shows up — or disappears once sent.
  Future<void> refreshDrafts() async {
    await _refreshDrafts();
    notifyListeners();
  }

  /// Re-fetch conversations + drafts WITHOUT the loading spinner. Call this when
  /// returning from a chat so unread counts reflect what was just read, even if
  /// a socket update was missed or arrived out of order.
  Future<void> silentReload() async {
    try {
      _conversations = await _repository.fetchConversations(
        userId: userId,
        role: role,
      );
      await _refreshDrafts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error reloading conversations: $e');
    }
  }

  Future<void> _refreshDrafts() async {
    final next = <String, String>{};
    for (final c in _conversations) {
      final draft = await _draftStore.read(c.id);
      if (draft != null && draft.isNotEmpty) next[c.id] = draft;
    }
    _drafts = next;
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Realtime ─────────────────────────────────────────────────────────────
  /// Upsert a pushed conversation row and keep the list newest-first.
  void _applyRealtimeUpdate(Conversation incoming) {
    final index = _conversations.indexWhere((c) => c.id == incoming.id);
    if (index >= 0) {
      _conversations[index] = incoming;
    } else {
      _conversations.add(incoming);
    }

    _conversations.sort((a, b) {
      final at = a.lastMessageAt;
      final bt = b.lastMessageAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });

    notifyListeners();
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
