/// 설교 카테고리. 백엔드 SermonCategory enum과 1:1.
enum SermonCategory {
  sunday,
  staff,
  guest,
  special;

  String get apiValue {
    switch (this) {
      case SermonCategory.sunday:
        return 'SUNDAY';
      case SermonCategory.staff:
        return 'STAFF';
      case SermonCategory.guest:
        return 'GUEST';
      case SermonCategory.special:
        return 'SPECIAL';
    }
  }

  String get label {
    switch (this) {
      case SermonCategory.sunday:
        return '주일예배설교';
      case SermonCategory.staff:
        return '부교역자설교';
      case SermonCategory.guest:
        return '초청강사설교';
      case SermonCategory.special:
        return '특별집회';
    }
  }

  static SermonCategory fromApiValue(String value) {
    switch (value) {
      case 'STAFF':
        return SermonCategory.staff;
      case 'GUEST':
        return SermonCategory.guest;
      case 'SPECIAL':
        return SermonCategory.special;
      case 'SUNDAY':
      default:
        return SermonCategory.sunday;
    }
  }
}
