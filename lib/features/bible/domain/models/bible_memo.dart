import 'package:hive/hive.dart';

part 'bible_memo.g.dart';

@HiveType(typeId: 1)
class BibleMemo extends HiveObject {
  @HiveField(0)
  final String id;

  /// DB/API 표준 book 코드 (예: JHN)
  @HiveField(1)
  final String bookId;

  @HiveField(2)
  final String bookKoName;

  @HiveField(3)
  final int chapter;

  @HiveField(4)
  final int verse;

  @HiveField(5)
  final String content;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final int highlightColorValue;

  @HiveField(8)
  final int startVerse;

  @HiveField(9)
  final int? endVerse;

  BibleMemo({
    required this.id,
    required this.bookId,
    required this.bookKoName,
    required this.chapter,
    required this.verse,
    required this.content,
    required this.createdAt,
    required this.highlightColorValue,
    required this.startVerse,
    required this.endVerse,
  });
}
