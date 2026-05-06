import 'package:flutter/foundation.dart';

class ApiConfig {
  /// 환경별 실행 방법:
  ///   로컬(Web/iOS): flutter run
  ///   로컬(Android 에뮬레이터): flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
  ///   서버: flutter run --dart-define=API_BASE_URL=http://210.114.19.105
  static const String _defined = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_defined.isNotEmpty) return _defined;
    // Android 에뮬레이터는 10.0.2.2 로 host machine 접근
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      return 'http://10.0.2.2:4000';
    }
    return 'http://localhost:4000';
  }

  static bool get isLocal => baseUrl.contains('localhost') || baseUrl.contains('10.0.2.2');
}
