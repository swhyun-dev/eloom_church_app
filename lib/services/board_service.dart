import 'api_service.dart';

class BoardPostData {
  final int id;
  final String category; // CHURCH_NEWS | MEETING_NOTICE | MEMBER_NEWS
  final String title;
  final String content;
  final bool isPinned;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime createdAt;

  const BoardPostData({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.createdAt,
    this.startAt,
    this.endAt,
  });

  String get type {
    switch (category) {
      case 'CHURCH_NEWS': return 'news';
      case 'MEETING_NOTICE': return 'notice';
      case 'MEMBER_NEWS': return 'fellow';
      default: return 'news';
    }
  }

  factory BoardPostData.fromJson(Map<String, dynamic> j) => BoardPostData(
        id: j['id'] as int,
        category: j['category'] as String? ?? 'CHURCH_NEWS',
        title: j['title'] as String,
        content: j['content'] as String,
        isPinned: j['isPinned'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String),
        startAt: j['startAt'] != null ? DateTime.tryParse(j['startAt'] as String) : null,
        endAt: j['endAt'] != null ? DateTime.tryParse(j['endAt'] as String) : null,
      );
}

class BoardService {
  final ApiService _api;
  BoardService() : _api = ApiService();

  Future<List<BoardPostData>> fetchByCategory(String category) async {
    final data = await _api.get('/api/v1/board-posts', query: {'category': category});
    final items = data['items'] as List? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(BoardPostData.fromJson)
        .toList();
  }

  Future<BoardPostData?> fetchOne(String category, int id) async {
    final items = await fetchByCategory(category);
    try {
      return items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
