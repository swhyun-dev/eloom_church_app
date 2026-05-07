import '../../domain/models/notice.dart';
import '../dto/notice_dto.dart';

/// DTO ↔ Domain 변환 전담.
class NoticeMapper {
  NoticeMapper._();

  static Notice toDomain(NoticeDto dto) => Notice(
        id: dto.id,
        title: dto.title,
        content: dto.content,
        isPinned: dto.isPinned,
        createdAt: DateTime.parse(dto.createdAt),
      );
}
