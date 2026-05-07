import '../../../services/api_service.dart';
import 'dto/zone_post_dto.dart';

class ZonePostApi {
  ZonePostApi();

  final ApiService _api = ApiService();

  Future<List<ZonePostDto>> fetchAll() async {
    final data = await _api.get('/api/v1/zone-posts');
    final items = data['items'] as List? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(ZonePostDto.fromJson)
        .toList();
  }

  Future<void> create({required String title, required String content}) async {
    await _api.post('/api/v1/zone-posts', {'title': title, 'content': content});
  }

  Future<void> update(int id, {required String title, required String content}) async {
    await _api.patch('/api/v1/zone-posts/$id', {'title': title, 'content': content});
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/v1/zone-posts/$id');
  }
}
