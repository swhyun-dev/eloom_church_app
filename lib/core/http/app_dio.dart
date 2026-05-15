import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../storage/token_storage.dart';

/// 단일 Dio 인스턴스 — JWT 자동 첨부 + 401 시 토큰 정리/로그아웃 콜백.
///
/// Safari PWA / iOS WKWebView 환경에서 secure_storage/SharedPreferences가
/// 페이지 전환 시 일시적으로 빈 값을 반환하는 경우가 있어,
/// 토큰을 메모리(`memoryToken`)에도 함께 보관하고 메모리를 1순위로 사용한다.
class AppDio {
  AppDio._();

  /// 401 응답 시 호출. main.dart에서 등록(예: container.read(authProvider.notifier).logout()).
  static void Function()? onUnauthorized;

  /// 메모리 토큰 캐시 — login/logout/hydrate 시점에 동기화.
  /// storage 실패해도 같은 앱 세션 동안에는 항상 사용 가능.
  static String? memoryToken;

  /// 앱 시작 시 storage → memory hydrate.
  static Future<void> hydrate() async {
    try {
      memoryToken = await TokenStorage.read();
    } catch (_) {
      memoryToken = null;
    }
  }

  static final Dio instance = _create();

  static Dio _create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1) 메모리 우선
          var token = memoryToken;
          // 2) 메모리 비어있으면 storage 시도
          if (token == null || token.isEmpty) {
            try {
              token = await TokenStorage.read();
              if (token != null && token.isNotEmpty) memoryToken = token;
            } catch (_) {
              // storage 실패 무시
            }
          }
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            memoryToken = null;
            await TokenStorage.clear();
            onUnauthorized?.call();
          }
          handler.next(e);
        },
      ),
    );

    return dio;
  }
}
