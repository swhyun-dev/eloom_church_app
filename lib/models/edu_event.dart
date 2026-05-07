/// dummy/dummy_data.dart 전용 EduEvent (출시 시 dummy 폐기와 함께 제거 예정).
/// 실제 화면은 BoardPost(BoardCategory.eduNotice)를 사용한다.
class EduEvent {
  final int id;
  final String title;
  final String description;
  final DateTime startAt;
  final DateTime endAt;
  final String? location;
  final String? host;
  final String? applyUrl;

  EduEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startAt,
    required this.endAt,
    this.location,
    this.host,
    this.applyUrl,
  });
}
