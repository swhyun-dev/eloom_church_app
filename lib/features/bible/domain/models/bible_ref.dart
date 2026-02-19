class BibleRef {
  /// DB/API 표준 book 코드 (예: JHN)
  final String book;
  final int chapter;
  final int? verse; // null이면 장 전체

  const BibleRef({
    required this.book,
    required this.chapter,
    this.verse,
  });
}