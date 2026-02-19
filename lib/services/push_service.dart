class PushPayload {
  final String type;
  final String title;
  final String body;
  final String route;

  PushPayload({
    required this.type,
    required this.title,
    required this.body,
    required this.route,
  });

  factory PushPayload.fromMap(Map<String, dynamic> map) {
    return PushPayload(
      type: map['type'],
      title: map['title'],
      body: map['body'],
      route: map['route'],
    );
  }
}
