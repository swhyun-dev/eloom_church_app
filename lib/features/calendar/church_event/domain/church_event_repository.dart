import 'models/church_event.dart';
import 'models/church_event_category.dart';

abstract class ChurchEventRepository {
  Future<List<ChurchEvent>> fetchMonth({
    required int year,
    required int month,
    ChurchEventCategory? category,
  });

  Future<ChurchEvent?> fetchById(int id);
}
