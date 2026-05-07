import 'models/zone_post.dart';

abstract class ZonePostRepository {
  Future<List<ZonePost>> fetchAll();
  Future<void> create({required String title, required String content});
  Future<void> update(int id, {required String title, required String content});
  Future<void> delete(int id);
}
