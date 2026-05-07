import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../core/http/app_dio.dart';

class ApiService {
  ApiService();

  Dio get _dio => AppDio.instance;

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query?.isNotEmpty == true ? query : null,
      );
      return res.data ?? const {};
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(path, data: body);
      return res.data ?? const {};
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(path, data: body);
      return res.data ?? const {};
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(path, data: body);
      return res.data ?? const {};
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Exception _toException(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return Exception(data['message'] as String);
    }
    final code = e.response?.statusCode;
    return Exception('요청에 실패했습니다.${code != null ? ' ($code)' : ''}');
  }

  static String absoluteUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '${ApiConfig.baseUrl}$path';
  }
}
