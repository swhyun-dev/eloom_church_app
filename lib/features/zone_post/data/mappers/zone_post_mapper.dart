import '../../domain/models/zone_post.dart';
import '../dto/zone_post_dto.dart';

class ZonePostMapper {
  ZonePostMapper._();

  static ZonePost toDomain(ZonePostDto dto) => ZonePost(
        id: dto.id,
        title: dto.title,
        content: dto.content,
        authorName: dto.authorName,
        createdAt: DateTime.parse(dto.createdAt),
      );
}
