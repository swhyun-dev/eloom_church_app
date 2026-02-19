class EduEvent {
  final int id;
  final String title;
  final String description;
  final DateTime startAt;
  final DateTime endAt;
  final String location;
  final String host;
  final String? applyUrl;

  EduEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.location,
    required this.host,
    this.applyUrl,
  });
}
