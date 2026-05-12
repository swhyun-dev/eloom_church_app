import '../../domain/models/church_event.dart';
import '../../domain/models/church_event_category.dart';
import '../dto/church_event_dto.dart';

class ChurchEventMapper {
  ChurchEventMapper._();

  static ChurchEvent toDomain(ChurchEventDto dto) => ChurchEvent(
        id: dto.id,
        category: ChurchEventCategory.fromApiValue(dto.category),
        title: dto.title,
        description: dto.description,
        startAt: DateTime.parse(dto.startAt),
        endAt: DateTime.parse(dto.endAt),
        location: dto.location,
      );
}
