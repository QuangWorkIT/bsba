import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Single source of truth for backend host/URLs across REST and WebSocket.
class ApiConfig {
  ApiConfig._();

  static const int port = 8080;

  /// Manual host override.
  ///
  /// For LDPlayer (and other emulators whose NAT can't reach the host's LAN IP),
  /// run an adb reverse tunnel and point here at loopback:
  ///   adb -s DEVICE reverse tcp:8080 tcp:8080
  ///   then hostOverride = '127.0.0.1'
  /// For a physical device on the same Wi-Fi, use the PC's LAN IP instead.
  /// Leave empty ('') to auto-detect (10.0.2.2 on the standard Android emulator).
  static const String hostOverride = '127.0.0.1';

  /// The standard Android emulator (AVD) reaches the host PC via the special
  /// alias 10.0.2.2. Web, desktop and the iOS simulator run on the host itself,
  /// so localhost is correct there.
  static String get host {
    if (hostOverride.isNotEmpty) return hostOverride;
    if (!kIsWeb && Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get restBaseUrl => 'http://$host:$port/api/v1';

  static String get wsUrl => 'ws://$host:$port/ws';
}
