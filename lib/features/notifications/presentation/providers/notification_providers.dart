import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/notification_api.dart';
import '../../data/notification_repository_impl.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(api: NotificationApi());
});

/// 알림함 — 첫 페이지만 (페이징은 P5에서).
final inboxProvider = FutureProvider<NotificationList>((ref) async {
  return ref.watch(notificationRepositoryProvider).fetchInbox();
});

/// 단일 읽음 처리.
final markNotificationReadProvider =
    Provider<Future<AppNotification> Function(int)>((ref) {
  return ref.watch(notificationRepositoryProvider).markRead;
});

/// 전체 읽음 처리.
final markAllNotificationsReadProvider = Provider<Future<int> Function()>((ref) {
  return ref.watch(notificationRepositoryProvider).markAllRead;
});

/// 단일 삭제.
final deleteNotificationProvider = Provider<Future<void> Function(int)>((ref) {
  return ref.watch(notificationRepositoryProvider).delete;
});
