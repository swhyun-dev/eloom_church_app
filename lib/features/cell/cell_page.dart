import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../dummy/dummy_data.dart';

class CellPage extends StatelessWidget {
  /// 0 = 나의 구역 정보 / 1 = 구역 게시판
  final int initialTab;
  const CellPage({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab.clamp(0, 1),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('구역모임'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: '나의 구역 정보'),
              Tab(text: '구역 게시판'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MyCellInfoTab(),
            _CellBoardTab(),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// 탭1: 나의 구역 정보
/// ===============================
class _MyCellInfoTab extends StatelessWidget {
  const _MyCellInfoTab();

  @override
  Widget build(BuildContext context) {
    if (!DummyData.isAssigned) {
      return const _UnassignedCenter();
    }

    final me = DummyData.me!;
    final leader = DummyData.cellLeader;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      children: [
        // ✅ PrayerPage 톤의 카드
        _InfoCard(
          title: '나의 구역 정보',
          lines: [
            _InfoLine(label: '이름', value: '${me.name}(${me.position})'),
            _InfoLine(label: '교구', value: me.parish),
            _InfoLine(label: '구역', value: me.district),
            _InfoLine(label: '구역장', value: leader == null ? '-' : '${leader.name}(${leader.position})'),
          ],
        ),
      ],
    );
  }
}

/// ===============================
/// 탭2: 구역 게시판
/// ===============================
class _CellBoardTab extends StatelessWidget {
  const _CellBoardTab();

  @override
  Widget build(BuildContext context) {
    if (!DummyData.isAssigned) return const _UnassignedCenter();

    final key = DummyData.cellKey!;
    final notices = (DummyData.cellNoticesByCellKey[key] ?? []).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      children: [
        // ✅ 구역 공지
        _SectionHeader(
          title: '구역 공지',
          trailing: TextButton(
            onPressed: () => context.push('/cell/notices'),
            child: const Text('더보기'),
          ),
        ),
        const SizedBox(height: 8),

        if (notices.isEmpty)
          _EmptyHint('등록된 공지가 없습니다.')
        else
          ...notices.take(3).map((n) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CardListTile(
                dateText: _fmtYmd(n.date),
                title: n.title,
                onTap: () => context.push('/cell/notices/${n.id}'),
              ),
            );
          }),

        const SizedBox(height: 12),

        // ✅ 구역원 기도 제목 진입
        _SectionHeader(title: '구역원 기도 제목'),
        const SizedBox(height: 8),
        _CardNavTile(
          title: '구역원 기도 제목 보기',
          onTap: () => context.push('/cell/prayers'),
        ),
      ],
    );
  }
}

/// ===============================
/// /cell/notices (공지 리스트)
/// ===============================
class CellNoticeListPage extends StatelessWidget {
  const CellNoticeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!DummyData.isAssigned) {
      return Scaffold(
        appBar: AppBar(title: const Text('구역공지'), centerTitle: true),
        body: const _UnassignedCenter(),
      );
    }

    final key = DummyData.cellKey!;
    final isLeader = DummyData.isLeader;

    final notices = (DummyData.cellNoticesByCellKey[key] ?? []).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('구역공지'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
              itemCount: notices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final n = notices[i];
                return _AccordionCard(
                  dateText: _fmtYmd(n.date),
                  title: n.title,
                  content: n.content,
                  onDetailTap: () => context.push('/cell/notices/${n.id}'),
                );
              },
            ),
          ),
          if (isLeader)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                height: 46,
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.push('/cell/notices/write'),
                  child: const Text('글쓰기'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ===============================
/// /cell/notices/:id (공지 상세)
/// ===============================
class CellNoticeDetailPage extends StatelessWidget {
  final String noticeId;
  const CellNoticeDetailPage({super.key, required this.noticeId});

  @override
  Widget build(BuildContext context) {
    if (!DummyData.isAssigned) {
      return Scaffold(
        appBar: AppBar(title: const Text('구역공지'), centerTitle: true),
        body: const _UnassignedCenter(),
      );
    }

    final key = DummyData.cellKey!;
    final notices = DummyData.cellNoticesByCellKey[key] ?? [];
    final n = notices.firstWhere((e) => e.id == noticeId);

    final isLeader = DummyData.isLeader;

    return Scaffold(
      appBar: AppBar(title: const Text('구역공지'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
        children: [
          _DetailCard(
            dateText: _fmtYmd(n.date),
            title: n.title,
            content: n.content,
          ),
          if (isLeader) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('삭제는 API 연결 후 동작하도록 연결해주세요.')),
                  );
                },
                child: const Text('삭제하기'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ===============================
/// /cell/notices/write (구역장만)
/// ===============================
class CellNoticeWritePage extends StatefulWidget {
  const CellNoticeWritePage({super.key});

  @override
  State<CellNoticeWritePage> createState() => _CellNoticeWritePageState();
}

class _CellNoticeWritePageState extends State<CellNoticeWritePage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLeader = DummyData.isLeader;

    return Scaffold(
      appBar: AppBar(title: const Text('구역공지 작성'), centerTitle: true),
      body: !isLeader
          ? Center(
        child: Text(
          '구역장만 작성할 수 있습니다.',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black.withOpacity(0.6)),
        ),
      )
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
        children: [
          const Text('공지제목*', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          TextField(controller: _titleCtrl, decoration: _inputDeco()),
          const SizedBox(height: 16),
          const Text('공지내용*', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          TextField(controller: _contentCtrl, maxLines: 7, decoration: _inputDeco()),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('작성완료는 API 연결 후 동작하도록 연결해주세요.')),
                );
                context.pop();
              },
              child: const Text('작성완료'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('취소'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0B4AA2), width: 1.4),
      ),
    );
  }
}

/// ===============================
/// /cell/prayers (구역원 기도 제목)
/// - 규칙: isPublic && 같은 구역만 (더미는 같은 구역만 들어있음)
/// ===============================
class CellPrayerTitlesPage extends StatefulWidget {
  const CellPrayerTitlesPage({super.key});

  @override
  State<CellPrayerTitlesPage> createState() => _CellPrayerTitlesPageState();
}

class _CellPrayerTitlesPageState extends State<CellPrayerTitlesPage> {
  String? selectedName;

  @override
  Widget build(BuildContext context) {
    if (!DummyData.isAssigned) {
      return Scaffold(
        appBar: AppBar(title: const Text('구역원 기도 제목'), centerTitle: true),
        body: const _UnassignedCenter(),
      );
    }

    final key = DummyData.cellKey!;
    final all = (DummyData.cellPrayersByCellKey[key] ?? []).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // ✅ 공개만 노출
    final visible = all.where((p) => p.isPublic).toList();

    final names = <String>{};
    for (final p in visible) {
      names.add(p.userName);
    }
    final nameList = names.toList();

    if (selectedName == null && nameList.isNotEmpty) {
      selectedName = nameList.first;
    }

    final filtered = selectedName == null
        ? <CellPrayerDummy>[]
        : visible.where((p) => p.userName == selectedName).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('구역원 기도 제목'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: nameList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final name = nameList[i];
                final selected = name == selectedName;
                return _ChoicePill(
                  text: name,
                  selected: selected,
                  onTap: () => setState(() => selectedName = name),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyCenter('공개된 기도제목이 없습니다.')
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = filtered[i];
                return _AccordionCard(
                  dateText: _fmtYmd(p.date),
                  title: p.title,
                  content: p.content,
                  onDetailTap: null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// PrayerPage 톤으로 통일된 위젯들
/// ===============================
class _CardListTile extends StatelessWidget {
  const _CardListTile({
    required this.dateText,
    required this.title,
    required this.onTap,
  });

  final String dateText;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black.withOpacity(0.45)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black.withOpacity(0.35)),
          ],
        ),
      ),
    );
  }
}

class _CardNavTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _CardNavTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black.withOpacity(0.35)),
          ],
        ),
      ),
    );
  }
}

class _AccordionCard extends StatelessWidget {
  final String dateText;
  final String title;
  final String content;
  final VoidCallback? onDetailTap;

  const _AccordionCard({
    required this.dateText,
    required this.title,
    required this.content,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          trailing: Icon(Icons.keyboard_arrow_down, color: Colors.black.withOpacity(0.35)),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Colors.black.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onDetailTap != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onDetailTap,
                  child: const Text('상세보기', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoLine> lines;

  const _InfoCard({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 12),
          ...lines.expand((l) sync* {
            yield _InfoRow(label: l.label, value: l.value);
            yield const SizedBox(height: 10);
          }).toList()
            ..removeLast(),
        ],
      ),
    );
  }
}

class _InfoLine {
  final String label;
  final String value;
  const _InfoLine({required this.label, required this.value});
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 66,
          child: Text(
            '· $label',
            style: const TextStyle(
              color: Color(0xFF0B4AA2),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black.withOpacity(0.78),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ChoicePill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ChoicePill({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: selected ? Colors.white : Colors.black.withOpacity(0.75),
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF0B4AA2),
      backgroundColor: const Color(0xFFF3F4F6),
      side: BorderSide(color: Colors.black.withOpacity(0.06)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      showCheckmark: false,
    );
  }
}

class _UnassignedCenter extends StatelessWidget {
  const _UnassignedCenter();

  @override
  Widget build(BuildContext context) {
    return const _EmptyCenter(
      '구역이 배정되지 않았습니다.\n(배정문의는 교회 행정실로 문의 바랍니다)',
    );
  }
}

class _EmptyCenter extends StatelessWidget {
  final String text;
  const _EmptyCenter(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black.withOpacity(0.45),
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black.withOpacity(0.6)),
      ),
    );
  }
}

String _fmtYmd(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y/$m/$day';
}

class _DetailCard extends StatelessWidget {
  final String dateText;
  final String title;
  final String content;

  const _DetailCard({
    required this.dateText,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black.withOpacity(0.45)),
              const SizedBox(width: 6),
              Text(
                dateText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Colors.black.withOpacity(0.78),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
