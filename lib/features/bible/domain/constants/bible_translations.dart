class BibleTranslation {
  final String id;     // translationId (DB/API)
  final String label;  // UI 표시명
  final String language; // "ko" | "en"
  const BibleTranslation({
    required this.id,
    required this.label,
    required this.language,
  });
}

/// ✅ 최종 사용 역본 (DB/API 기준)
/// - 한글: 개역개정, 현대인의성경, 새번역
/// - 영문: NIV, KJV
const translationsKo = <BibleTranslation>[
  BibleTranslation(id: 'kor_gae', label: '개역개정', language: 'ko'),
  BibleTranslation(id: 'kor_hdb', label: '현대인의성경', language: 'ko'),
  BibleTranslation(id: 'kor_saenew', label: '새번역', language: 'ko'),
];

const translationsEn = <BibleTranslation>[
  BibleTranslation(id: 'niv', label: 'NIV', language: 'en'),
  BibleTranslation(id: 'kjv', label: 'KJV', language: 'en'),
];

/// (선택) 전체 리스트가 필요할 때 사용
const translationsAll = <BibleTranslation>[
  ...translationsKo,
  ...translationsEn,
];