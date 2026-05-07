import '../../domain/models/board_category.dart';
import '../../domain/models/board_post.dart';
import '../dto/board_post_dto.dart';

class BoardPostMapper {
  BoardPostMapper._();

  static BoardPost toDomain(BoardPostDto dto) => BoardPost(
        id: dto.id,
        category: BoardCategory.fromApiValue(dto.category),
        title: dto.title,
        content: dto.content,
        isPinned: dto.isPinned,
        createdAt: DateTime.parse(dto.createdAt),
        startAt: dto.startAt != null ? DateTime.tryParse(dto.startAt!) : null,
        endAt: dto.endAt != null ? DateTime.tryParse(dto.endAt!) : null,
      );
}
