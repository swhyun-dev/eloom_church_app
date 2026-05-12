import 'models/sermon.dart';
import 'models/sermon_category.dart';

abstract class SermonRepository {
  Future<List<Sermon>> fetchSermons({SermonCategory? category, int? cursor});
  Future<Sermon?> fetchById(int id);
}
