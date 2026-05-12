/// 사용자가 ON/OFF 할 수 있는 알림 토픽 8개.
/// 백엔드 User.notificationSettings JSON의 키와 1:1.
enum NotificationTopic {
  worshipSunday1('worshipSunday1', '주일 1부 예배 알림'),
  worshipSunday2('worshipSunday2', '주일 2부 예배 알림'),
  worshipSundayEvening('worshipSundayEvening', '주일 저녁 예배 알림'),
  worshipWednesday('worshipWednesday', '수요예배 알림'),
  churchNews('churchNews', '교회소식 알림'),
  meetingNotice('meetingNotice', '모임공지 알림'),
  eduNotice('eduNotice', '교육공지 알림'),
  memberNews('memberNews', '교우동정 알림');

  final String apiKey;
  final String label;
  const NotificationTopic(this.apiKey, this.label);

  static NotificationTopic? fromApiKey(String key) {
    for (final t in NotificationTopic.values) {
      if (t.apiKey == key) return t;
    }
    return null;
  }
}

/// 그룹화된 표시 묶음 (UI에서 섹션으로 그룹핑).
class NotificationTopicGroups {
  static const worship = [
    NotificationTopic.worshipSunday1,
    NotificationTopic.worshipSunday2,
    NotificationTopic.worshipSundayEvening,
    NotificationTopic.worshipWednesday,
  ];

  static const board = [
    NotificationTopic.churchNews,
    NotificationTopic.meetingNotice,
    NotificationTopic.eduNotice,
    NotificationTopic.memberNews,
  ];
}
