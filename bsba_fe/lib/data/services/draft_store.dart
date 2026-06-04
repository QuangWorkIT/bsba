import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists an unsent chat draft per conversation so backing out of a thread
/// mid-typing doesn't lose what was written. Drafts expire after [_window] to
/// avoid restoring stale text the user has long forgotten about.
class DraftStore {
  static const String _keyPrefix = 'chat_draft_';
  static const Duration _window = Duration(days: 1);

  String _key(String conversationId) => '$_keyPrefix$conversationId';

  /// Save (or, for empty text, remove) the draft for [conversationId].
  Future<void> save(String conversationId, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(conversationId);

    if (text.trim().isEmpty) {
      await prefs.remove(key);
      return;
    }

    await prefs.setString(
      key,
      jsonEncode({'text': text, 'savedAt': DateTime.now().toIso8601String()}),
    );
  }

  /// Return the saved draft if it exists and is still within [_window];
  /// otherwise null (and prune the expired/corrupt entry).
  Future<String?> read(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(conversationId);
    final raw = prefs.getString(key);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.tryParse(map['savedAt'] as String? ?? '');
      if (savedAt == null || DateTime.now().difference(savedAt) > _window) {
        await prefs.remove(key);
        return null;
      }
      final text = map['text'] as String?;
      return (text != null && text.isNotEmpty) ? text : null;
    } catch (_) {
      await prefs.remove(key);
      return null;
    }
  }

  Future<void> clear(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(conversationId));
  }
}
