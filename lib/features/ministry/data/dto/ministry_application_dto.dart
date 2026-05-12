class MinistryApplicationDto {
  final int id;
  final String department;
  final String motivation;
  final String? experience;
  final String status;
  final String? reviewNote;
  final String? reviewedAt;
  final String createdAt;
  final String updatedAt;

  const MinistryApplicationDto({
    required this.id,
    required this.department,
    required this.motivation,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.experience,
    this.reviewNote,
    this.reviewedAt,
  });

  factory MinistryApplicationDto.fromJson(Map<String, dynamic> j) =>
      MinistryApplicationDto(
        id: j['id'] as int,
        department: j['department'] as String? ?? 'WORSHIP',
        motivation: j['motivation'] as String? ?? '',
        experience: j['experience'] as String?,
        status: j['status'] as String? ?? 'PENDING',
        reviewNote: j['reviewNote'] as String?,
        reviewedAt: j['reviewedAt'] as String?,
        createdAt: j['createdAt'] as String,
        updatedAt: j['updatedAt'] as String? ?? j['createdAt'] as String,
      );
}
