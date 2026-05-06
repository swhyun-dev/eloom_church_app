import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// ✅ 여기 경로가 실제 파일 위치와 다르면 "Undefined class 'BibleService'"가 납니다.
// 프로젝트에서 bible_service.dart 실제 위치에 맞게 이 import 한 줄만 수정하세요.
import '../../domain/bible_service.dart';

import '../../domain/models/bible_chapter.dart';
import '../../domain/constants/bible_books.dart';
import '../../domain/constants/bible_translations.dart' as tr;
import '../../domain/models/bible_book.dart';
import '../controllers/bible_reader_controller.dart';

class BibleReaderPage extends StatefulWidget {
  final BibleService bibleService;
  final BibleReaderController readerController;

  /// DB/API book code (예: GEN, JHN)
  final String? initialBookId;
  final int? initialChapter;

  const BibleReaderPage({
    super.key,
    required this.bibleService,
    required this.readerController,
    this.initialBookId,
    this.initialChapter,
  });

  @override
  State<BibleReaderPage> createState() => _BibleReaderPageState();
}

class _BibleReaderPageState extends State<BibleReaderPage>
    with AutomaticKeepAliveClientMixin {
  BibleBook _book = bibleBooks.first;
  int _chapter = 1;

  bool _loading = false;
  String? _error;

  BibleChapter? _chapterA;
  BibleChapter? _chapterB;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
  ItemPositionsListener.create();

  int? _pendingScrollVerse;
  late final VoidCallback _controllerListener;

  // ✅ 구약/신약 분리
  static const int _otCount = 39; // 구약 39권
  List<BibleBook> get _oldTestament => bibleBooks.take(_otCount).toList();
  List<BibleBook> get _newTestament => bibleBooks.skip(_otCount).toList();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // 초기 book/chapter 설정
    if (widget.initialBookId != null) {
      final found =
      bibleBooks.where((b) => b.id == widget.initialBookId).toList();
      if (found.isNotEmpty) _book = found.first;
    }
    if (widget.initialChapter != null && widget.initialChapter! > 0) {
      _chapter = widget.initialChapter!;
    }

    _controllerListener = () {
      if (mounted) setState(() {});
    };
    widget.readerController.addListener(_controllerListener);

    widget.readerController.attachJumpListener((req) {
      setState(() {
        final found = bibleBooks.where((b) => b.id == req.bookId).toList();
        if (found.isNotEmpty) _book = found.first;
        _chapter = req.chapter;
        _pendingScrollVerse = req.verse;
      });

      _load();
    });

    _load();
  }

  @override
  void dispose() {
    widget.readerController.removeListener(_controllerListener);
    widget.readerController.detachJumpListener();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final isDual = widget.readerController.isDual;
    final translationA = widget.readerController.translationA;
    final translationB = widget.readerController.translationB;

    try {
      final a = await widget.bibleService.getChapter(
        book: _book.id,
        chapter: _chapter,
        translationId: translationA,
      );

      BibleChapter? b;
      if (isDual) {
        b = await widget.bibleService.getChapter(
          book: _book.id,
          chapter: _chapter,
          translationId: translationB,
        );
      }

      setState(() {
        _chapterA = a;
        _chapterB = b;
      });

      // 데이터 로드 끝나고 스크롤 예약
      final verse = _pendingScrollVerse;
      if (verse != null) {
        _pendingScrollVerse = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _scrollToVerseByIndex(verse);
        });
      }
    } catch (e) {
      // ✅ provider에서 사용자용 메시지로 throw하면 여기엔 그 문구만 들어옵니다.
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _scrollToVerseByIndex(int verse) {
    if (_chapterA == null) return;

    final verses = _chapterA!.verses;
    final index = verses.indexWhere((v) => v.verse == verse);
    if (index < 0) return;

    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        alignment: 0.12,
      );
    }
  }

  String _translationLabel(String id) {
    final found = tr.translationsAll.where((t) => t.id == id).toList();
    if (found.isEmpty) return id;
    return found.first.label;
  }

  Future<void> _openPicker({required int initialTabIndex}) async {
    BibleBook tempBook = _book;
    int tempChapter = _chapter;

    // ✅ 컨트롤러 값으로 시작(리셋 방지)
    bool tempDual = widget.readerController.isDual;
    String tempA = widget.readerController.translationA;
    String tempB = widget.readerController.translationB;

    // 권선택 탭에서 구약/신약 기본 탭 지정
    final isNT = bibleBooks.indexWhere((b) => b.id == tempBook.id) >= _otCount;

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              height: MediaQuery.of(ctx).size.height * 0.62,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: DefaultTabController(
                length: 3,
                initialIndex: initialTabIndex.clamp(0, 2),
                child: StatefulBuilder(
                  builder: (ctx, setModal) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 8),
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const TabBar(
                          tabs: [
                            Tab(text: '권선택'),
                            Tab(text: '장선택'),
                            Tab(text: '역본선택'), // ✅ 명칭 변경
                          ],
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _BookPickerOTNT(
                                initialIsNewTestament: isNT,
                                selected: tempBook,
                                oldBooks: _oldTestament,
                                newBooks: _newTestament,
                                onPick: (b) => setModal(() => tempBook = b),
                              ),
                              _ChapterPicker(
                                total: tempBook.chapters,
                                selected: tempChapter,
                                onPick: (c) => setModal(() => tempChapter = c),
                              ),
                              _VersionPicker(
                                isDual: tempDual,
                                translationA: tempA,
                                translationB: tempB,
                                onToggleDual: (v) => setModal(() => tempDual = v),
                                onPickA: (id) => setModal(() => tempA = id),
                                onPickB: (id) => setModal(() => tempB = id),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('취소'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('선택완료'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    if (applied == true) {
      setState(() {
        _book = tempBook;
        _chapter = tempChapter.clamp(1, tempBook.chapters);
      });

      // ✅ 선택 결과를 컨트롤러에 저장(탭 이동해도 유지)
      widget.readerController.setTranslations(
        isDual: tempDual,
        a: tempA,
        b: tempB,
      );

      _load();
    }
  }

  void _prevChapter() {
    if (_chapter <= 1) return;
    setState(() => _chapter -= 1);
    _load();
  }

  void _nextChapter() {
    if (_chapter >= _book.chapters) return;
    setState(() => _chapter += 1);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ KeepAlive 필수
    return Column(
      children: [
        _buildControlsV2(),
        const Divider(height: 1),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildControlsV2() {
    final cs = Theme.of(context).colorScheme;

    final title = '${_book.koName} $_chapter장';

    final canPrev = !_loading && _chapter > 1;
    final canNext = !_loading && _chapter < _book.chapters;

    final isDual = widget.readerController.isDual;
    final a = widget.readerController.translationA;
    final b = widget.readerController.translationB;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        children: [
          Row(
            children: [
              _CircleNavButton(
                icon: Icons.chevron_left,
                enabled: canPrev,
                onTap: canPrev ? _prevChapter : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _CircleNavButton(
                icon: Icons.chevron_right,
                enabled: canNext,
                onTap: canNext ? _nextChapter : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChipButton(
                  label: _book.koName,
                  onTap: () => _openPicker(initialTabIndex: 0),
                ),
                _ChipButton(
                  label: '$_chapter장',
                  onTap: () => _openPicker(initialTabIndex: 1),
                ),
                _ChipButton(
                  label: isDual
                      ? '${_translationLabel(a)} + ${_translationLabel(b)}'
                      : _translationLabel(a),
                  onTap: () => _openPicker(initialTabIndex: 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('다시 시도')),
            ],
          ),
        ),
      );
    }

    if (_chapterA == null) return const Center(child: Text('본문이 없습니다.'));

    final aVerses = _chapterA!.verses;

    final isDual = widget.readerController.isDual;

    final bMap = <int, String>{};
    if (isDual && _chapterB != null) {
      for (final v in _chapterB!.verses) {
        bMap[v.verse] = v.text;
      }
    }

    final highlight = widget.readerController.highlightColor;

    return ScrollablePositionedList.separated(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: aVerses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final v = aVerses[i];
        final bText = bMap[v.verse];

        final selected = widget.readerController.isInSelectedRange(
          bookId: _book.id,
          chapter: _chapter,
          verse: v.verse,
        );

        return Stack(
          children: [
            if (selected)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Container(
                    decoration: BoxDecoration(
                      color: highlight.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              child: _VerseTile(
                verse: v.verse,
                textA: v.text,
                textB: (isDual ? bText : null),
                onTap: () {
                  widget.readerController.selectVerseRange(
                    bookId: _book.id,
                    bookKoName: _book.koName,
                    chapter: _chapter,
                    verse: v.verse,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.expand_more, size: 18, color: cs.onSurface.withValues(alpha: 0.55)),
          ],
        ),
      ),
    );
  }
}

/// ✅ 구약/신약 탭 분리 픽커
class _BookPickerOTNT extends StatelessWidget {
  const _BookPickerOTNT({
    required this.initialIsNewTestament,
    required this.selected,
    required this.oldBooks,
    required this.newBooks,
    required this.onPick,
  });

  final bool initialIsNewTestament;
  final BibleBook selected;
  final List<BibleBook> oldBooks;
  final List<BibleBook> newBooks;
  final ValueChanged<BibleBook> onPick;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialIsNewTestament ? 1 : 0,
      child: Column(
        children: [
          const SizedBox(height: 10),
          const TabBar(
            tabs: [
              Tab(text: '구약'),
              Tab(text: '신약'),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              children: [
                _BookList(selected: selected, books: oldBooks, onPick: onPick),
                _BookList(selected: selected, books: newBooks, onPick: onPick),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookList extends StatelessWidget {
  const _BookList({
    required this.selected,
    required this.books,
    required this.onPick,
  });

  final BibleBook selected;
  final List<BibleBook> books;
  final ValueChanged<BibleBook> onPick;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final b = books[i];
        final active = b.id == selected.id;

        return InkWell(
          onTap: () => onPick(b),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: active ? cs.primary.withValues(alpha: 0.10) : cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                active ? cs.primary.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    b.koName,
                    style: TextStyle(
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                if (active) Icon(Icons.check, color: cs.primary),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChapterPicker extends StatelessWidget {
  const _ChapterPicker({
    required this.total,
    required this.selected,
    required this.onPick,
  });

  final int total;
  final int selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = List.generate(total, (i) => i + 1);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final c = items[i];
        final active = c == selected;

        return InkWell(
          onTap: () => onPick(c),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? cs.primary : cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? cs.primary : Colors.black.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              '$c',
              style: TextStyle(
                color: active ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.85),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VersionPicker extends StatelessWidget {
  const _VersionPicker({
    required this.isDual,
    required this.translationA,
    required this.translationB,
    required this.onToggleDual,
    required this.onPickA,
    required this.onPickB,
  });

  final bool isDual;
  final String translationA;
  final String translationB;
  final ValueChanged<bool> onToggleDual;
  final ValueChanged<String> onPickA;
  final ValueChanged<String> onPickB;

  // ✅ "대조 역본"을 완전히 다른 색으로 (라이트/다크 모두 대비 좋게)
  Color _contrastFill(ColorScheme cs) {
    // teal 계열: 다크에서도 잘 튀고, 라이트에서도 과하지 않음
    final base = cs.brightness == Brightness.dark
        ? const Color(0xFF2DD4BF) // teal 400
        : const Color(0xFF0F766E); // teal 700
    return base;
  }

  Color _contrastSurface(ColorScheme cs) {
    // 선택 강조 배경(살짝 깔아주는 용도)
    return cs.brightness == Brightness.dark
        ? const Color(0xFF0B3B38) // 어두운 teal 배경
        : const Color(0xFFE6FFFB); // 매우 연한 teal 배경
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        Row(
          children: [
            Expanded(
              child: _SegmentButton(
                label: '한권보기',
                active: !isDual,
                onTap: () => onToggleDual(false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SegmentButton(
                label: '두권보기',
                active: isDual,
                onTap: () => onToggleDual(true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _VersionColumn(
                title: '기본 역본', // ✅ 명칭 변경
                enabled: true,
                selectedId: translationA,
                onPick: onPickA,
                // 기본 역본: 기존 스타일(Primary 계열)
                activeFill: cs.primary.withValues(alpha: 0.14),
                activeBorder: cs.primary.withValues(alpha: 0.55),
                activeText: cs.onSurface,
                badgeColor: cs.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _VersionColumn(
                title: '대조 역본', // ✅ 명칭 변경
                enabled: isDual,
                selectedId: translationB,
                onPick: onPickB,
                // 대조 역본: teal 계열로 완전히 구분
                activeFill: _contrastSurface(cs),
                activeBorder: _contrastFill(cs).withValues(alpha: 0.85),
                activeText: cs.onSurface,
                badgeColor: _contrastFill(cs),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        Text(
          '두권보기는 기본 역본/대조 역본을 나란히 표시합니다.',
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? cs.primary : Colors.black.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: active ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

class _VersionColumn extends StatelessWidget {
  const _VersionColumn({
    required this.title,
    required this.enabled,
    required this.selectedId,
    required this.onPick,
    required this.activeFill,
    required this.activeBorder,
    required this.activeText,
    required this.badgeColor,
  });

  final String title;
  final bool enabled;
  final String selectedId;
  final ValueChanged<String> onPick;

  // ✅ 컬럼별 커스텀 컬러(기본/대조 구분)
  final Color activeFill;
  final Color activeBorder;
  final Color activeText;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ),
              // ✅ 헤더 뱃지로도 한 번 더 구분(다크에서도 선명)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: cs.brightness == Brightness.dark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: cs.brightness == Brightness.dark ? 0.55 : 0.45),
                  ),
                ),
                child: Text(
                  title == '기본 역본' ? 'A' : 'B',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: badgeColor.withValues(alpha: cs.brightness == Brightness.dark ? 0.95 : 0.90),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...tr.translationsAll.map((t) {
            final active = t.id == selectedId;

            final fill = active ? activeFill : cs.surface;
            final border = active ? activeBorder : Colors.black.withValues(alpha: 0.12);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: enabled ? () => onPick(t.id) : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: Text(
                    t.label,
                    style: TextStyle(
                      fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                      color: active ? activeText : cs.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _VerseTile extends StatelessWidget {
  final int verse;
  final String textA;
  final String? textB;
  final VoidCallback onTap;

  const _VerseTile({
    required this.verse,
    required this.textA,
    required this.textB,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ✅ 대조역본(B) 텍스트 색: 다크에서도 확실히 구별되게 teal 계열
    final contrastTextColor = cs.brightness == Brightness.dark
        ? const Color(0xFF5EEAD4) // teal 300
        : const Color(0xFF0F766E); // teal 700

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$verse',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textA,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: cs.onSurface.withValues(alpha: 0.88),
                  ),
                ),
                if (textB != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    textB!,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: contrastTextColor, // ✅ 대조역본은 확실히 다른 색
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleNavButton extends StatelessWidget {
  const _CircleNavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cs.surface,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
          ),
          child: Icon(icon, size: 24, color: cs.onSurface.withValues(alpha: 0.75)),
        ),
      ),
    );
  }
}