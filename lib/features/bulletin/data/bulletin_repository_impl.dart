import '../domain/models/bulletin.dart';
import '../domain/bulletin_repository.dart';
import 'mappers/bulletin_mapper.dart';
import 'bulletin_api.dart';

class BulletinRepositoryImpl implements BulletinRepository {
  final BulletinApi api;

  BulletinRepositoryImpl({required this.api});

  @override
  Future<List<Bulletin>> fetchAll() async {
    final dtos = await api.fetchAll();
    return dtos.map(BulletinMapper.toDomain).toList();
  }
}
