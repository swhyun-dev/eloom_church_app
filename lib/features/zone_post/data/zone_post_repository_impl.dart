import '../domain/models/zone_post.dart';
import '../domain/zone_post_repository.dart';
import 'mappers/zone_post_mapper.dart';
import 'zone_post_api.dart';

class ZonePostRepositoryImpl implements ZonePostRepository {
  final ZonePostApi api;

  ZonePostRepositoryImpl({required this.api});

  @override
  Future<List<ZonePost>> fetchAll() async {
    final dtos = await api.fetchAll();
    return dtos.map(ZonePostMapper.toDomain).toList();
  }

  @override
  Future<void> create({required String title, required String content}) =>
      api.create(title: title, content: content);

  @override
  Future<void> update(int id, {required String title, required String content}) =>
      api.update(id, title: title, content: content);

  @override
  Future<void> delete(int id) => api.delete(id);
}
