class ApiConfig {
  /// 빌드 시 --dart-define=API_BASE_URL=... 로 주입.
  ///
  /// - Android 에뮬레이터: http://10.0.2.2:4000
  /// - iOS 시뮬레이터:    http://localhost:4000
  /// - 프로덕션:          https://api.eloomtv.com
  ///
  /// 미주입 시 Android 에뮬레이터 기본값으로 동작.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );
}
