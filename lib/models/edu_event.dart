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

  factory EduEvent.fromJson(Map<String, dynamic> j) {
    return EduEvent(
      id: j['id'] as int,
      title: j['title'] as String,
      description: j['content'] as String? ?? '',
      startAt: DateTime.parse(j['startAt'] as String),
      endAt: DateTime.parse(j['endAt'] as String),
    );
  }
}
