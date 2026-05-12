import '../../../../services/api_service.dart';
import '../domain/models/church_event_category.dart';
import 'dto/church_event_dto.dart';

class ChurchEventApi {
  ChurchEventApi();

  final ApiService _api = ApiService();

  /// GET /api/v1/church-events?month=YYYY-MM&category=...
  Future<List<ChurchEventDto>> fetchMonth({
    required int year,
    required int month,
    ChurchEventCategory? category,
  }) async {
    final monthStr = '$year-${month.toString().padLeft(2, '0')}';
    final data = await _api.get('/api/v1/church-events', query: {
      'month': monthStr,
      if (category != null) 'category': category.apiValue,
    });
    final items = data['items'] as List? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(ChurchEventDto.fromJson)
        .toList();
  }

  /// GET /api/v1/church-events/:id
  Future<ChurchEventDto?> fetchById(int id) async {
    final data = await _api.get('/api/v1/church-events/$id');
    final item = data['item'] as Map<String, dynamic>?;
    if (item == null) return null;
    return ChurchEventDto.fromJson(item);
  }
}
