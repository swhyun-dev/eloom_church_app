import '../domain/models/app_notification.dart';
import '../domain/models/notification_kind.dart';
import '../domain/notification_repository.dart';
import 'mappers/app_notification_mapper.dart';
import 'notification_api.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationApi api;

  NotificationRepositoryImpl({required this.api});

  @override
  Future<NotificationList> fetchInbox({
    NotificationKind? kind,
    bool unreadOnly = false,
    int? cursor,
  }) async {
    final res = await api.fetchInbox(
      kind: kind,
      unreadOnly: unreadOnly,
      cursor: cursor,
    );
    return NotificationList(
      items: res.items.map(AppNotificationMapper.toDomain).toList(),
      unreadCount: res.unreadCount,
      nextCursor: res.nextCursor,
    );
  }

  @override
  Future<AppNotification> markRead(int id) async {
    final dto = await api.markRead(id);
    return AppNotificationMapper.toDomain(dto);
  }

  @override
  Future<int> markAllRead() => api.markAllRead();

  @override
  Future<void> delete(int id) => api.delete(id);
}
