class BoardPost {
  final int id;
  final String type; // news | notice
  final String title;
  final String content;
  final DateTime createdAt;
  final bool pinned;
  final bool important;
  final String target; // 전체/청년부/7남전도회 등
  final DateTime? startAt;
  final DateTime? endAt;

  BoardPost({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.createdAt,
    this.pinned = false,
    this.important = false,
    this.target = '전체',
    this.startAt,
    this.endAt,
  });
}
