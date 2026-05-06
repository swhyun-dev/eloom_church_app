// lib/features/bible/presentation/pages/bible_search_tab.dart
import 'package:flutter/material.dart';

import '../controllers/bible_reader_controller.dart';
import '../search/bible_query_parser.dart';
import '../../domain/bible_service.dart';
import '../../domain/constants/bible_books.dart';

class BibleSearchTab extends StatefulWidget {
  final BibleService bibleService; // (지금은 이동만이라 직접 사용하진 않지만 유지 OK)
  final BibleReaderController readerController;
  final TabController tabController;

  const BibleSearchTab({
    super.key,
    required this.bibleService,
    required this.readerController,
    required this.tabController,
  });

  @override
  State<BibleSearchTab> createState() => _BibleSearchTabState();
}

class _BibleSearchTabState extends State<BibleSearchTab> {
  final _c = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _leadingBookPart(String text) {
    final s = text.trimLeft();
    final m = RegExp(r'^([^\d:]+)').firstMatch(s);
    return (m?.group(1) ?? '').trim();
  }

  void _go() {
    final text = _c.text.trim();
    if (text.isEmpty) return;

    // ✅ 책 후보가 애매하면 안내(창세기로 떨어지지 않게)
    final bookPart = _leadingBookPart(text);
    if (bookPart.isNotEmpty) {
      final candidates = findBookCandidates(bookPart);
      if (candidates.isEmpty) {
        setState(() => _error = '책 이름을 찾을 수 없습니다. 예: 마태 5:3 / 요 3:16 / Genesis 1');
        return;
      }
      if (candidates.length > 1) {
        final names = candidates
            .map((id) => bibleBooks.firstWhere((b) => b.id == id).koName)
            .take(5)
            .join(', ');
        setState(() => _error = '책이 여러 권으로 인식됩니다: $names\n좀 더 정확히 입력하거나 목록에서 선택해주세요.');
        return;
      }
    }

    final parsed = parseBibleQuery(text);
    if (parsed == null) {
      setState(() => _error = '예: 마태 5:3 / 마태복음 5:3 / 요 3:16 / 창 1:1-4 / Genesis 1');
      return;
    }

    setState(() => _error = null);

    widget.readerController.jumpTo(
      BibleJumpRequest(
        bookId: parsed.bookId,
        chapter: parsed.chapter,
        verse: parsed.verse,
      ),
    );

    widget.tabController.animateTo(0); // 성경 탭으로 이동
  }

  Widget _chip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _c.text = text;
        _go();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 자동완성 옵션: 책 이름/부분입력 기반
    Iterable<String> optionsBuilder(TextEditingValue v) {
      final input = v.text;
      final bookPart = _leadingBookPart(input);

      // 숫자(장/절) 입력 중이면 옵션 과다 표시 방지
      if (bookPart.isEmpty) return const Iterable<String>.empty();

      final candidates = findBookCandidates(bookPart);
      if (candidates.isEmpty) return const Iterable<String>.empty();

      // 표시 문자열은 "한글책이름 (ID)" 형태
      return candidates.take(10).map((id) {
        final book = bibleBooks.firstWhere((b) => b.id == id);
        return '${book.koName} ($id)';
      });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('구절 이동', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),

          // ✅ Autocomplete 적용
          Autocomplete<String>(
            optionsBuilder: (v) => optionsBuilder(v),
            onSelected: (selected) {
              final idMatch = RegExp(r'\(([A-Z0-9]+)\)$').firstMatch(selected.trim());
              final bookId = idMatch?.group(1);
              if (bookId == null) return;

              // 사용자가 입력한 숫자(장/절) 일부가 있으면 반영
              final rest = _c.text.replaceFirst(RegExp(r'^[^\d:]+'), '').trim();
              final m = RegExp(r'^(\d+)(?:\s*:\s*(\d+))?').firstMatch(rest);

              final chapter = m != null ? (int.tryParse(m.group(1)!) ?? 1) : 1;
              final verse = (m != null && m.group(2) != null) ? int.tryParse(m.group(2)!) : null;

              widget.readerController.jumpTo(
                BibleJumpRequest(bookId: bookId, chapter: chapter, verse: verse),
              );
              widget.tabController.animateTo(0);
            },
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
              // Autocomplete가 내부 controller를 쓰는데, 우리는 _c를 쓰고 싶음
              // => 내부 controller를 _c와 동기화
              textEditingController.value = _c.value;

              textEditingController.addListener(() {
                if (_c.value.text != textEditingController.text) {
                  _c.value = textEditingController.value;
                }
              });

              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: '예: 마태 5:3 / 요 3:16 / 창 1:1-4 / Genesis 1',
                  errorText: _error,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: _go,
                    icon: const Icon(Icons.search),
                  ),
                ),
                onSubmitted: (_) => _go(),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: options.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final opt = options.elementAt(index);
                        return ListTile(
                          dense: true,
                          title: Text(opt),
                          onTap: () => onSelected(opt),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('요 3:16'),
              _chip('창 1:1-4'),
              _chip('롬 8'),
              _chip('마태 5:3'),
              _chip('Genesis 1'),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            '팁: 책 이름은 일부만 입력해도 됩니다. (예: "마태" → 마태복음)\n'
                '책이 여러 권으로 인식되면(예: "마") 자동완성 목록에서 선택해주세요.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), height: 1.35),
          ),
        ],
      ),
    );
  }
}