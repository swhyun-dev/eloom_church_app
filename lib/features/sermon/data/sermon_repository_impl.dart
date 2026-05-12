import '../domain/models/sermon.dart';
import '../domain/models/sermon_category.dart';
import '../domain/sermon_repository.dart';
import 'mappers/sermon_mapper.dart';
import 'sermon_api.dart';

class SermonRepositoryImpl implements SermonRepository {
  final SermonApi api;

  SermonRepositoryImpl({required this.api});

  @override
  Future<List<Sermon>> fetchSermons({SermonCategory? category, int? cursor}) async {
    final dtos = await api.fetchList(category: category, cursor: cursor);
    return dtos.map(SermonMapper.toDomain).toList();
  }

  @override
  Future<Sermon?> fetchById(int id) async {
    final dto = await api.fetchById(id);
    return dto == null ? null : SermonMapper.toDomain(dto);
  }
}
