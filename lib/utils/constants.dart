import 'package:flutter/foundation.dart';

class Constants {
  static const String _productionBaseUrl =
      'https://testify-server-production-98a5.up.railway.app/api';

  // Optional runtime override for local/staging environments.
  // Example:
  // flutter run --dart-define=API_BASE_URL=http://192.168.1.15:8080/api
  static const String _envBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    final override = _envBaseUrl.trim();
    if (override.isNotEmpty) {
      return override;
    }

    if (kReleaseMode) {
      return _productionBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator maps host machine localhost to 10.0.2.2.
      return 'http://10.0.2.2:8080/api';
    }

    // iOS simulator / desktop apps can use localhost directly.
    return 'http://localhost:8080/api';
  }
}