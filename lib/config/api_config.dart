import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  // Override at build time if needed:
  // flutter run --dart-define=API_HOST=192.168.1.10 --dart-define=API_PORT=9000
  // or provide full base URL: --dart-define=API_BASEURL=https://your.domain/api
  static const String _envHost = String.fromEnvironment('API_HOST');
  // Default to 8000 to match typical Laravel dev server
  static const int _envPort = int.fromEnvironment('API_PORT', defaultValue: 8000);
  static const String _envBase = String.fromEnvironment('API_BASEURL');

  static String _detectHost() {
    if (_envHost.isNotEmpty) return _envHost; // explicit override
    if (kIsWeb) {
      final h = Uri.base.host;
      if (h.isNotEmpty && h != 'localhost' && h != '127.0.0.1') return h;
      return '127.0.0.1';
    }
    try {
      if (Platform.isAndroid) return '10.0.2.2'; // Android emulator alias to host
    } catch (_) {}
    return '127.0.0.1'; // iOS simulator/desktop default
  }

  static String get baseUrl => _envBase.isNotEmpty
      ? _envBase
      : 'http://${_detectHost()}:$_envPort/api';

  static const String login = '/mobile/login';
  static const String attendance = '/attendance';
}
