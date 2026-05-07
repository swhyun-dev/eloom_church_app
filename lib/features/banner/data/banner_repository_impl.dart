import '../domain/banner_repository.dart';
import '../domain/models/banner_slot.dart';
import 'banner_api.dart';
import 'mappers/banner_slot_mapper.dart';

class BannerRepositoryImpl implements BannerRepository {
  final BannerApi api;

  BannerRepositoryImpl({required this.api});

  @override
  Future<List<BannerSlot>> fetchActive() async {
    final dtos = await api.fetchActive();
    return dtos.map(BannerSlotMapper.toDomain).toList();
  }
}
