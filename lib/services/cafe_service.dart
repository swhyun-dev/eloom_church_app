import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart'; // baseUrl
import '../features/cafe/cafe_page.dart'; // 아래에서 추가할 모델들 경로 맞추세요

class CafeService {
  CafeService();

  /// GET /api/cafe/menu
  /// 응답:
  /// {
  ///   ok: true,
  ///   categories: ["커피","논커피"...],
  ///   data: { "커피":[{...}], "논커피":[{...}] }
  /// }
  Future<CafeMenuPayload> fetchMenu({bool all = false}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/cafe/menu')
        .replace(queryParameters: all ? {'all': '1'} : null);

    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('메뉴 조회 실패 (${res.statusCode})');
    }

    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw Exception('메뉴 응답 형식이 올바르지 않습니다.');
    }
    if (decoded['ok'] != true) {
      throw Exception((decoded['message'] ?? '메뉴 조회 실패').toString());
    }

    final categories = (decoded['categories'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();

    final data = decoded['data'];
    final grouped = <String, List<CafeMenuItem>>{};

    if (data is Map) {
      data.forEach((cat, list) {
        final catName = (cat ?? '기타').toString();
        final out = <CafeMenuItem>[];
        if (list is List) {
          for (final it in list) {
            if (it is Map) {
              final j = Map<String, dynamic>.from(it);
              // 서버는 category를 넣어주지만, 방어적으로 주입
              j['category'] = catName;
              out.add(CafeMenuItem.fromJson(j));
            }
          }
        }
        grouped[catName] = out;
      });
    }

    // 서버가 정렬을 보장하지만(카테고리 sortOrder / 아이템 sortOrder),
    // 혹시라도 대비해서 한번 더 안정적으로 정렬
    for (final e in grouped.entries) {
      e.value.sort((a, b) {
        final c = a.sortOrder.compareTo(b.sortOrder);
        if (c != 0) return c;
        return a.id.compareTo(b.id);
      });
    }

    return CafeMenuPayload(
      categories: categories,
      data: grouped,
    );
  }

  /// POST /api/cafe/orders (requireAuth)
  /// body:
  /// {
  ///  items: [{menuId, qty, options?}],
  ///  memo?
  /// }
  Future<Map<String, dynamic>> createOrder({
    required String accessToken,
    required List<Map<String, dynamic>> items,
    String? memo,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/cafe/orders');

    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'items': items,
        if (memo != null && memo.trim().isNotEmpty) 'memo': memo.trim(),
      }),
    );

    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw Exception('주문 응답 형식이 올바르지 않습니다.');
    }

    if (res.statusCode < 200 || res.statusCode >= 300 || decoded['ok'] != true) {
      throw Exception((decoded['message'] ?? '주문 실패').toString());
    }

    return decoded;
  }
}