import 'api_service.dart';

class BannerData {
  final int slot;
  final String imageUrl;
  final String? linkUrl;

  const BannerData({required this.slot, required this.imageUrl, this.linkUrl});

  factory BannerData.fromJson(Map<String, dynamic> j) {
    return BannerData(
      slot: j['slot'] as int,
      imageUrl: j['imageUrl'] as String,
      linkUrl: j['linkUrl'] as String?,
    );
  }
}

class BannerService {
  final ApiService _api = ApiService();

  Future<List<BannerData>> fetchActive() async {
    final data = await _api.get('/api/v1/banners');
    final list = data['banners'] as List? ?? [];
    return list.whereType<Map<String, dynamic>>().map(BannerData.fromJson).toList();
  }
}
