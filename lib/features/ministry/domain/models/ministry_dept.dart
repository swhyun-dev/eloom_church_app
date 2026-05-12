/// 사역신청 부서. 백엔드 MinistryDept enum과 1:1.
enum MinistryDept {
  worship,
  praise,
  vehicle,
  media,
  education,
  service,
  evangelism;

  /// 백엔드 enum 값 (대문자).
  String get apiValue {
    switch (this) {
      case MinistryDept.worship:
        return 'WORSHIP';
      case MinistryDept.praise:
        return 'PRAISE';
      case MinistryDept.vehicle:
        return 'VEHICLE';
      case MinistryDept.media:
        return 'MEDIA';
      case MinistryDept.education:
        return 'EDUCATION';
      case MinistryDept.service:
        return 'SERVICE';
      case MinistryDept.evangelism:
        return 'EVANGELISM';
    }
  }

  /// 한국어 표시명.
  String get label {
    switch (this) {
      case MinistryDept.worship:
        return '예배부';
      case MinistryDept.praise:
        return '찬양사역부';
      case MinistryDept.vehicle:
        return '차량관리부';
      case MinistryDept.media:
        return '미디어사역부';
      case MinistryDept.education:
        return '교육부';
      case MinistryDept.service:
        return '봉사부';
      case MinistryDept.evangelism:
        return '전도부';
    }
  }

  static MinistryDept fromApiValue(String value) {
    switch (value) {
      case 'PRAISE':
        return MinistryDept.praise;
      case 'VEHICLE':
        return MinistryDept.vehicle;
      case 'MEDIA':
        return MinistryDept.media;
      case 'EDUCATION':
        return MinistryDept.education;
      case 'SERVICE':
        return MinistryDept.service;
      case 'EVANGELISM':
        return MinistryDept.evangelism;
      case 'WORSHIP':
      default:
        return MinistryDept.worship;
    }
  }
}
