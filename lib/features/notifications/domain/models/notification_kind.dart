/// 알림 종류. 백엔드 NotificationKind enum과 1:1.
enum NotificationKind {
  worship,
  cafe,
  zone,
  ministry,
  general;

  String get apiValue {
    switch (this) {
      case NotificationKind.worship:
        return 'WORSHIP';
      case NotificationKind.cafe:
        return 'CAFE';
      case NotificationKind.zone:
        return 'ZONE';
      case NotificationKind.ministry:
        return 'MINISTRY';
      case NotificationKind.general:
        return 'GENERAL';
    }
  }

  String get label {
    switch (this) {
      case NotificationKind.worship:
        return '예배알림';
      case NotificationKind.cafe:
        return '카페알림';
      case NotificationKind.zone:
        return '구역알림';
      case NotificationKind.ministry:
        return '사역알림';
      case NotificationKind.general:
        return '알림';
    }
  }

  /// 해당 알림이 가리키는 화면이 로그인 필요한지.
  bool get requiresLogin {
    switch (this) {
      case NotificationKind.cafe:
      case NotificationKind.zone:
      case NotificationKind.ministry:
        return true;
      case NotificationKind.worship:
      case NotificationKind.general:
        return false;
    }
  }

  static NotificationKind fromApiValue(String value) {
    switch (value) {
      case 'WORSHIP':
        return NotificationKind.worship;
      case 'CAFE':
        return NotificationKind.cafe;
      case 'ZONE':
        return NotificationKind.zone;
      case 'MINISTRY':
        return NotificationKind.ministry;
      case 'GENERAL':
      default:
        return NotificationKind.general;
    }
  }
}
