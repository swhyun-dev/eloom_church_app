import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/notification_settings_api.dart';
import '../../data/notification_settings_repository_impl.dart';
import '../../domain/models/notification_settings.dart';
import '../../domain/models/notification_topic.dart';
import '../../domain/notification_settings_repository.dart';

final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>((ref) {
  return NotificationSettingsRepositoryImpl(api: NotificationSettingsApi());
});

final notificationSettingsProvider =
    FutureProvider<NotificationSettings>((ref) async {
  return ref.watch(notificationSettingsRepositoryProvider).fetchMine();
});

/// 단일 토픽 토글. 호출 후 notificationSettingsProvider invalidate 권장.
final toggleNotificationTopicProvider = Provider<
    Future<NotificationSettings> Function(NotificationTopic, bool)>((ref) {
  final repo = ref.watch(notificationSettingsRepositoryProvider);
  return (topic, value) => repo.update({topic: value});
});
