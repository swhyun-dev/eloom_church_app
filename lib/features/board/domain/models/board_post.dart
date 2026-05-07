import 'board_category.dart';

class BoardPost {
  final int id;
  final BoardCategory category;
  final String title;
  final String content;
  final bool isPinned;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime createdAt;

  const BoardPost({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.createdAt,
    this.startAt,
    this.endAt,
  });
}
