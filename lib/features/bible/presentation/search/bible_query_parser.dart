// lib/features/bible/presentation/search/bible_query_parser.dart
import '../../domain/constants/bible_books.dart';

class BibleParsedQuery {
  final String bookId; // 예: GEN, MAT
  final int chapter;   // 1+
  final int? verse;    // optional

  const BibleParsedQuery({
    required this.bookId,
    required this.chapter,
    this.verse,
  });
}

/// ✅ 지원 예:
/// - "요 3:16" / "창 1:1-4" / "롬 8"
/// - "마태 5:3" / "마태복음 5:3" / "마태 5"
/// - "John 3:16" / "Genesis 1" / "Matthew 5:3" / "Matt 5"
BibleParsedQuery? parseBibleQuery(String input) {
  final raw = input.trim();
  if (raw.isEmpty) return null;

  // 공백/구분자 정리
  final s = raw
      .replaceAll(RegExp(r'[,\.\(\)\[\]\{\}]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // bookPart: 숫자/구분자 나오기 전까지(책 이름 영역)
  // rest: 이후 장/절 영역
  final m = RegExp(r'^([^\d:]+)\s*(.*)$').firstMatch(s);
  if (m == null) return null;

  final bookPart = (m.group(1) ?? '').trim();
  final rest = (m.group(2) ?? '').trim();

  final candidates = findBookCandidates(bookPart);
  if (candidates.isEmpty) return null;

  // 애매하면(여러 개) -> null (UI에서 자동완성 선택 유도)
  if (candidates.length != 1) return null;

  final bookId = candidates.single;

  // 장/절 파싱
  // 허용: "3", "3:16", "3:16-18"(절은 16만 사용), ""(없으면 1장)
  if (rest.isEmpty) {
    return BibleParsedQuery(bookId: bookId, chapter: 1, verse: null);
  }

  final m2 = RegExp(r'^(\d+)(?:\s*[:]\s*(\d+))?').firstMatch(rest);
  if (m2 == null) return null;

  final chapter = int.tryParse(m2.group(1)!) ?? 1;
  final verse = m2.group(2) != null ? int.tryParse(m2.group(2)!) : null;

  if (chapter <= 0) return null;
  return BibleParsedQuery(bookId: bookId, chapter: chapter, verse: verse);
}

/// ✅ 책 후보를 여러개 뽑아줌(부분검색/약칭/영문 포함)
/// - "마태" -> ["MAT"]
/// - "마" -> ["MAT","MRK"] 처럼 복수 가능(애매)
List<String> findBookCandidates(String bookInput) {
  final q0 = bookInput.trim();
  if (q0.isEmpty) return [];

  final q = _normalize(q0);

  // 1) ID 직접 입력(GEN/JHN 등)
  final direct = bibleBooks.where((b) => _normalize(b.id) == q).toList();
  if (direct.isNotEmpty) return [direct.first.id];

  // 2) 한글 전체/부분 매칭(koName, 별칭)
  final koMatches = <String>[];

  for (final b in bibleBooks) {
    final ko = _normalize(b.koName);
    if (ko.contains(q) || q.contains(ko)) {
      koMatches.add(b.id);
      continue;
    }
    final aliases = _koAliases(b.id);
    if (aliases.any((a) => _normalize(a).contains(q) || q.contains(_normalize(a)))) {
      koMatches.add(b.id);
    }
  }

  // 3) 영문 매칭(대표 별칭만)
  final enMatches = <String>[];
  final en = _enMap();
  for (final e in en.entries) {
    if (_normalize(e.key).contains(q) || q.contains(_normalize(e.key))) {
      enMatches.add(e.value);
    }
  }

  final merged = {...koMatches, ...enMatches}.toList();

  // 안정적으로 정렬(입력과 가장 가까운 것 우선)
  merged.sort((a, b) {
    final aScore = _scoreBookMatch(a, q0);
    final bScore = _scoreBookMatch(b, q0);
    return bScore.compareTo(aScore);
  });

  return merged;
}

int _scoreBookMatch(String bookId, String rawQuery) {
  final q = _normalize(rawQuery);
  final book = bibleBooks.firstWhere((b) => b.id == bookId);
  final ko = _normalize(book.koName);

  // 완전 동일/접두/포함 순으로 점수
  if (ko == q) return 100;
  if (ko.startsWith(q)) return 90;
  if (ko.contains(q)) return 70;

  // 별칭도 가산
  final aliases = _koAliases(bookId).map(_normalize).toList();
  if (aliases.any((a) => a == q)) return 85;
  if (aliases.any((a) => a.startsWith(q))) return 75;
  if (aliases.any((a) => a.contains(q))) return 60;

  return 10;
}

String _normalize(String s) {
  return s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[^a-z0-9가-힣]'), '');
}

/// ✅ 한글 별칭(필요한 것만 우선 추가)
List<String> _koAliases(String id) {
  switch (id) {
    case 'GEN': return ['창', '창세', '창세기'];
    case 'EXO': return ['출', '출애', '출애굽', '출애굽기'];
    case 'PSA': return ['시', '시편'];
    case 'PRO': return ['잠', '잠언'];
    case 'ISA': return ['사', '이사야'];
    case 'JER': return ['렘', '예레미야'];
    case 'MAT': return ['마태', '마태복음'];
    case 'MRK': return ['마가', '마가복음'];
    case 'LUK': return ['누가', '누가복음'];
    case 'JHN': return ['요', '요한', '요한복음'];
    case 'ACT': return ['행', '사도행전'];
    case 'ROM': return ['롬', '로마서'];
    case '1CO': return ['고전', '고린도전서'];
    case '2CO': return ['고후', '고린도후서'];
    case 'GAL': return ['갈', '갈라디아서'];
    case 'EPH': return ['엡', '에베소서'];
    case 'PHP': return ['빌', '빌립보서'];
    case 'COL': return ['골', '골로새서'];
    case '1TH': return ['살전', '데살로니가전서'];
    case '2TH': return ['살후', '데살로니가후서'];
    case '1TI': return ['딤전', '디모데전서'];
    case '2TI': return ['딤후', '디모데후서'];
    case 'HEB': return ['히', '히브리서'];
    case 'JAS': return ['약', '야고보서'];
    case '1PE': return ['벧전', '베드로전서'];
    case '2PE': return ['벧후', '베드로후서'];
    case '1JN': return ['요일', '요한일서'];
    case '2JN': return ['요이', '요한이서'];
    case '3JN': return ['요삼', '요한삼서'];
    case 'JUD': return ['유', '유다서'];
    case 'REV': return ['계', '요한계시록', '계시록'];
    default: return const [];
  }
}

/// ✅ 영문 별칭(대표만)
Map<String, String> _enMap() {
  return {
    'genesis': 'GEN',
    'gen': 'GEN',
    'exodus': 'EXO',
    'exo': 'EXO',
    'psalm': 'PSA',
    'psalms': 'PSA',
    'ps': 'PSA',
    'proverbs': 'PRO',
    'prov': 'PRO',
    'isaiah': 'ISA',
    'jeremiah': 'JER',
    'matthew': 'MAT',
    'matt': 'MAT',
    'mark': 'MRK',
    'luke': 'LUK',
    'john': 'JHN',
    'acts': 'ACT',
    'romans': 'ROM',
    'rom': 'ROM',
    'revelation': 'REV',
    'rev': 'REV',
  };
}