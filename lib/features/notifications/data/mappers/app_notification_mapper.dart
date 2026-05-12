import '../../domain/models/app_notification.dart';
import '../../domain/models/notification_kind.dart';
import '../dto/app_notification_dto.dart';

class AppNotificationMapper {
  AppNotificationMapper._();

  static AppNotification toDomain(AppNotificationDto dto) => AppNotification(
        id: dto.id,
        kind: NotificationKind.fromApiValue(dto.kind),
        title: dto.title,
        body: dto.body,
        route: dto.route,
        isRead: dto.isRead,
        createdAt: DateTime.parse(dto.createdAt),
      );
}
