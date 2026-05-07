import 'models/bulletin.dart';

abstract class BulletinRepository {
  Future<List<Bulletin>> fetchAll();
}
