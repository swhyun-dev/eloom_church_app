class ZonePostDto {
  final int id;
  final String title;
  final String content;
  final String? authorName;
  final String createdAt;

  const ZonePostDto({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.authorName,
  });

  factory ZonePostDto.fromJson(Map<String, dynamic> j) {
    final author = j['author'] as Map<String, dynamic>?;
    return ZonePostDto(
      id: j['id'] as int,
      title: j['title'] as String,
      content: j['content'] as String,
      authorName: author?['name'] as String?,
      createdAt: j['createdAt'] as String,
    );
  }
}
