// lib/features/bible/bible_page.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'domain/bible_service.dart';
import 'presentation/controllers/bible_reader_controller.dart';
import 'presentation/pages/bible_reader_page.dart';
import 'presentation/pages/bible_search_tab.dart';
import 'presentation/pages/bible_note_tab.dart';
import 'presentation/widgets/memo_bottom_sheet.dart';
import 'presentation/widgets/highlight_color_picker.dart';

class BiblePage extends StatefulWidget {
  const BiblePage({super.key});

  @override
  State<BiblePage> createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  late final BibleService bibleService;
  late final BibleReaderController readerController;

  // ✅ BiblePage 전용 테마 토글(앱 전체 테마에는 영향 없음)
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    bibleService = GetIt.I<BibleService>();
    readerController = BibleReaderController();
  }

  @override
  void dispose() {
    // (Controller dispose가 필요한 구조가 아니라면 그대로 둬도 됩니다)
    super.dispose();
  }

  ThemeData _buildBibleTheme(BuildContext context, {required bool dark}) {
    final base = Theme.of(context);

    const darkBg = Color(0xFF0B1220);
    const darkSurface = Color(0xFF0F172A);

    // ✅ M3: 라이트/다크를 명확히 선언 + onSurface/onBackground까지 지정
    final scheme = base.colorScheme.copyWith(
      brightness: dark ? Brightness.dark : Brightness.light,
      surface: dark ? darkSurface : base.colorScheme.surface,
      background: dark ? darkBg : base.colorScheme.background,
      onSurface: dark ? Colors.white : Colors.black,
      onBackground: dark ? Colors.white : Colors.black,
    );

    // ✅ 글씨가 안 보이는 문제의 핵심: AppBar/TabBar/본문 기본 색을 확실히 잡는다
    final txt = base.textTheme;

    return base.copyWith(
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,

      scaffoldBackgroundColor: dark ? darkBg : base.scaffoldBackgroundColor,
      canvasColor: dark ? darkBg : base.canvasColor,

      dividerColor: dark ? Colors.white12 : Colors.black12,

      // ✅ 기본 텍스트 컬러 강제(본문/타이틀 모두)
      textTheme: txt.copyWith(
        bodyLarge: (txt.bodyLarge ?? const TextStyle()).copyWith(
          color: dark ? Colors.white : Colors.black,
        ),
        bodyMedium: (txt.bodyMedium ?? const TextStyle()).copyWith(
          color: dark ? Colors.white : Colors.black,
        ),
        bodySmall: (txt.bodySmall ?? const TextStyle()).copyWith(
          color: dark ? Colors.white70 : Colors.black87,
        ),
        titleLarge: (txt.titleLarge ?? const TextStyle()).copyWith(
          color: dark ? Colors.white : Colors.black,
        ),
        titleMedium: (txt.titleMedium ?? const TextStyle()).copyWith(
          color: dark ? Colors.white : Colors.black,
        ),
      ),

      // ✅ AppBar 타이틀이 안 보이는 문제 해결: titleTextStyle 명시
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: dark ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(
          color: dark ? Colors.white : Colors.black,
        ),
        actionsIconTheme: IconThemeData(
          color: dark ? Colors.white : Colors.black,
        ),
      ),

      // ✅ TabBar 라벨 가독성 보장
      tabBarTheme: TabBarThemeData(
        labelColor: dark ? Colors.white : Colors.black,
        unselectedLabelColor: dark ? Colors.white70 : Colors.black54,
        indicatorColor: base.colorScheme.primary,
      ),


      // ✅ 버튼/시트 등도 대비가 유지되도록
      iconTheme: IconThemeData(color: dark ? Colors.white : Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bibleTheme = _buildBibleTheme(context, dark: _isDark);

    return Theme(
      data: bibleTheme,
      child: DefaultTabController(
        length: 3,
        child: Builder(
          builder: (ctx) {
            final tabController = DefaultTabController.of(ctx);

            return Scaffold(
              appBar: AppBar(
                title: const Text('성경'),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: '성경'),
                    Tab(text: '검색'),
                    Tab(text: '예배노트'),
                  ],
                ),
                actions: [
                  // ✅ BiblePage 전용 다크/라이트 토글
                  IconButton(
                    tooltip: _isDark ? '라이트 모드' : '다크 모드',
                    onPressed: () => setState(() => _isDark = !_isDark),
                    icon: Icon(
                      _isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    ),
                  ),

                  IconButton(
                    tooltip: '형광펜 색상',
                    onPressed: () async {
                      final picked = await showHighlightColorPicker(
                        context,
                        initial: readerController.highlightColor,
                      );
                      if (picked != null) {
                        readerController.setHighlightColor(picked);
                        // ✅ 색상 변경이 곧바로 반영되게(리더가 리스너로 setState 하긴 하지만 안전하게)
                        if (mounted) setState(() {});
                      }
                    },
                    icon: const Icon(Icons.format_color_fill),
                  ),

                  IconButton(
                    tooltip: '메모',
                    onPressed: () async {
                      await showMemoBottomSheet(
                        context,
                        readerController: readerController,
                      );
                    },
                    icon: const Icon(Icons.note_add_outlined),
                  ),
                ],
              ),
              body: TabBarView(
                children: [
                  BibleReaderPage(
                    bibleService: bibleService,
                    readerController: readerController,
                    initialBookId: 'GEN',
                    initialChapter: 1,
                  ),
                  BibleSearchTab(
                    bibleService: bibleService,
                    readerController: readerController,
                    tabController: tabController,
                  ),
                  BibleNoteTab(
                    readerController: readerController,
                    tabController: tabController,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
