import 'package:flutter/material.dart';

class BibleJumpRequest {
  final String bookId;
  final int chapter;
  final int? verse; // 스크롤용(없으면 장만 이동)

  const BibleJumpRequest({
    required this.bookId,
    required this.chapter,
    this.verse,
  });
}

class BibleReaderController extends ChangeNotifier {
  void Function(BibleJumpRequest req)? _jumpListener;
  BibleJumpRequest? _pendingJump;

  // ===== 선택 상태(범위) =====
  String? _bookId;
  String? _bookKoName;
  int? _chapter;

  int? _startVerse;
  int? _endVerse;

  // ===== 형광펜 색 =====
  int _highlightColorValue = 0xFFFFF59D;

  // ===== ✅ 버전/두권보기 상태(리셋 방지 핵심) =====
  bool _isDual = false;
  String _translationA = 'kor_gae'; // 기본: 한글 개역개정
  String _translationB = 'kjv';     // 기본: 영문 KJV

  bool get isDual => _isDual;
  String get translationA => _translationA;
  String get translationB => _translationB;

  void setDual(bool v) {
    if (_isDual == v) return;
    _isDual = v;
    notifyListeners();
  }

  void setTranslationA(String id) {
    if (_translationA == id) return;
    _translationA = id;
    notifyListeners();
  }

  void setTranslationB(String id) {
    if (_translationB == id) return;
    _translationB = id;
    notifyListeners();
  }

  void setTranslations({
    required bool isDual,
    required String a,
    required String b,
  }) {
    var changed = false;
    if (_isDual != isDual) {
      _isDual = isDual;
      changed = true;
    }
    if (_translationA != a) {
      _translationA = a;
      changed = true;
    }
    if (_translationB != b) {
      _translationB = b;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  // ===== 점프 리스너 연결 =====
  void attachJumpListener(void Function(BibleJumpRequest req) listener) {
    _jumpListener = listener;

    if (_pendingJump != null) {
      final r = _pendingJump!;
      _pendingJump = null;
      _jumpListener?.call(r);
    }
  }

  void detachJumpListener() {
    _jumpListener = null;
  }

  // ✅ 중요: jumpTo는 "이동(스크롤)"만 한다. 선택/범위/색상은 절대 건드리지 않음.
  void jumpTo(BibleJumpRequest req) {
    if (_jumpListener != null) {
      _jumpListener!.call(req);
    } else {
      _pendingJump = req;
    }
  }

  // ===== 형광펜 색 =====
  void setHighlightColor(Color c) {
    _highlightColorValue = c.value;
    notifyListeners();
  }

  Color get highlightColor => Color(_highlightColorValue);
  int get highlightColorValue => _highlightColorValue;

  void clearSelection() {
    _startVerse = null;
    _endVerse = null;
    notifyListeners();
  }

  // ===== 범위 선택(A안) =====
  void selectVerseRange({
    required String bookId,
    required String bookKoName,
    required int chapter,
    required int verse,
  }) {
    final samePlace = (_bookId == bookId && _chapter == chapter);

    _bookId = bookId;
    _bookKoName = bookKoName;
    _chapter = chapter;

    if (samePlace &&
        _startVerse == verse &&
        (_endVerse == null || _endVerse == verse)) {
      _startVerse = null;
      _endVerse = null;
      notifyListeners();
      return;
    }

    if (!samePlace) {
      _startVerse = verse;
      _endVerse = null;
      notifyListeners();
      return;
    }

    if (_startVerse == null) {
      _startVerse = verse;
      _endVerse = null;
      notifyListeners();
      return;
    }

    if (_endVerse == null) {
      _endVerse = verse;
      if (_endVerse! < _startVerse!) {
        final tmp = _startVerse!;
        _startVerse = _endVerse;
        _endVerse = tmp;
      }
      notifyListeners();
      return;
    }

    // 이미 범위가 있으면 새 시작으로 리셋
    _startVerse = verse;
    _endVerse = null;
    notifyListeners();
  }

  bool isInSelectedRange({
    required String bookId,
    required int chapter,
    required int verse,
  }) {
    if (_bookId != bookId || _chapter != chapter) return false;
    if (_startVerse == null) return false;
    if (_endVerse == null) return verse == _startVerse;
    return verse >= _startVerse! && verse <= _endVerse!;
  }

  // ===== 메모(예배노트) 클릭 시: 범위+색상 세팅 후 이동 =====
  void jumpToMemoRange({
    required String bookId,
    required String bookKoName,
    required int chapter,
    required int startVerse,
    required int? endVerse,
    required int colorValue,
  }) {
    _bookId = bookId;
    _bookKoName = bookKoName;
    _chapter = chapter;
    _startVerse = startVerse;
    _endVerse = endVerse;

    _highlightColorValue = colorValue;

    notifyListeners(); // ✅ 먼저 하이라이트/색상 상태를 확정

    // ✅ 이동은 시작절로 스크롤만
    jumpTo(BibleJumpRequest(
      bookId: bookId,
      chapter: chapter,
      verse: startVerse,
    ));
  }

  // 메모 저장용(범위+색)
  ({String bookId, String bookKoName, int chapter, int startVerse, int? endVerse, int colorValue})?
  getSelectionWithColorRange() {
    if (_bookId == null ||
        _bookKoName == null ||
        _chapter == null ||
        _startVerse == null) return null;

    return (
    bookId: _bookId!,
    bookKoName: _bookKoName!,
    chapter: _chapter!,
    startVerse: _startVerse!,
    endVerse: _endVerse,
    colorValue: _highlightColorValue,
    );
  }
}