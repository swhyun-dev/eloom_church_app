/// 교회일정 카테고리. 백엔드 ChurchEventCategory enum과 1:1.
enum ChurchEventCategory {
  worship,
  event,
  education,
  gathering;

  String get apiValue {
    switch (this) {
      case ChurchEventCategory.worship:
        return 'WORSHIP';
      case ChurchEventCategory.event:
        return 'EVENT';
      case ChurchEventCategory.education:
        return 'EDUCATION';
      case ChurchEventCategory.gathering:
        return 'GATHERING';
    }
  }

  String get label {
    switch (this) {
      case ChurchEventCategory.worship:
        return '예배';
      case ChurchEventCategory.event:
        return '행사';
      case ChurchEventCategory.education:
        return '교육';
      case ChurchEventCategory.gathering:
        return '집회';
    }
  }

  static ChurchEventCategory fromApiValue(String value) {
    switch (value) {
      case 'EVENT':
        return ChurchEventCategory.event;
      case 'EDUCATION':
        return ChurchEventCategory.education;
      case 'GATHERING':
        return ChurchEventCategory.gathering;
      case 'WORSHIP':
      default:
        return ChurchEventCategory.worship;
    }
  }
}
