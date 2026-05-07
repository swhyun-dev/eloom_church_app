import '../../../services/api_service.dart';
import 'dto/notice_dto.dart';

/// API 호출만 담당. ApiService(JWT 자동첨부)를 거쳐 백엔드와 통신.
class NoticeApi {
  NoticeApi();

  final ApiService _api = ApiService();

  Future<List<NoticeDto>> fetchAll() async {
    final data = await _api.get('/api/v1/notices');
    final items = data['items'] as List? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(NoticeDto.fromJson)
        .toList();
  }
}
