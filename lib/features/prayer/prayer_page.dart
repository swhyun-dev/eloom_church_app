import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'prayer_models.dart';
import 'widgets/privacy_chip.dart';
import '../../services/prayer_service.dart';
import '../../state/auth_provider.dart';

class PrayerPage extends ConsumerStatefulWidget {
  final int initialTab;

  const PrayerPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<PrayerPage> createState() => _PrayerPageState();
}

enum _PrivacyFilter { all, public, private }

class _PrayerPageState extends ConsumerState<PrayerPage> {
  late Future<List<PrayerData>> _communalFuture;
  late Future<List<PrayerData>> _myFuture;

  _PrivacyFilter _privacyFilter = _PrivacyFilter.all;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final token = ref.read(authProvider).token;
    _communalFuture = PrayerService(token: null).fetchCommon();
    _myFuture = PrayerService(token: token).fetchMine();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

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
            auth.isLoggedIn ? _buildMyPrayerList() : _buildNeedLogin(),
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
                color: Colors.black.withValues(alpha: 0.75),
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
    return FutureBuilder<List<PrayerData>>(
      future: _communalFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('오류: ${snap.error}'));
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('공동기도제목이 없습니다.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final d = items[i];
            final item = PrayerItem(
              id: d.id.toString(),
              date: d.createdAt,
              title: d.title,
              content: d.content,
            );
            return _CardListTile(
              dateText: formatYmd(d.createdAt),
              title: d.title,
              onTap: () => context.push('/prayer/detail', extra: item),
            );
          },
        );
      },
    );
  }

  Widget _buildMyPrayerList() {
    final red = Colors.red.shade700;

    return FutureBuilder<List<PrayerData>>(
      future: _myFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('오류: ${snap.error}'));
        }
        final all = snap.data ?? [];

        final filtered = all.where((m) {
          return switch (_privacyFilter) {
            _PrivacyFilter.all => true,
            _PrivacyFilter.public => m.isPublic,
            _PrivacyFilter.private => !m.isPublic,
          };
        }).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
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
                      color: Colors.black.withValues(alpha: 0.75),
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
                      color: Colors.black.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 46,
              child: FilledButton(
                onPressed: () async {
                  await context.push('/prayer/write');
                  if (!mounted) return;
                  setState(_loadData);
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

            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ChoicePill(
                    text: '전체',
                    selected: _privacyFilter == _PrivacyFilter.all,
                    onTap: () => setState(() => _privacyFilter = _PrivacyFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _ChoicePill(
                    text: '공개',
                    selected: _privacyFilter == _PrivacyFilter.public,
                    onTap: () => setState(() => _privacyFilter = _PrivacyFilter.public),
                  ),
                  const SizedBox(width: 8),
                  _ChoicePill(
                    text: '비공개',
                    selected: _privacyFilter == _PrivacyFilter.private,
                    onTap: () => setState(() => _privacyFilter = _PrivacyFilter.private),
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
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              ...filtered.map((d) {
                final myItem = MyPrayerItem(
                  id: d.id.toString(),
                  date: d.createdAt,
                  title: d.title,
                  content: d.content,
                  isPublic: d.isPublic,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MyPrayerCard(
                    item: myItem,
                    onTap: () async {
                      await context.push('/prayer/my/${d.id}');
                      if (!mounted) return;
                      setState(_loadData);
                    },
                  ),
                );
              }),
          ],
        );
      },
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
          color: selected ? Colors.white : Colors.black.withValues(alpha: 0.75),
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF0B4AA2),
      backgroundColor: const Color(0xFFF3F4F6),
      side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
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
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black.withValues(alpha: 0.45)),
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
                      color: Colors.black.withValues(alpha: 0.55),
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
            Icon(Icons.chevron_right, color: Colors.black.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}

class _MyPrayerCard extends StatelessWidget {
  final MyPrayerItem item;
  final VoidCallback onTap;

  const _MyPrayerCard({required this.item, required this.onTap});

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
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 5),
              color: Colors.black.withValues(alpha: 0.04),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 14, color: Colors.black.withValues(alpha: 0.45)),
                      const SizedBox(width: 6),
                      Text(
                        formatYmd(item.date),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.black.withValues(alpha: 0.55),
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
                  PrivacyChip(isPublic: item.isPublic),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right, color: Colors.black.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}
