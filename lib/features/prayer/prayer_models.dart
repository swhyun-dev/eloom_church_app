class PrayerItem {
  final String id;
  final DateTime date;
  final String title;
  final String content;

  PrayerItem({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
  });
}

class MyPrayerItem {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final bool isPublic;

  const MyPrayerItem({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.isPublic,
  });

  MyPrayerItem copyWith({
    DateTime? date,
    String? title,
    String? content,
    bool? isPublic,
  }) {
    return MyPrayerItem(
      id: id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}

String formatYmd(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y년 $m월 $day일';
}
