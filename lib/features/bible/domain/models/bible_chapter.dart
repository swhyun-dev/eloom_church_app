import 'bible_ref.dart';
import 'bible_verse.dart';

class BibleChapter {
  final BibleRef ref;
  final String translationId;
  final String translationName;
  final List<BibleVerse> verses;

  const BibleChapter({
    required this.ref,
    required this.translationId,
    required this.translationName,
    required this.verses,
  });
}
