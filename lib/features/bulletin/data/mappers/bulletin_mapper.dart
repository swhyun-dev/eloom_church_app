import '../../../../services/api_service.dart';
import '../../domain/models/bulletin.dart';
import '../dto/bulletin_dto.dart';

class BulletinMapper {
  BulletinMapper._();

  static Bulletin toDomain(BulletinDto dto) {
    final urls = dto.images
        .map((img) => ApiService.absoluteUrl(img.imageUrl))
        .where((url) => url.isNotEmpty)
        .toList();
    return Bulletin(
      id: dto.id,
      date: DateTime.parse(dto.date),
      imageUrls: urls,
    );
  }
}
