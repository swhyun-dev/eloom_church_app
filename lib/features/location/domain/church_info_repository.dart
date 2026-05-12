import 'models/church_info.dart';

abstract class ChurchInfoRepository {
  Future<ChurchInfo?> fetch();
}
