import 'models/board_category.dart';
import 'models/board_post.dart';

abstract class BoardRepository {
  Future<List<BoardPost>> fetchByCategory(BoardCategory category);
}
