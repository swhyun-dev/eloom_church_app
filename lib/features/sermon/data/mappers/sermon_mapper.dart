import '../../domain/models/sermon.dart';
import '../../domain/models/sermon_category.dart';
import '../dto/sermon_dto.dart';

class SermonMapper {
  SermonMapper._();

  static Sermon toDomain(SermonDto dto) => Sermon(
        id: dto.id,
        category: SermonCategory.fromApiValue(dto.category),
        title: dto.title,
        speaker: dto.speaker,
        bibleText: dto.bibleText,
        preachedAt: DateTime.parse(dto.preachedAt),
        youtubeId: dto.youtubeId,
        thumbnailUrl: dto.thumbnailUrl,
      );
}
