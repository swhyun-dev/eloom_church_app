import 'notification_topic.dart';

/// 사용자 알림 토픽 ON/OFF 묶음. 백엔드에 없는 키는 ON(true)로 간주.
class NotificationSettings {
  final Map<NotificationTopic, bool> values;

  const NotificationSettings(this.values);

  factory NotificationSettings.allOn() => NotificationSettings({
        for (final t in NotificationTopic.values) t: true,
      });

  bool isOn(NotificationTopic topic) => values[topic] ?? true;

  NotificationSettings copyWithToggle(NotificationTopic topic, bool value) {
    return NotificationSettings({...values, topic: value});
  }
}
