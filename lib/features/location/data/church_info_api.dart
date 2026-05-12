import '../../../services/api_service.dart';
import '../domain/models/church_info.dart';

class ChurchInfoApi {
  ChurchInfoApi();

  final ApiService _api = ApiService();

  /// GET /api/v1/church-info — singleton row.
  Future<ChurchInfo?> fetch() async {
    final data = await _api.get('/api/v1/church-info');
    final info = data['info'] as Map<String, dynamic>?;
    if (info == null) return null;
    return ChurchInfo(
      address: info['address'] as String? ?? '',
      addressDetail: info['addressDetail'] as String?,
      phone: info['phone'] as String?,
      fax: info['fax'] as String?,
      email: info['email'] as String?,
      parkingGuide: info['parkingGuide'] as String?,
      trafficGuide: info['trafficGuide'] as String?,
      mapLatitude: (info['mapLatitude'] as num?)?.toDouble(),
      mapLongitude: (info['mapLongitude'] as num?)?.toDouble(),
      naverMapUrl: info['naverMapUrl'] as String?,
      kakaoMapUrl: info['kakaoMapUrl'] as String?,
    );
  }
}
