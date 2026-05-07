/// API 응답 DTO. `/api/v1/bulletins` 응답의 `bulletins[]` 항목 1개에 대응.
class BulletinDto {
  final int id;
  final String date; // ISO 8601
  final List<BulletinImageDto> images;

  const BulletinDto({
    required this.id,
    required this.date,
    required this.images,
  });

  factory BulletinDto.fromJson(Map<String, dynamic> j) => BulletinDto(
        id: j['id'] as int,
        date: j['date'] as String,
        images: (j['images'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(BulletinImageDto.fromJson)
            .toList(),
      );
}

class BulletinImageDto {
  final int id;
  final int idx;
  final String? imageUrl; // 서버 상대 경로(예: "/uploads/...") 가능

  const BulletinImageDto({
    required this.id,
    required this.idx,
    required this.imageUrl,
  });

  factory BulletinImageDto.fromJson(Map<String, dynamic> j) => BulletinImageDto(
        id: j['id'] as int,
        idx: j['idx'] as int? ?? 0,
        imageUrl: j['imageUrl'] as String?,
      );
}
