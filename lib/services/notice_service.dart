import 'api_service.dart';

class NoticeItem {
  final int id;
  final String title;
  final String content;
  final bool isPinned;
  final DateTime createdAt;

  const NoticeItem({
    required this.id,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.createdAt,
  });

  factory NoticeItem.fromJson(Map<String, dynamic> j) => NoticeItem(
        id: j['id'] as int,
        title: j['title'] as String,
        content: j['content'] as String,
        isPinned: j['isPinned'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class NoticeService {
  final ApiService _api;
  NoticeService({String? token}) : _api = ApiService(token: token);

  Future<List<NoticeItem>> fetchAll() async {
    final data = await _api.get('/api/v1/notices');
    final items = data['items'] as List? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(NoticeItem.fromJson)
        .toList();
  }
}
