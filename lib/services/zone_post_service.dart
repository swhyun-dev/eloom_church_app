import 'api_service.dart';

class ZonePostData {
  final int id;
  final String title;
  final String content;
  final String? authorName;
  final DateTime createdAt;

  const ZonePostData({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.authorName,
  });

  factory ZonePostData.fromJson(Map<String, dynamic> j) {
    final author = j['author'] as Map<String, dynamic>?;
    return ZonePostData(
      id: j['id'] as int,
      title: j['title'] as String,
      content: j['content'] as String,
      authorName: author?['name'] as String?,
      createdAt: DateTime.parse(j['createdAt'] as String),
    );
  }
}

class ZonePostService {
  final ApiService _api;
  ZonePostService({String? token}) : _api = ApiService(token: token);

  Future<List<ZonePostData>> fetchAll() async {
    final data = await _api.get('/api/v1/zone-posts');
    final items = data['items'] as List? ?? [];
    return items.whereType<Map<String, dynamic>>().map(ZonePostData.fromJson).toList();
  }

  Future<ZonePostData?> fetchById(int id) async {
    final all = await fetchAll();
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> create({required String title, required String content}) async {
    await _api.post('/api/v1/zone-posts', {'title': title, 'content': content});
  }

  Future<void> update(int id, {required String title, required String content}) async {
    await _api.put('/api/v1/zone-posts/$id', {'title': title, 'content': content});
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/v1/zone-posts/$id');
  }
}
