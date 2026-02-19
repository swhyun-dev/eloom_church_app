import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../state/auth_provider.dart';
import '../../sermon/widget/sermon_select_sheet.dart';
import '../../../config/links.dart';

class HomeEndDrawerV1Simple extends ConsumerWidget {
  const HomeEndDrawerV1Simple({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '이룸교회',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    auth.isLoggedIn ? '${auth.name} 성도님 환영합니다' : '로그인 후 이용 가능합니다',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Divider(),

            _Item(
              icon: Icons.mic,
              title: '설교',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => const SermonSelectSheet(),
                );
              },
            ),
            _Item(
              icon: Icons.article_outlined,
              title: '교회주보',
              onTap: () => context.go('/bulletin'),
            ),
            _Item(
              icon: Icons.menu_book_outlined,
              title: '성경읽기',
              onTap: () => context.go('/bible'),
            ),
            _Item(
              icon: Icons.volunteer_activism_outlined,
              title: '기도제목',
              onTap: () => context.go('/boards/prayer'),
            ),

            _Item(
              icon: Icons.payments_outlined,
              title: '온라인헌금',
              onTap: () => context.push('/offering'),
            ),

            const Divider(),

            _Item(
              icon: Icons.local_cafe_outlined,
              title: '교회카페',
              requireLogin: true,
              onTap: () => context.go('/cafe'),
            ),
            _Item(
              icon: Icons.groups_outlined,
              title: '구역모임',
              requireLogin: true,
              onTap: () => context.go('/cell'),
            ),

            _Item(
              icon: Icons.language_outlined,
              title: '홈페이지',
              onTap: () async {
                final uri = Uri.parse(AppLinks.homepage);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
            _Item(
              icon: Icons.settings_outlined,
              title: '설정',
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends ConsumerWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool requireLogin;

  const _Item({
    required this.icon,
    required this.title,
    required this.onTap,
    this.requireLogin = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      onTap: () {
        Navigator.pop(context);

        if (requireLogin && !auth.isLoggedIn) {
          final loc = GoRouterState.of(context).uri.toString();
          final encoded = Uri.encodeComponent(loc);
          context.push('/login?from=$encoded');
          return;
        }
        onTap();
      },
    );
  }
}
