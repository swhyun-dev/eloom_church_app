import '../../domain/models/prayer.dart';
import '../dto/prayer_dto.dart';

class PrayerMapper {
  PrayerMapper._();

  static Prayer toDomain(PrayerDto dto) => Prayer(
        id: dto.id,
        type: PrayerType.fromApi(dto.type),
        status: PrayerStatus.fromApi(dto.status),
        title: dto.title ?? '',
        content: dto.content,
        isPublic: dto.isPublic,
        authorName: dto.authorName,
        createdAt: DateTime.parse(dto.createdAt),
      );
}
