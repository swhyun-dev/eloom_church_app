import '../../../services/api_service.dart';
import '../domain/models/board_category.dart';
import 'dto/board_post_dto.dart';

class BoardApi {
  BoardApi();

  final ApiService _api = ApiService();

  /// GET /api/v1/board-posts?category=...
  Future<List<BoardPostDto>> fetchByCategory(BoardCategory category) async {
    final data = await _api.get(
      '/api/v1/board-posts',
      query: {'category': category.apiValue},
    );
    final items = data['items'] as List? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(BoardPostDto.fromJson)
        .toList();
  }
}
