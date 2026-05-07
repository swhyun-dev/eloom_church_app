enum PrayerType {
  common,
  personal;

  String get apiValue => switch (this) {
        PrayerType.common => 'COMMON',
        PrayerType.personal => 'PERSONAL',
      };

  static PrayerType fromApi(String? value) => switch (value) {
        'PERSONAL' => PrayerType.personal,
        _ => PrayerType.common,
      };
}

enum PrayerStatus {
  pending,
  approved,
  rejected;

  static PrayerStatus fromApi(String? value) => switch (value) {
        'APPROVED' => PrayerStatus.approved,
        'REJECTED' => PrayerStatus.rejected,
        _ => PrayerStatus.pending,
      };
}

/// 기도제목 도메인 엔티티. common/zone/mine 응답 모두 같은 형태.
class Prayer {
  final int id;
  final PrayerType type;
  final PrayerStatus status;
  final String title; // 빈 문자열 가능 (zone/mine은 title 없을 수 있음)
  final String content;
  final bool isPublic;
  final String? authorName;
  final DateTime createdAt;

  const Prayer({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.content,
    required this.isPublic,
    required this.createdAt,
    this.authorName,
  });
}
