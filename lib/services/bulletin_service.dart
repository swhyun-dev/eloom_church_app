import 'api_service.dart';

class BulletinData {
  final int id;
  final DateTime date;
  final String thumbUrl;
  final List<String> imageUrls;

  const BulletinData({
    required this.id,
    required this.date,
    required this.thumbUrl,
    required this.imageUrls,
  });

  String get title {
    return '${date.year}년 ${date.month}월 ${date.day}일 주보';
  }

  factory BulletinData.fromJson(Map<String, dynamic> j) {
    final images = (j['images'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((img) => ApiService.absoluteUrl(img['imageUrl'] as String?))
        .where((url) => url.isNotEmpty)
        .toList();

    return BulletinData(
      id: j['id'] as int,
      date: DateTime.parse(j['date'] as String),
      thumbUrl: images.isNotEmpty ? images.first : '',
      imageUrls: images,
    );
  }
}

class BulletinService {
  final ApiService _api;
  BulletinService() : _api = const ApiService();

  Future<List<BulletinData>> fetchAll() async {
    final data = await _api.get('/api/v1/bulletins');
    final items = data['bulletins'] as List? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(BulletinData.fromJson)
        .toList();
  }

  Future<BulletinData?> fetchById(int id) async {
    final all = await fetchAll();
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
