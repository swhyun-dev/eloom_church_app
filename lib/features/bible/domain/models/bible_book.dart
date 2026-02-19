class BibleBook {
  /// DB/API에서 사용하는 book 코드
  /// 예: GEN, EXO, PSA, MAT, JHN, REV ...
  final String id;

  /// UI 표시용
  final String koName;

  /// 장 수
  final int chapters;

  const BibleBook({
    required this.id,
    required this.koName,
    required this.chapters,
  });
}