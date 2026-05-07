import 'models/banner_slot.dart';

abstract class BannerRepository {
  Future<List<BannerSlot>> fetchActive();
}
