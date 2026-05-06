import '../models/edu_event.dart';
import 'api_service.dart';

class EduEventService {
  final ApiService _api = ApiService();

  Future<List<EduEvent>> fetchAll() async {
    final data = await _api.get('/api/v1/board-posts?category=EDU_NOTICE');
    final items = data['items'] as List? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .where((j) => j['startAt'] != null && j['endAt'] != null)
        .map(EduEvent.fromJson)
        .toList();
  }

  Future<EduEvent?> fetchById(int id) async {
    final all = await fetchAll();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
