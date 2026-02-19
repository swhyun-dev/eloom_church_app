class BibleApiComVerseDto {
  final int verse;
  final String text;

  BibleApiComVerseDto({required this.verse, required this.text});

  factory BibleApiComVerseDto.fromJson(Map<String, dynamic> json) {
    return BibleApiComVerseDto(
      verse: (json['verse'] as num).toInt(),
      text: (json['text'] as String).trim(),
    );
  }
}

class BibleApiComResponseDto {
  final String reference;
  final String translationId;
  final String translationName;
  final List<BibleApiComVerseDto> verses;

  BibleApiComResponseDto({
    required this.reference,
    required this.translationId,
    required this.translationName,
    required this.verses,
  });

  factory BibleApiComResponseDto.fromJson(Map<String, dynamic> json) {
    final verses = (json['verses'] as List<dynamic>? ?? [])
        .map((e) => BibleApiComVerseDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return BibleApiComResponseDto(
      reference: (json['reference'] ?? '') as String,
      translationId: (json['translation_id'] ?? '') as String,
      translationName: (json['translation_name'] ?? '') as String,
      verses: verses,
    );
  }
}
