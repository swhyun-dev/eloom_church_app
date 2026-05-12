class AppNotificationDto {
  final int id;
  final String kind;
  final String title;
  final String body;
  final String? route;
  final bool isRead;
  final String createdAt;

  const AppNotificationDto({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.route,
  });

  factory AppNotificationDto.fromJson(Map<String, dynamic> j) =>
      AppNotificationDto(
        id: j['id'] as int,
        kind: j['kind'] as String? ?? 'GENERAL',
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        route: j['route'] as String?,
        isRead: j['isRead'] as bool? ?? false,
        createdAt: j['createdAt'] as String,
      );
}
