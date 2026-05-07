/// 도메인 엔티티 — UI/비즈니스 로직에서 직접 다루는 형태.
class Bulletin {
  final int id;
  final DateTime date;
  final List<String> imageUrls; // 절대 URL (mapper에서 변환 완료)

  const Bulletin({
    required this.id,
    required this.date,
    required this.imageUrls,
  });

  String get title =>
      '${date.year}년 ${date.month}월 ${date.day}일 주보';

  String get thumbUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
}
