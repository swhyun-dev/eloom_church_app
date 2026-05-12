import '../../../services/api_service.dart';
import '../domain/models/sermon_category.dart';
import 'dto/sermon_dto.dart';

class SermonApi {
  SermonApi();

  final ApiService _api = ApiService();

  /// GET /api/v1/sermons
  Future<List<SermonDto>> fetchList({
    SermonCategory? category,
    int? cursor,
    int? take,
  }) async {
    final data = await _api.get('/api/v1/sermons', query: {
      if (category != null) 'category': category.apiValue,
      if (cursor != null) 'cursor': cursor.toString(),
      if (take != null) 'take': take.toString(),
    });
    final items = data['items'] as List? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(SermonDto.fromJson)
        .toList();
  }

  /// GET /api/v1/sermons/:id
  Future<SermonDto?> fetchById(int id) async {
    final data = await _api.get('/api/v1/sermons/$id');
    final item = data['item'] as Map<String, dynamic>?;
    if (item == null) return null;
    return SermonDto.fromJson(item);
  }
}
