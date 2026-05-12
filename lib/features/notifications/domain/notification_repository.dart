import 'models/app_notification.dart';
import 'models/notification_kind.dart';

abstract class NotificationRepository {
  /// GET /api/v1/notifications
  Future<NotificationList> fetchInbox({
    NotificationKind? kind,
    bool unreadOnly = false,
    int? cursor,
  });

  /// PATCH /api/v1/notifications/:id/read
  Future<AppNotification> markRead(int id);

  /// PATCH /api/v1/notifications/read-all
  Future<int> markAllRead();

  /// DELETE /api/v1/notifications/:id
  Future<void> delete(int id);
}
