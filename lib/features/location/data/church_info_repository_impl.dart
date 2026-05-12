import '../domain/church_info_repository.dart';
import '../domain/models/church_info.dart';
import 'church_info_api.dart';

class ChurchInfoRepositoryImpl implements ChurchInfoRepository {
  final ChurchInfoApi api;
  ChurchInfoRepositoryImpl({required this.api});

  @override
  Future<ChurchInfo?> fetch() => api.fetch();
}
