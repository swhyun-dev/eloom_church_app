import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../sermon/widget/sermon_select_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/links.dart';

class HomeMenuGrid extends ConsumerWidget {
  const HomeMenuGrid({super.key});

  static const _homepageKey = '__external_homepage__';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    final items = const [
      _MenuItem('설교', Icons.record_voice_over_outlined, 'Sermon', '/sermon'),
      _MenuItem('교회주보', Icons.article_outlined, 'Bulletin', '/bulletin'),
      _MenuItem('성경읽기', Icons.menu_book_outlined, 'Holy Bible', '/bible'),
      _MenuItem('기도제목', Icons.volunteer_activism_outlined, 'Prayer', '/prayer?tab=0'),
      _MenuItem('온라인헌금', Icons.favorite_border, 'Offering', '/offering'), // ✅ 추가
      _MenuItem('교회카페', Icons.local_cafe_outlined, 'Cafeteria', '/cafe'),
      _MenuItem('구역모임', Icons.groups_outlined, 'Cell Group', '/cell'),
      _MenuItem('사역신청', Icons.assignment_outlined, 'Ministry', '/ministry'),
      _MenuItem('홈페이지', Icons.language_outlined, 'Homepage', _homepageKey),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, i) {
        final it = items[i];

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            // 1) 설교: 선택 시트
            if (it.route == '/sermon') {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const SermonSelectSheet(),
              );
              return;
            }

            // 2) 홈페이지: 즉시 외부 링크
            if (it.route == _homepageKey) {
              final uri = Uri.parse(AppLinks.homepage);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return;
            }

            // 3) 로그인 필요 메뉴
            final needLogin =
                it.route == '/cafe' ||
                    it.route == '/cell' ||
                    it.route == '/ministry' ||
                    it.route.startsWith('/prayer?tab=1');

            if (needLogin && !auth.isLoggedIn) {
              final from = Uri.encodeComponent(it.route); // ✅ 원래 가려던 경로를 그대로 from으로
              context.push('/login?from=$from');
              return;
            }

            // 4) 내부 라우트 이동
            context.push(it.route);
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    it.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    it.sub,
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(it.icon, size: 28, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final String sub;
  final String route;
  const _MenuItem(this.title, this.icon, this.sub, this.route);
}
