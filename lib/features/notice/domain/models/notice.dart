/// 도메인 엔티티 — UI/비즈니스 로직에서 직접 다루는 형태.
class Notice {
  final int id;
  final String title;
  final String content;
  final bool isPinned;
  final DateTime createdAt;

  const Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.createdAt,
  });
}
