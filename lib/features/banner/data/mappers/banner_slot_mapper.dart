import '../../../../services/api_service.dart';
import '../../domain/models/banner_slot.dart';
import '../dto/banner_slot_dto.dart';

class BannerSlotMapper {
  BannerSlotMapper._();

  static BannerSlot toDomain(BannerSlotDto dto) => BannerSlot(
        slot: dto.slot,
        imageUrl: ApiService.absoluteUrl(dto.imageUrl),
        linkUrl: dto.linkUrl,
      );
}
