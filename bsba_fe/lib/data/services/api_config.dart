import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Single source of truth for backend host/URLs across REST and WebSocket.
class ApiConfig {
  ApiConfig._();

  static const int port = 8080;

  /// The Android emulator can't reach the host PC via "localhost"; it routes
  /// to the host loopback through the special alias 10.0.2.2. Web, desktop and
  /// the iOS simulator all run on the host itself, so localhost is correct.
  ///
  /// A real physical device needs the PC's LAN IP instead (e.g. 192.168.x.x);
  /// override it there.
  static String get host {
    if (!kIsWeb && Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get restBaseUrl => 'http://$host:$port/api/v1';

  static String get wsUrl => 'ws://$host:$port/ws';
}
