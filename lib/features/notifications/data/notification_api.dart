import '../../../services/api_service.dart';
import '../domain/models/notification_kind.dart';
import 'dto/app_notification_dto.dart';

class NotificationApi {
  NotificationApi();

  final ApiService _api = ApiService();

  /// GET /api/v1/notifications
  Future<({List<AppNotificationDto> items, int unreadCount, int? nextCursor})>
      fetchInbox({
    NotificationKind? kind,
    bool unreadOnly = false,
    int? cursor,
    int? take,
  }) async {
    final data = await _api.get('/api/v1/notifications', query: {
      if (kind != null) 'kind': kind.apiValue,
      if (unreadOnly) 'unreadOnly': 'true',
      if (cursor != null) 'cursor': cursor.toString(),
      if (take != null) 'take': take.toString(),
    });
    final items = (data['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AppNotificationDto.fromJson)
        .toList();
    return (
      items: items,
      unreadCount: data['unreadCount'] as int? ?? 0,
      nextCursor: data['nextCursor'] as int?,
    );
  }

  /// PATCH /api/v1/notifications/:id/read
  Future<AppNotificationDto> markRead(int id) async {
    final data = await _api.patch('/api/v1/notifications/$id/read', const {});
    final item = data['item'] as Map<String, dynamic>?;
    if (item == null) {
      throw Exception('읽음 처리 응답 형식이 올바르지 않습니다.');
    }
    return AppNotificationDto.fromJson(item);
  }

  /// PATCH /api/v1/notifications/read-all
  Future<int> markAllRead() async {
    final data = await _api.patch('/api/v1/notifications/read-all', const {});
    return data['updated'] as int? ?? 0;
  }

  /// DELETE /api/v1/notifications/:id
  Future<void> delete(int id) async {
    await _api.delete('/api/v1/notifications/$id');
  }
}
