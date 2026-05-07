import 'models/prayer.dart';

abstract class PrayerRepository {
  Future<List<Prayer>> fetchCommon();
  Future<List<Prayer>> fetchZone();
  Future<List<Prayer>> fetchMine();

  Future<void> create({
    required PrayerType type,
    String? title,
    required String content,
    bool? isPublic,
  });

  Future<void> update(int id, {String? title, String? content, bool? isPublic});

  Future<void> delete(int id);
}
