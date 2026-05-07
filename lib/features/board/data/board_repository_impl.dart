import '../domain/board_repository.dart';
import '../domain/models/board_category.dart';
import '../domain/models/board_post.dart';
import 'board_api.dart';
import 'mappers/board_post_mapper.dart';

class BoardRepositoryImpl implements BoardRepository {
  final BoardApi api;

  BoardRepositoryImpl({required this.api});

  @override
  Future<List<BoardPost>> fetchByCategory(BoardCategory category) async {
    final dtos = await api.fetchByCategory(category);
    return dtos.map(BoardPostMapper.toDomain).toList();
  }
}
