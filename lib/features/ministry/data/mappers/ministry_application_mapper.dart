import '../../domain/models/ministry_application.dart';
import '../../domain/models/ministry_dept.dart';
import '../../domain/models/ministry_status.dart';
import '../dto/ministry_application_dto.dart';

class MinistryApplicationMapper {
  MinistryApplicationMapper._();

  static MinistryApplication toDomain(MinistryApplicationDto dto) =>
      MinistryApplication(
        id: dto.id,
        department: MinistryDept.fromApiValue(dto.department),
        motivation: dto.motivation,
        experience: dto.experience,
        status: MinistryStatus.fromApiValue(dto.status),
        reviewNote: dto.reviewNote,
        reviewedAt: dto.reviewedAt != null
            ? DateTime.tryParse(dto.reviewedAt!)
            : null,
        createdAt: DateTime.parse(dto.createdAt),
        updatedAt: DateTime.parse(dto.updatedAt),
      );
}
