import '../domain/models/prayer.dart';
import '../domain/prayer_repository.dart';
import 'mappers/prayer_mapper.dart';
import 'prayer_api.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerApi api;

  PrayerRepositoryImpl({required this.api});

  @override
  Future<List<Prayer>> fetchCommon() async {
    final dtos = await api.fetchCommon();
    return dtos.map(PrayerMapper.toDomain).toList();
  }

  @override
  Future<List<Prayer>> fetchZone() async {
    final dtos = await api.fetchZone();
    return dtos.map(PrayerMapper.toDomain).toList();
  }

  @override
  Future<List<Prayer>> fetchMine() async {
    final dtos = await api.fetchMine();
    return dtos.map(PrayerMapper.toDomain).toList();
  }

  @override
  Future<void> create({
    required PrayerType type,
    String? title,
    required String content,
    bool? isPublic,
  }) =>
      api.create(
        typeApiValue: type.apiValue,
        title: title,
        content: content,
        isPublic: isPublic,
      );

  @override
  Future<void> update(int id, {String? title, String? content, bool? isPublic}) =>
      api.update(id, title: title, content: content, isPublic: isPublic);

  @override
  Future<void> delete(int id) => api.delete(id);
}
