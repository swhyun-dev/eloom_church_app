import '../../../services/api_service.dart';
import 'dto/banner_slot_dto.dart';

class BannerApi {
  BannerApi();

  final ApiService _api = ApiService();

  Future<List<BannerSlotDto>> fetchActive() async {
    final data = await _api.get('/api/v1/banners');
    final list = data['banners'] as List? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(BannerSlotDto.fromJson)
        .toList();
  }
}
