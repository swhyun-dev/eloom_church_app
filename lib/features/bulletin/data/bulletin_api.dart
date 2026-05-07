import '../../../services/api_service.dart';
import 'dto/bulletin_dto.dart';

class BulletinApi {
  BulletinApi();

  final ApiService _api = ApiService();

  /// GET /api/v1/bulletins — 최신 20개. date 미지정 시 list, 지정 시 단일.
  Future<List<BulletinDto>> fetchAll() async {
    final data = await _api.get('/api/v1/bulletins');
    final items = data['bulletins'] as List? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(BulletinDto.fromJson)
        .toList();
  }
}
