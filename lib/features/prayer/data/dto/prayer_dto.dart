class PrayerDto {
  final int id;
  final String? type;
  final String? status;
  final String? title;
  final String content;
  final bool isPublic;
  final String? authorName;
  final String createdAt;

  const PrayerDto({
    required this.id,
    required this.content,
    required this.isPublic,
    required this.createdAt,
    this.type,
    this.status,
    this.title,
    this.authorName,
  });

  factory PrayerDto.fromJson(Map<String, dynamic> j) {
    final author = j['author'] as Map<String, dynamic>?;
    return PrayerDto(
      id: j['id'] as int,
      type: j['type'] as String?,
      status: j['status'] as String?,
      title: j['title'] as String?,
      content: j['content'] as String,
      isPublic: j['isPublic'] as bool? ?? false,
      authorName: author?['name'] as String?,
      createdAt: j['createdAt'] as String,
    );
  }
}
