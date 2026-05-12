import '../domain/church_event_repository.dart';
import '../domain/models/church_event.dart';
import '../domain/models/church_event_category.dart';
import 'church_event_api.dart';
import 'mappers/church_event_mapper.dart';

class ChurchEventRepositoryImpl implements ChurchEventRepository {
  final ChurchEventApi api;

  ChurchEventRepositoryImpl({required this.api});

  @override
  Future<List<ChurchEvent>> fetchMonth({
    required int year,
    required int month,
    ChurchEventCategory? category,
  }) async {
    final dtos = await api.fetchMonth(
      year: year,
      month: month,
      category: category,
    );
    return dtos.map(ChurchEventMapper.toDomain).toList();
  }

  @override
  Future<ChurchEvent?> fetchById(int id) async {
    final dto = await api.fetchById(id);
    return dto == null ? null : ChurchEventMapper.toDomain(dto);
  }
}
