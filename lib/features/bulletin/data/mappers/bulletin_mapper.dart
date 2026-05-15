import '../../../../services/api_service.dart';
import '../../domain/models/bulletin.dart';
import '../dto/bulletin_dto.dart';

class BulletinMapper {
  BulletinMapper._();

  static Bulletin toDomain(BulletinDto dto) {
    final urls = dto.images
        .map((img) => ApiService.absoluteUrl(img.imageUrl))
        .where((url) => url.isNotEmpty)
        .toList();
    // 백엔드는 KST 자정의 UTC ISO 문자열로 응답 (예: 2026-05-16T15:00:00.000Z = KST 5/17 0시).
    // .toLocal() 미적용 시 UTC 기준 day가 1일 빠르게 인식되어 dropdown 매칭 실패.
    return Bulletin(
      id: dto.id,
      date: DateTime.parse(dto.date).toLocal(),
      imageUrls: urls,
    );
  }
}
