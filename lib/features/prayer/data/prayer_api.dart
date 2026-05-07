import '../../../services/api_service.dart';
import 'dto/prayer_dto.dart';

class PrayerApi {
  PrayerApi();

  final ApiService _api = ApiService();

  Future<List<PrayerDto>> fetchCommon() async {
    final data = await _api.get('/api/v1/prayers/common');
    return _parseList(data);
  }

  Future<List<PrayerDto>> fetchZone() async {
    final data = await _api.get('/api/v1/prayers/zone');
    return _parseList(data);
  }

  Future<List<PrayerDto>> fetchMine() async {
    final data = await _api.get('/api/v1/prayers/mine');
    return _parseList(data);
  }

  Future<void> create({
    required String typeApiValue,
    String? title,
    required String content,
    bool? isPublic,
  }) async {
    await _api.post('/api/v1/prayers', {
      'type': typeApiValue,
      'content': content,
      if (title != null && title.isNotEmpty) 'title': title,
      if (isPublic != null) 'isPublic': isPublic,
    });
  }

  Future<void> update(
    int id, {
    String? title,
    String? content,
    bool? isPublic,
  }) async {
    await _api.patch('/api/v1/prayers/$id', {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (isPublic != null) 'isPublic': isPublic,
    });
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/v1/prayers/$id');
  }

  List<PrayerDto> _parseList(Map<String, dynamic> data) {
    final items = data['items'] as List? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(PrayerDto.fromJson)
        .toList();
  }
}
