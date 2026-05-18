import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/bulletin.dart';
import '../providers/bulletin_providers.dart';

/// 날짜(년/월/주일) 선택형 주보 뷰어 — PageView 슬라이드 기반.
class BulletinPage extends ConsumerStatefulWidget {
  const BulletinPage({super.key});

  @override
  ConsumerState<BulletinPage> createState() => _BulletinPageState();
}

class _BulletinPageState extends ConsumerState<BulletinPage> {
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int day = DateTime.now().day;
  int pageIndex = 0;

  late final PageController _pageController = PageController();

  List<int> get years => List.generate(10, (i) => 2020 + i);
  List<int> get months => List.generate(12, (i) => i + 1);
  List<int> get sundayDays => _getSundays(year, month);

  @override
  void initState() {
    super.initState();
    _ensureValidDay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _ensureValidDay() {
    final list = sundayDays;
    if (list.isEmpty) return;
    if (list.contains(day)) return;
    int? best;
    for (final s in list) {
      if (s <= day) best = s;
    }
    day = best ?? list.first;
  }

  void _resetPage() {
    pageIndex = 0;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _setYear(int v) => setState(() {
        year = v;
        _ensureValidDay();
        _resetPage();
      });

  void _setMonth(int v) => setState(() {
        month = v;
        _ensureValidDay();
        _resetPage();
      });

  void _setDay(int v) => setState(() {
        day = v;
        _resetPage();
      });

  void _animateToPage(int target) {
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  List<int> _getSundays(int y, int m) {
    final lastDay = DateTime(y, m + 1, 0).day;
    return [
      for (int d = 1; d <= lastDay; d++)
        if (DateTime(y, m, d).weekday == DateTime.sunday) d,
    ];
  }

  Bulletin? _findBulletin(List<Bulletin> all) {
    try {
      return all.firstWhere(
        (b) => b.date.year == year && b.date.month == month && b.date.day == day,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final asyncList = ref.watch(bulletinListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('교회주보'), centerTitle: true),
      body: AsyncValueBuilder<List<Bulletin>>(
        value: asyncList,
        onRetry: () => ref.invalidate(bulletinListProvider),
        isEmpty: (_) => false,
        builder: (all) {
          final bulletin = _findBulletin(all);
          final images = bulletin?.imageUrls ?? const <String>[];
          final maxPage = images.isEmpty ? 0 : images.length - 1;
          final idx = pageIndex.clamp(0, maxPage);

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _DropdownBox<int>(
                          value: year,
                          items: years,
                          labelBuilder: (v) => '$v년',
                          onChanged: _setYear,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 3,
                        child: _DropdownBox<int>(
                          value: month,
                          items: months,
                          labelBuilder: (v) => '$v월',
                          onChanged: _setMonth,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 3,
                        child: _DropdownBox<int>(
                          value: day,
                          items: sundayDays,
                          labelBuilder: (v) => '$v일',
                          onChanged: _setDay,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                            color: Colors.black.withValues(alpha: 0.06),
                          ),
                        ],
                        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: bulletin == null
                          ? _EmptyState(year: year, month: month, day: day)
                          : _SlideViewer(
                              images: images,
                              currentIndex: idx,
                              maxPage: maxPage,
                              pageController: _pageController,
                              onPageChanged: (p) =>
                                  setState(() => pageIndex = p),
                              onPrev: idx > 0
                                  ? () => _animateToPage(idx - 1)
                                  : null,
                              onNext: idx < maxPage
                                  ? () => _animateToPage(idx + 1)
                                  : null,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// PageView + 오버레이 화살표 + 페이지 인디케이터.
class _SlideViewer extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final int maxPage;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _SlideViewer({
    required this.images,
    required this.currentIndex,
    required this.maxPage,
    required this.pageController,
    required this.onPageChanged,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // 슬라이드 — 좌우 스와이프
        PageView.builder(
          controller: pageController,
          itemCount: images.length,
          onPageChanged: onPageChanged,
          itemBuilder: (_, i) => InteractiveViewer(
            child: Image.network(
              images[i],
              fit: BoxFit.contain,
              width: double.infinity,
              loadingBuilder: (_, child, p) => p == null
                  ? child
                  : const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, _, _) => Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 54,
                  color: cs.onSurface.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
        ),

        // 좌측 화살표 — 첫 페이지 아닐 때만
        if (onPrev != null)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: _OverlayArrow(
              icon: Icons.chevron_left,
              onTap: onPrev!,
              alignment: Alignment.centerLeft,
            ),
          ),

        // 우측 화살표 — 마지막 페이지 아닐 때만
        if (onNext != null)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _OverlayArrow(
              icon: Icons.chevron_right,
              onTap: onNext!,
              alignment: Alignment.centerRight,
            ),
          ),

        // 페이지 인디케이터 — 2장 이상일 때만
        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: _PageIndicator(
                current: currentIndex,
                total: images.length,
              ),
            ),
          ),
      ],
    );
  }
}

/// 이미지 위에 떠 있는 희미한 좌/우 화살표.
class _OverlayArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Alignment alignment;

  const _OverlayArrow({
    required this.icon,
    required this.onTap,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;

    return SizedBox(
      width: 72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            alignment: alignment,
            padding: EdgeInsets.only(
              left: isLeft ? 8 : 0,
              right: isLeft ? 0 : 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
                end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
                colors: [
                  Colors.black.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
              ),
            ),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    color: Colors.black.withValues(alpha: 0.10),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 26,
                color: Colors.black.withValues(alpha: 0.65),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 페이지 인디케이터 — "1 / 5" + 진행 점.
class _PageIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _PageIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${current + 1} / $total',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int year, month, day;
  const _EmptyState({required this.year, required this.month, required this.day});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined,
              size: 54, color: cs.onSurface.withValues(alpha: 0.35)),
          const SizedBox(height: 12),
          Text(
            '$year.$month.${day.toString().padLeft(2, '0')} 주보',
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            '등록된 주보가 없습니다.',
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DropdownBox<T> extends StatelessWidget {
  const _DropdownBox({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        icon: const Icon(Icons.expand_more, size: 18),
        iconEnabledColor: Colors.black54,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
          ),
        ),
        selectedItemBuilder: (context) => items
            .map(
              (v) => Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(1.0)),
                    child: Text(
                      labelBuilder(v),
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
        items: items
            .map(
              (v) => DropdownMenuItem<T>(
                value: v,
                child: Text(labelBuilder(v), overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
