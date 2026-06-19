import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:project/data/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// Thin STOMP-over-WebSocket client.
///
/// Register topics with [subscribeJson] (before or after [connect]); each
/// decoded JSON payload is delivered to the matching callback. Used for the
/// live inbox (`/topic/users/{id}/conversations`) and the open chat
/// (`/topic/conversations/{id}/messages`).
class ChatSocketService {
  ChatSocketService({String? wsUrl}) : wsUrl = wsUrl ?? ApiClient.wsUrl;

  final String wsUrl;

  StompClient? _client;
  final List<_Subscription> _subscriptions = [];
  bool _connected = false;
  bool _connecting = false;

  bool get isConnected => _connected;

  /// Notified whenever the connection goes up (true) or down (false).
  void Function(bool connected)? onStateChange;

  /// Listen to a topic; safe to call before or after [connect].
  void subscribeJson(
    String destination,
    void Function(Map<String, dynamic> json) onMessage,
  ) {
    final sub = _Subscription(destination, onMessage);
    _subscriptions.add(sub);
    if (isConnected) _activate(sub);
  }

  Future<void> connect() async {
    if (_client != null || _connecting) return;
    _connecting = true;

    // Attach the JWT so Spring Security lets the /ws handshake through.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final authHeaders = (token != null && token.isNotEmpty)
        ? {'Authorization': 'Bearer $token'}
        : <String, String>{};

    debugPrint('STOMP connecting → $wsUrl');
    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        // HTTP handshake headers (read by the security filter) + STOMP frame.
        webSocketConnectHeaders: authHeaders,
        stompConnectHeaders: authHeaders,
        onConnect: (StompFrame _) {
          _connected = true;
          debugPrint('STOMP connected ✓ ($wsUrl)');
          for (final sub in _subscriptions) {
            _activate(sub);
          }
          onStateChange?.call(true);
        },
        onWebSocketError: (dynamic error) {
          _connected = false;
          debugPrint('STOMP websocket error: $error');
          onStateChange?.call(false);
        },
        onStompError: (StompFrame frame) =>
            debugPrint('STOMP error: ${frame.body}'),
        onDisconnect: (StompFrame frame) {
          _connected = false;
          debugPrint('STOMP disconnected');
          onStateChange?.call(false);
        },
        reconnectDelay: const Duration(seconds: 3),
      ),
    );

    _connecting = false;
    _client!.activate();
  }

  /// Send a JSON payload to a STOMP destination (e.g. `/app/presence`).
  /// No-op until connected. The content-type lets Spring bind the body to a
  /// `Map`/DTO on the `@MessageMapping` handler.
  void send(String destination, Object body) {
    _client?.send(
      destination: destination,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json'},
    );
  }

  void _activate(_Subscription sub) {
    _client?.subscribe(
      destination: sub.destination,
      callback: (StompFrame frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        try {
          sub.onMessage(jsonDecode(body) as Map<String, dynamic>);
        } catch (e) {
          debugPrint(
            'Failed to parse STOMP payload for ${sub.destination}: $e',
          );
        }
      },
    );
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
    _connected = false;
    _connecting = false;
    _subscriptions.clear();
    onStateChange = null;
  }
}

class _Subscription {
  _Subscription(this.destination, this.onMessage);

  final String destination;
  final void Function(Map<String, dynamic> json) onMessage;
}
