import '../domain/models/notice.dart';
import '../domain/notice_repository.dart';
import 'mappers/notice_mapper.dart';
import 'notice_api.dart';

/// Repository 구현체. API 호출 + DTO→Domain 변환을 조합.
class NoticeRepositoryImpl implements NoticeRepository {
  final NoticeApi api;

  NoticeRepositoryImpl({required this.api});

  @override
  Future<List<Notice>> fetchAll() async {
    final dtos = await api.fetchAll();
    return dtos.map(NoticeMapper.toDomain).toList();
  }
}
