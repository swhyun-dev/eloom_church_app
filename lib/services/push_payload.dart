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
      type: (map['type'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      body: (map['body'] ?? '').toString(),
      route: (map['route'] ?? '/').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type,
    'title': title,
    'body': body,
    'route': route,
  };
}
