import 'church_event_category.dart';

class ChurchEvent {
  final int id;
  final ChurchEventCategory category;
  final String title;
  final String? description;
  final DateTime startAt;
  final DateTime endAt;
  final String? location;

  const ChurchEvent({
    required this.id,
    required this.category,
    required this.title,
    required this.startAt,
    required this.endAt,
    this.description,
    this.location,
  });

  bool occursOn(DateTime day) {
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    return sameDay(startAt, day);
  }
}
