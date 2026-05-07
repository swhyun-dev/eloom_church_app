import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/http/app_dio.dart';
import '../dto/bible_api_com_dto.dart';
import 'bible_api_exceptions.dart';

class BibleApiComProvider {
  BibleApiComProvider();

  Dio get _dio => AppDio.instance;

  BibleApiUserException _mapDioError(DioException e) {
    final res = e.response;
    final sc = res?.statusCode;

    String? serverMsg;
    final data = res?.data;
    if (data is Map && data['message'] is String) {
      serverMsg = data['message'] as String;
    }

    if (sc == 404) {
      return BibleApiUserException('요청한 본문을 찾을 수 없습니다.', statusCode: sc);
    }
    if (sc == 429) {
      return BibleApiUserException('요청이 많습니다. 잠시 후 다시 시도해주세요.', statusCode: sc);
    }
    if (sc != null && sc >= 500) {
      return BibleApiUserException('서버 점검 중입니다. 잠시 후 다시 시도해주세요.', statusCode: sc);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return BibleApiUserException(
        '서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.',
        original: e,
      );
    }
    if (e.error is SocketException) {
      return BibleApiUserException(
        '네트워크에 연결할 수 없습니다. 인터넷 연결을 확인해주세요.',
        original: e.error,
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return BibleApiUserException(
        '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.',
        original: e,
      );
    }

    return BibleApiUserException(
      serverMsg ?? '성경 데이터를 불러오지 못했습니다. 다시 시도해주세요.',
      statusCode: sc,
      original: e,
    );
  }

  BibleApiUserException _mapException(Object e) {
    if (e is FormatException) {
      return BibleApiUserException('데이터 처리 중 오류가 발생했습니다. 다시 시도해주세요.', original: e);
    }
    return BibleApiUserException('알 수 없는 오류가 발생했습니다. 다시 시도해주세요.', original: e);
  }

  Future<BibleApiComResponseDto> fetchChapter({
    required String translationId,
    required String book,
    required int chapter,
  }) async {
    final path = '/api/v1/bible/chapters/$translationId/$book/$chapter';
    debugPrint('[BibleApiComProvider] GET $path');

    try {
      final res = await _dio.get<dynamic>(path);
      debugPrint('[BibleApiComProvider] status=${res.statusCode} data=${res.data}');

      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw BibleApiUserException('성경 응답 형식이 올바르지 않습니다.');
      }
      return BibleApiComResponseDto.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      if (e is BibleApiUserException) rethrow;
      throw _mapException(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchTranslations() async {
    const path = '/api/v1/bible/translations';
    debugPrint('[BibleApiComProvider] GET $path');

    try {
      final res = await _dio.get<dynamic>(path);
      debugPrint('[BibleApiComProvider] status=${res.statusCode} data=${res.data}');

      final data = res.data;
      if (data is! List) {
        throw BibleApiUserException('성경 번역 목록 응답 형식이 올바르지 않습니다.');
      }
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      if (e is BibleApiUserException) rethrow;
      throw _mapException(e);
    }
  }

  Future<BibleApiComResponseDto> fetch(
    String passage, {
    required String translationId,
  }) async {
    final parts = passage.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw BibleApiUserException('형식이 올바르지 않습니다. (예: "GEN 1")');
    }
    final book = parts.first;
    final chapter = int.tryParse(parts[1]) ?? 1;
    return fetchChapter(translationId: translationId, book: book, chapter: chapter);
  }
}
