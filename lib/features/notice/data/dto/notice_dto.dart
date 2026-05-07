/// API 응답 DTO. JSON 형태에 1:1 대응.
/// 도메인 엔티티(`Notice`)와의 변환은 `mappers/notice_mapper.dart`.
class NoticeDto {
  final int id;
  final String title;
  final String content;
  final bool isPinned;
  final String createdAt; // ISO 8601 문자열 (서버 응답 그대로)

  const NoticeDto({
    required this.id,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.createdAt,
  });

  factory NoticeDto.fromJson(Map<String, dynamic> j) => NoticeDto(
        id: j['id'] as int,
        title: j['title'] as String,
        content: j['content'] as String,
        isPinned: j['isPinned'] as bool? ?? false,
        createdAt: j['createdAt'] as String,
      );
}
