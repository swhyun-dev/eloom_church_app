import 'notification_kind.dart';

/// 앱 알림함의 단일 알림 항목.
/// (Flutter SDK의 `Notification`과 충돌을 피하기 위해 prefix.)
class AppNotification {
  final int id;
  final NotificationKind kind;
  final String title;
  final String body;
  final String? route;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.route,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        kind: kind,
        title: title,
        body: body,
        route: route,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}

class NotificationList {
  final List<AppNotification> items;
  final int unreadCount;
  final int? nextCursor;

  const NotificationList({
    required this.items,
    required this.unreadCount,
    this.nextCursor,
  });
}
