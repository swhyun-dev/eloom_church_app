import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../../../config/api_config.dart';
import '../../../core/http/app_http_client.dart';
import '../dto/bible_api_com_dto.dart';
import 'bible_api_exceptions.dart';

class BibleApiComProvider {
  final AppHttpClient httpClient;
  BibleApiComProvider(this.httpClient);

  Uri _buildUri(String path) {
    return Uri.parse(ApiConfig.baseUrl).replace(path: path);
  }

  BibleApiUserException _mapHttpError(http.Response res) {
    final sc = res.statusCode;

    // 서버에서 {message: "..."} 같은 포맷이면 같이 보여주고 싶을 때(선택)
    String? serverMsg;
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map && decoded['message'] is String) {
        serverMsg = decoded['message'] as String;
      }
    } catch (_) {}

    if (sc == 404) {
      return BibleApiUserException('요청한 본문을 찾을 수 없습니다.', statusCode: sc);
    }
    if (sc == 429) {
      return BibleApiUserException('요청이 많습니다. 잠시 후 다시 시도해주세요.', statusCode: sc);
    }
    if (sc >= 500) {
      return BibleApiUserException('서버 점검 중입니다. 잠시 후 다시 시도해주세요.', statusCode: sc);
    }

    return BibleApiUserException(
      serverMsg ?? '성경 데이터를 불러오지 못했습니다. 다시 시도해주세요.',
      statusCode: sc,
    );
  }

  BibleApiUserException _mapException(Object e) {
    // 네트워크 끊김/도메인 불가/오프라인 등
    if (e is SocketException) {
      return BibleApiUserException('네트워크에 연결할 수 없습니다. 인터넷 연결을 확인해주세요.', original: e);
    }
    // 타임아웃
    if (e is TimeoutException) {
      return BibleApiUserException('서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.', original: e);
    }
    // http 라이브러리 예외
    if (e is http.ClientException) {
      return BibleApiUserException('서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.', original: e);
    }
    // JSON 파싱 문제 등
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
    final uri = _buildUri('/api/bible/chapters/$translationId/$book/$chapter');
    debugPrint('[BibleApiComProvider] GET $uri');

    try {
      final http.Response res = await httpClient
          .get(uri.toString())
          .timeout(const Duration(seconds: 15));

      debugPrint('[BibleApiComProvider] status=${res.statusCode} body=${res.body}');

      if (res.statusCode != 200) {
        throw _mapHttpError(res);
      }

      final jsonMap = json.decode(res.body) as Map<String, dynamic>;
      return BibleApiComResponseDto.fromJson(jsonMap);
    } catch (e) {
      // 이미 사용자 예외면 그대로
      if (e is BibleApiUserException) rethrow;
      throw _mapException(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchTranslations() async {
    final uri = _buildUri('/api/bible/translations');
    debugPrint('[BibleApiComProvider] GET $uri');

    try {
      final http.Response res = await httpClient
          .get(uri.toString())
          .timeout(const Duration(seconds: 15));

      debugPrint('[BibleApiComProvider] status=${res.statusCode} body=${res.body}');

      if (res.statusCode != 200) {
        throw _mapHttpError(res);
      }

      final list = json.decode(res.body) as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
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