import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../dummy/dummy_data.dart';
import '../../../models/edu_event.dart';

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
            // 상단: 탭 + 더보기
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

            // 본문: 탭별 3개 미리보기
            if (idx == 0) _NewsPreview(),
            if (idx == 1) _NoticePreview(),
            if (idx == 2) _EduPreview(),
            if (idx == 3) _FellowPreview(),
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
        separatorBuilder: (_, __) => const SizedBox(width: 8),
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

class _NewsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = DummyData.boardPosts.where((p) => p.type == 'news').toList()
      ..sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return b.createdAt.compareTo(a.createdAt);
      });

    final top3 = items.take(3).toList();

    return _PreviewList(
      children: top3.map((p) {
        return _RowItem(
          title: p.title,
          date: _fmtDate(p.createdAt),
          onTap: () => context.push('/boards/news/${p.id}'),
        );
      }).toList(),
    );
  }
}

class _NoticePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = DummyData.boardPosts.where((p) => p.type == 'notice').toList()
      ..sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        if (a.important != b.important) return a.important ? -1 : 1;
        return b.createdAt.compareTo(a.createdAt);
      });

    final top3 = items.take(3).toList();

    return _PreviewList(
      children: top3.map((p) {
        final prefix = p.important ? '[중요] ' : '';
        final dday = _ddayText(p.endAt);
        return _RowItem(
          title: '$prefix${p.title}',
          date: dday ?? _fmtDate(p.createdAt),
          onTap: () => context.push('/boards/notice/${p.id}'),
          isUrgent: dday != null,
        );
      }).toList(),
    );
  }
}

class _EduPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final items = [...DummyData.eduEvents]..sort((a, b) => a.startAt.compareTo(b.startAt));

    final upcoming = items.where((e) => !e.endAt.isBefore(now)).take(3).toList();
    final top3 = upcoming.isNotEmpty ? upcoming : items.take(3).toList();

    return _PreviewList(
      children: top3.map((EduEvent e) {
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

class _FellowPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = <_FellowNewsItem>[
      _FellowNewsItem(
        id: 'f1',
        title: '김OO 성도님 장례 안내',
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: '장례',
      ),
      _FellowNewsItem(
        id: 'f2',
        title: '박OO 성도님 자녀 결혼식 안내',
        date: DateTime.now().subtract(const Duration(days: 3)),
        category: '결혼',
      ),
      _FellowNewsItem(
        id: 'f3',
        title: '이OO 성도님 출산 소식 (축하드립니다)',
        date: DateTime.now().subtract(const Duration(days: 5)),
        category: '출산',
      ),
      _FellowNewsItem(
        id: 'f4',
        title: '정OO 성도님 입원 중입니다. 기도 부탁드립니다.',
        date: DateTime.now().subtract(const Duration(days: 7)),
        category: '중보',
      ),
      _FellowNewsItem(
        id: 'f5',
        title: '새가족 환영: 최OO 성도님(인도: 김OO 집사)',
        date: DateTime.now().subtract(const Duration(days: 9)),
        category: '새가족',
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final top3 = items.take(3).toList();

    return _PreviewList(
      children: top3.map((p) {
        final prefix = '[${p.category}] ';
        return _RowItem(
          title: '$prefix${p.title}',
          date: _fmtDate(p.date),
          onTap: () => context.push('/boards/fellow/${p.id}'),
        );
      }).toList(),
    );
  }
}

class _FellowNewsItem {
  final String id;
  final String title;
  final DateTime date;
  final String category;

  const _FellowNewsItem({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
  });
}
