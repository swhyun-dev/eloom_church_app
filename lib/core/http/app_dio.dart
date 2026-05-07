import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../storage/token_storage.dart';

/// 단일 Dio 인스턴스 — JWT 자동 첨부 인터셉터 포함.
/// 401 처리/로그아웃 연동은 후속 단계(HTTP-2)에서 추가.
class AppDio {
  AppDio._();

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
      ),
    );

    return dio;
  }
}
