import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'prayer_models.dart';
import 'widgets/privacy_chip.dart';

class PrayerPage extends StatefulWidget {
  /// initialTab: 0 = 공동 / 1 = 개인
  final int initialTab;
  final bool isLoggedIn;

  const PrayerPage({
    super.key,
    this.initialTab = 0,
    required this.isLoggedIn,
  });

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

enum _PrivacyFilter { all, public, private }
enum _ProgressFilter { all, praying, done }

class _PrayerPageState extends State<PrayerPage> {
  // 더미 데이터 - 공동
  late final List<PrayerItem> _communal = [
    PrayerItem(
      id: 'c1',
      date: DateTime(2026, 1, 23),
      title: '[한우리도] ○○○ 집사 묘지 수술',
      content: '1. ○○○ 집사님의 수술이 잘 진행되도록\n2. 회복과 재활 과정에 은혜가 있도록 기도합니다.',
    ),
    PrayerItem(
      id: 'c2',
      date: DateTime(2026, 1, 2),
      title: '[월간 공동기도제목] 2026년 1월',
      content: '1. 새해 사역과 교회 비전 가운데 주님의 인도하심\n2. 성도들의 건강과 가정의 평안',
    ),
    PrayerItem(
      id: 'c3',
      date: DateTime(2026, 1, 2),
      title: '[2026년도 이룸교회 공동기도제목]',
      content: '1. 교회의 영적 부흥\n2. 다음세대와 선교\n3. 지역과 열방을 위한 기도',
    ),
  ];

  // ✅ 더미 데이터 - 개인(내 리스트)
  // API 연결 후에는 이 리스트를 Provider/Store/Repository에서 가져오면 됩니다.
  final List<MyPrayerItem> _myList = [
    MyPrayerItem(
      id: 'm1',
      date: DateTime(2026, 1, 23),
      title: '나의 깊은 아픔을 만져주세요..',
      content: '마음의 상처가 회복되고 평안이 임하도록 기도합니다.',
      isPublic: false,
    ),
    MyPrayerItem(
      id: 'm2',
      date: DateTime(2026, 1, 17),
      title: '가족의 건강을 위한 기도',
      content: '부모님 건강과 가족의 평안을 위해 기도합니다.',
      isPublic: true,
    ),
    MyPrayerItem(
      id: 'm3',
      date: DateTime(2026, 1, 12),
      title: '자녀 ○○○ 시험 합격을 위한 기도',
      content: '준비 과정 가운데 지혜와 체력이 있도록 기도합니다.',
      isPublic: true,
    ),
    MyPrayerItem(
      id: 'm4',
      date: DateTime(2025, 12, 16),
      title: '○○○을 미워하지 않게 해주세요..',
      content: '용서와 화해의 마음이 생기도록 기도합니다.',
      isPublic: false,
    ),
  ];

  // ✅ 진행상태 더미(카드/필터용)
  final Map<String, _ProgressFilter> _progressById = {
    'm1': _ProgressFilter.praying,
    'm2': _ProgressFilter.praying,
    'm3': _ProgressFilter.done,
    'm4': _ProgressFilter.done,
  };

  _PrivacyFilter _privacyFilter = _PrivacyFilter.all;
  _ProgressFilter _progressFilter = _ProgressFilter.all;

  _ProgressFilter _progressOf(MyPrayerItem item) {
    return _progressById[item.id] ?? _ProgressFilter.praying;
  }

  List<MyPrayerItem> _applyFilters(List<MyPrayerItem> src) {
    return src.where((m) {
      // 공개/비공개
      final okPrivacy = switch (_privacyFilter) {
        _PrivacyFilter.all => true,
        _PrivacyFilter.public => m.isPublic,
        _PrivacyFilter.private => !m.isPublic,
      };

      // 진행상태
      final p = _progressOf(m);
      final okProgress = switch (_progressFilter) {
        _ProgressFilter.all => true,
        _ProgressFilter.praying => p == _ProgressFilter.praying,
        _ProgressFilter.done => p == _ProgressFilter.done,
      };

      return okPrivacy && okProgress;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab.clamp(0, 1),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('기도제목'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: '공동기도제목'),
              Tab(text: '개인기도리스트'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCommunalList(),
            widget.isLoggedIn ? _buildMyPrayerList() : _buildNeedLogin(),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedLogin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '개인 기도제목은 로그인 후 이용 가능합니다.',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              width: 160,
              child: FilledButton(
                onPressed: () => context.push(
                  '/login?from=${Uri.encodeComponent('/prayer?tab=1')}',
                ),
                child: const Text('로그인'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunalList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: _communal.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = _communal[i];
        return _CardListTile(
          dateText: formatYmd(item.date),
          title: item.title,
          onTap: () => context.push('/prayer/detail', extra: item),
        );
      },
    );
  }

  Widget _buildMyPrayerList() {
    final red = Colors.red.shade700;

    final filtered = _applyFilters(_myList);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      children: [
        // ✅ 주의사항(빨간 강조 포함)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '작성 유의 사항',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Text(
                '※ 개인 기도 리스트를 작성하시면 소속된 구역기본방 내의 기도 리스트가 자동 공유됩니다.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: Colors.black.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '※ 구역원에게 공개를 원하지 않으시면 반드시 비공개에 체크하시기 바랍니다.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: red,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '※ 공개된 기도 리스트는 구역과 본인 이외에는 절대 열람이 불가능하오니 참고하시기 바랍니다.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: Colors.black.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ✅ 작성하기
        SizedBox(
          height: 46,
          child: FilledButton(
            onPressed: () async {
              await context.push('/prayer/write');
              if (!mounted) return;
              setState(() {});
            },
            child: const Text('기도 리스트 작성하기'),
          ),
        ),

        const SizedBox(height: 14),

        const Center(
          child: Text(
            '나의 기도 리스트',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),

        const SizedBox(height: 12),

        // ✅ 필터 (공개여부 / 진행상태)
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _FilterGroup(
                  title: '공개여부',
                  children: [
                    _ChoicePill(
                      text: '전체',
                      selected: _privacyFilter == _PrivacyFilter.all,
                      onTap: () => setState(() => _privacyFilter = _PrivacyFilter.all),
                    ),
                    _ChoicePill(
                      text: '공개',
                      selected: _privacyFilter == _PrivacyFilter.public,
                      onTap: () => setState(() => _privacyFilter = _PrivacyFilter.public),
                    ),
                    _ChoicePill(
                      text: '비공개',
                      selected: _privacyFilter == _PrivacyFilter.private,
                      onTap: () => setState(() => _privacyFilter = _PrivacyFilter.private),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.black.withOpacity(0.08),
              ),
              Expanded(
                child: _FilterGroup(
                  title: '기도 진행 상태',
                  children: [
                    _ChoicePill(
                      text: '전체',
                      selected: _progressFilter == _ProgressFilter.all,
                      onTap: () => setState(() => _progressFilter = _ProgressFilter.all),
                    ),
                    _ChoicePill(
                      text: '기도중',
                      selected: _progressFilter == _ProgressFilter.praying,
                      onTap: () => setState(() => _progressFilter = _ProgressFilter.praying),
                    ),
                    _ChoicePill(
                      text: '완료',
                      selected: _progressFilter == _ProgressFilter.done,
                      onTap: () => setState(() => _progressFilter = _ProgressFilter.done),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                '필터 조건에 맞는 기도제목이 없습니다.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          )
        else
          ...filtered.map((m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MyPrayerCard(
                item: m,
                progress: _progressOf(m),
                onTap: () async {
                  await context.push('/prayer/my/${m.id}');
                  if (!mounted) return;
                  setState(() {});
                },
              ),
            );
          }),
      ],
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FilterGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: Colors.black.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: children,
        ),
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

class _MyPrayerCard extends StatelessWidget {
  final MyPrayerItem item;
  final _ProgressFilter progress;
  final VoidCallback onTap;

  const _MyPrayerCard({
    required this.item,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = (progress == _ProgressFilter.done) ? '완료' : '기도중';

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
              blurRadius: 10,
              offset: const Offset(0, 5),
              color: Colors.black.withOpacity(0.04),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 + 공개/비공개 + 진행상태(텍스트로 명확히)
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 14, color: Colors.black.withOpacity(0.45)),
                      const SizedBox(width: 6),
                      Text(
                        formatYmd(item.date),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.black.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                  ),

                  const SizedBox(height: 8),

                  // 보조: 칩(기존 컴포넌트 유지)
                  Row(
                    children: [
                      PrivacyChip(isPublic: item.isPublic),
                      const SizedBox(width: 8),
                      _ProgressChip(progress: progress),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right, color: Colors.black.withOpacity(0.35)),
          ],
        ),
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  final _ProgressFilter progress;
  const _ProgressChip({required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDone = progress == _ProgressFilter.done;
    final bg = isDone ? const Color(0xFFEEF2FF) : const Color(0xFFF3F4F6);
    final fg = isDone ? const Color(0xFF2563EB) : const Color(0xFF374151);
    final text = isDone ? '완료' : '기도중';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}
