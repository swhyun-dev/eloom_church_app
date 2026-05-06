import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_provider.dart';

import 'widgets/home_notice_box.dart';
import 'widgets/home_menu_grid.dart';
import 'widgets/home_banner_carousel.dart';
import 'widgets/home_end_drawer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      endDrawer: const HomeEndDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: false,
              snap: false,
              toolbarHeight: 72,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleSpacing: 16,
              title: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.go('/'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              actions: [
                Center(
                  child: IconButton(
                    iconSize: 26,
                    tooltip: 'My',
                    onPressed: () =>
                        context.push(auth.isLoggedIn ? '/my' : '/login'),
                    icon: const Icon(Icons.person_outline),
                  ),
                ),
                Center(
                  child: IconButton(
                    iconSize: 26,
                    tooltip: '알림',
                    onPressed: () {
                      context.push('/notifications');
                    },
                    icon: const Icon(Icons.notifications_none),
                  ),
                ),
                Builder(
                  builder: (ctx) => Center(
                    child: IconButton(
                      iconSize: 28,
                      tooltip: '메뉴',
                      onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                      icon: const Icon(Icons.menu),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              sliver: SliverList(
                // ✅ const 제거 (하단 위젯 추가 때문에)
                delegate: SliverChildListDelegate(
                  [
                    const HomeNoticeBox(),
                    const SizedBox(height: 14),
                    const HomeBannerCarousel(),
                    const SizedBox(height: 14),
                    const HomeMenuGrid(),

                    // ✅ 하단 정보 영역 추가
                    const SizedBox(height: 18),
                    const _HomeFooterInfo(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ 홈 하단: 로고 + 교회 정보(주소/전화/팩스)
class _HomeFooterInfo extends StatelessWidget {
  const _HomeFooterInfo();

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.black.withValues(alpha: 0.65);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ 로고(하단용)
          Image.asset(
            'assets/images/footer_logo.png', // 🔸 로고 파일명은 원하시는대로 변경 가능
            height: 22,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),

          _InfoRow(
            label: '주소',
            value: '강원특별자치도 원주시 지정면 도원로 138', // 🔸 실제 주소로 바꿔주세요
            color: textColor,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: '전화',
            value: '033-746-0690', // 🔸 실제 번호로 바꿔주세요
            color: textColor,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: '팩스',
            value: '033-733-2272', // 🔸 실제 번호로 바꿔주세요
            color: textColor,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
