import 'api_service.dart';

class PrayerData {
  final int id;
  final String title;
  final String content;
  final bool isPublic;
  final String? authorName;
  final DateTime createdAt;

  const PrayerData({
    required this.id,
    required this.title,
    required this.content,
    required this.isPublic,
    required this.createdAt,
    this.authorName,
  });

  factory PrayerData.fromJson(Map<String, dynamic> j) {
    final author = j['author'] as Map<String, dynamic>?;
    return PrayerData(
      id: j['id'] as int,
      title: j['title'] as String? ?? '',
      content: j['content'] as String,
      isPublic: j['isPublic'] as bool? ?? false,
      authorName: author?['name'] as String?,
      createdAt: DateTime.parse(j['createdAt'] as String),
    );
  }
}

class ZonePrayerData {
  final int id;
  final String title;
  final String content;
  final String? authorName;
  final DateTime createdAt;

  const ZonePrayerData({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.authorName,
  });

  factory ZonePrayerData.fromJson(Map<String, dynamic> j) {
    final author = j['author'] as Map<String, dynamic>?;
    return ZonePrayerData(
      id: j['id'] as int,
      title: j['title'] as String? ?? '',
      content: j['content'] as String,
      authorName: author?['name'] as String?,
      createdAt: DateTime.parse(j['createdAt'] as String),
    );
  }
}

class PrayerService {
  final ApiService _api;
  PrayerService({String? token}) : _api = ApiService(token: token);

  Future<List<PrayerData>> fetchCommon() async {
    final data = await _api.get('/api/v1/prayers/common');
    final items = data['items'] as List? ?? [];
    return items.whereType<Map<String, dynamic>>().map(PrayerData.fromJson).toList();
  }

  Future<List<ZonePrayerData>> fetchZone() async {
    final data = await _api.get('/api/v1/prayers/zone');
    final items = data['items'] as List? ?? [];
    return items.whereType<Map<String, dynamic>>().map(ZonePrayerData.fromJson).toList();
  }

  Future<List<PrayerData>> fetchMine() async {
    final data = await _api.get('/api/v1/prayers/mine');
    final items = data['items'] as List? ?? [];
    return items.whereType<Map<String, dynamic>>().map(PrayerData.fromJson).toList();
  }

  Future<void> create({
    required String content,
    String? title,
    bool isPublic = false,
  }) async {
    await _api.post('/api/v1/prayers', {
      'type': 'PERSONAL',
      'content': content,
      if (title != null && title.isNotEmpty) 'title': title,
      'isPublic': isPublic,
    });
  }
}
