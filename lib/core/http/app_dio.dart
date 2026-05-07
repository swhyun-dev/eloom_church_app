import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../storage/token_storage.dart';

/// 단일 Dio 인스턴스 — JWT 자동 첨부 + 401 시 토큰 정리/로그아웃 콜백.
class AppDio {
  AppDio._();

  /// 401 응답 시 호출. main.dart에서 등록(예: container.read(authProvider.notifier).logout()).
  static void Function()? onUnauthorized;

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
          final token = await TokenStorage.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
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
