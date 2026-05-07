import 'api_service.dart';
import '../features/cafe/cafe_page.dart'; // CafeMenuPayload / CafeMenuItem

class CafeService {
  CafeService();

  final ApiService _api = ApiService();

  /// GET /api/v1/cafe/menu
  Future<CafeMenuPayload> fetchMenu({bool all = false}) async {
    final decoded = await _api.get(
      '/api/v1/cafe/menu',
      query: all ? {'all': '1'} : null,
    );

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
              j['category'] = catName;
              out.add(CafeMenuItem.fromJson(j));
            }
          }
        }
        grouped[catName] = out;
      });
    }

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

  /// POST /api/v1/cafe/orders (requireAuth — JWT는 인터셉터가 자동 첨부)
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    String? memo,
  }) async {
    final decoded = await _api.post('/api/v1/cafe/orders', {
      'items': items,
      if (memo != null && memo.trim().isNotEmpty) 'memo': memo.trim(),
    });

    if (decoded['ok'] != true) {
      throw Exception((decoded['message'] ?? '주문 실패').toString());
    }

    return decoded;
  }
}
