class BoardPostDto {
  final int id;
  final String category; // CHURCH_NEWS | MEETING_NOTICE | EDU_NOTICE | MEMBER_NEWS
  final String title;
  final String content;
  final bool isPinned;
  final String? startAt;
  final String? endAt;
  final String createdAt;

  const BoardPostDto({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.createdAt,
    this.startAt,
    this.endAt,
  });

  factory BoardPostDto.fromJson(Map<String, dynamic> j) => BoardPostDto(
        id: j['id'] as int,
        category: j['category'] as String? ?? 'CHURCH_NEWS',
        title: j['title'] as String,
        content: j['content'] as String,
        isPinned: j['isPinned'] as bool? ?? false,
        startAt: j['startAt'] as String?,
        endAt: j['endAt'] as String?,
        createdAt: j['createdAt'] as String,
      );
}
