/// 구역 게시글 도메인 엔티티.
class ZonePost {
  final int id;
  final String title;
  final String content;
  final String? authorName;
  final DateTime createdAt;

  const ZonePost({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.authorName,
  });
}
