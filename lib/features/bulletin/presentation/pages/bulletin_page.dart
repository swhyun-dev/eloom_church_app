import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/bulletin.dart';
import '../providers/bulletin_providers.dart';

/// 날짜(년/월/주일) 선택형 주보 뷰어.
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

  List<int> get years => List.generate(10, (i) => 2020 + i);
  List<int> get months => List.generate(12, (i) => i + 1);
  List<int> get sundayDays => _getSundays(year, month);

  @override
  void initState() {
    super.initState();
    _ensureValidDay();
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

  void _setYear(int v) => setState(() {
        year = v;
        _ensureValidDay();
        pageIndex = 0;
      });

  void _setMonth(int v) => setState(() {
        month = v;
        _ensureValidDay();
        pageIndex = 0;
      });

  void _setDay(int v) => setState(() {
        day = v;
        pageIndex = 0;
      });

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
        // 빈 목록도 그대로 화면 유지 (날짜 선택 UI는 보여줘야 함)
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DropdownBox<int>(
                          value: year,
                          items: years,
                          labelBuilder: (v) => '$v년',
                          onChanged: _setYear,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DropdownBox<int>(
                          value: month,
                          items: months,
                          labelBuilder: (v) => '$v월',
                          onChanged: _setMonth,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          : InteractiveViewer(
                              child: Image.network(
                                images[idx],
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleNavButton(
                        icon: Icons.chevron_left,
                        filled: false,
                        onTap: idx > 0 ? () => setState(() => pageIndex = idx - 1) : null,
                      ),
                      if (images.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Text(
                          '${idx + 1} / ${images.length}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                      const SizedBox(width: 16),
                      _CircleNavButton(
                        icon: Icons.chevron_right,
                        filled: true,
                        onTap: images.isNotEmpty && idx < maxPage
                            ? () => setState(() => pageIndex = idx + 1)
                            : null,
                      ),
                    ],
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
          Icon(Icons.description_outlined, size: 54, color: cs.onSurface.withValues(alpha: 0.35)),
          const SizedBox(height: 12),
          Text(
            '$year.$month.${day.toString().padLeft(2, '0')} 주보',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            '등록된 주보가 없습니다.',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13),
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
      height: 40,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        icon: const Icon(Icons.expand_more),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
          ),
        ),
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

class _CircleNavButton extends StatelessWidget {
  const _CircleNavButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    final bg = filled ? cs.primary : cs.surface;
    final fg = filled ? cs.onPrimary : cs.onSurface;
    final border = filled ? Colors.transparent : Colors.black.withValues(alpha: 0.12);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border),
          ),
          child: Icon(icon, color: fg, size: 26),
        ),
      ),
    );
  }
}
