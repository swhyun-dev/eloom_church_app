import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/edu_event.dart';
import '../../../services/edu_event_service.dart';
import '../../board/domain/models/board_category.dart';
import '../../board/presentation/providers/board_providers.dart';

class HomeNoticeBox extends StatefulWidget {
  const HomeNoticeBox({super.key});

  @override
  State<HomeNoticeBox> createState() => _HomeNoticeBoxState();
}

class _HomeNoticeBoxState extends State<HomeNoticeBox> {
  int idx = 0;
  final tabs = const ['교회소식', '모임공지', '교육일정', '교우동정'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF2)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _Tabs(
                    tabs: tabs,
                    index: idx,
                    onChange: (i) => setState(() => idx = i),
                  ),
                ),
                const SizedBox(width: 6),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    if (idx == 0) context.push('/boards/news');
                    if (idx == 1) context.push('/boards/notice');
                    if (idx == 2) context.push('/calendar/edu');
                    if (idx == 3) context.push('/boards/fellow');
                  },
                  child: const Text(
                    '더보기',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F7AAE),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (idx == 0) const _BoardPreview(category: BoardCategory.churchNews, type: 'news'),
            if (idx == 1) const _BoardPreview(category: BoardCategory.meetingNotice, type: 'notice'),
            if (idx == 2) _EduPreview(),
            if (idx == 3) const _BoardPreview(category: BoardCategory.memberNews, type: 'fellow'),
          ],
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final List<String> tabs;
  final int index;
  final ValueChanged<int> onChange;

  const _Tabs({required this.tabs, required this.index, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = i == index;
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChange(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFEAF5FA) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  fontSize: 12.2,
                  fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                  color: active ? const Color(0xFF1F7AAE) : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BoardPreview extends ConsumerWidget {
  final BoardCategory category;
  final String type; // news | notice | fellow (라우트 호환)

  const _BoardPreview({required this.category, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(boardPostsByCategoryProvider(category));

    return asyncList.when(
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, _) => _PreviewList(children: const []),
      data: (raw) {
        final items = [...raw]..sort((a, b) {
            if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
            return b.createdAt.compareTo(a.createdAt);
          });
        final top3 = items.take(3).toList();
        if (top3.isEmpty) return _PreviewList(children: const []);

        return _PreviewList(
          children: top3.map((p) {
            final dday = type == 'notice' ? _ddayText(p.endAt) : null;
            return _RowItem(
              title: p.title,
              date: dday ?? _fmtDate(p.createdAt),
              isUrgent: dday != null,
              onTap: () {
                if (type == 'fellow') {
                  context.push('/boards/fellow/${p.id}');
                } else {
                  context.push('/boards/$type/${p.id}');
                }
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _EduPreview extends StatefulWidget {
  @override
  State<_EduPreview> createState() => _EduPreviewState();
}

class _EduPreviewState extends State<_EduPreview> {
  late final Future<List<EduEvent>> _future;

  @override
  void initState() {
    super.initState();
    _future = EduEventService().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EduEvent>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }

        final now = DateTime.now();
        final items = [...(snap.data ?? <EduEvent>[])]..sort((a, b) => a.startAt.compareTo(b.startAt));
        final upcoming = items.where((e) => !e.endAt.isBefore(now)).take(3).toList();
        final top3 = upcoming.isNotEmpty ? upcoming : items.take(3).toList();

        return _PreviewList(
          children: top3.map<Widget>((EduEvent e) {
            final badge = _eduBadge(e.startAt);
            final dateText = badge != null ? '$badge / ${_fmtDateTime(e.startAt)}' : _fmtDateTime(e.startAt);
            return _RowItem(
              title: e.title,
              date: dateText,
              onTap: () => context.push('/calendar/edu/${e.id}'),
              isUrgent: badge != null,
            );
          }).toList(),
        );
      },
    );
  }
}

class _PreviewList extends StatelessWidget {
  final List<Widget> children;
  const _PreviewList({required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text('표시할 내용이 없습니다.', style: TextStyle(color: Colors.black45, fontSize: 13)),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1)
            const Divider(height: 14, thickness: 1, color: Color(0xFFF0F3F7)),
        ],
      ],
    );
  }
}

class _RowItem extends StatelessWidget {
  final String title;
  final String date;
  final VoidCallback onTap;
  final bool isUrgent;

  const _RowItem({
    required this.title,
    required this.date,
    required this.onTap,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 6, color: Color(0xFF1F7AAE)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13.3, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isUrgent ? const Color(0xFF1F7AAE) : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDate(DateTime d) =>
    '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

String _fmtDateTime(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String? _ddayText(DateTime? endAt) {
  if (endAt == null) return null;
  final now = DateTime.now();
  final end = DateTime(endAt.year, endAt.month, endAt.day, 23, 59, 59);

  final diff = end.difference(now).inDays;
  if (diff < 0) return '마감';
  if (diff == 0) return 'D-DAY';
  if (diff <= 2) return 'D-$diff';
  return null;
}

String? _eduBadge(DateTime startAt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final s = DateTime(startAt.year, startAt.month, startAt.day);

  final diff = s.difference(today).inDays;
  if (diff == 0) return '오늘';
  if (diff > 0 && diff <= 6) return '이번주';
  return null;
}
