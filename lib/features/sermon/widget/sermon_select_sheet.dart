import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/links.dart';

class SermonSelectSheet extends StatelessWidget {
  const SermonSelectSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '설교',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),

            // ✅ 유튜브 실시간 생방송 → 즉시 외부 링크
            _Item(
              icon: Icons.live_tv,
              title: '유튜브 실시간 생방송',
              subtitle: '주일예배 Live',
              onTap: () async {
                Navigator.pop(context);

                final uri = Uri.parse(AppLinks.sermonLiveUrl);
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            const SizedBox(height: 10),

            // 설교 모음은 내부 페이지 유지
            _Item(
              icon: Icons.menu_book_outlined,
              title: '설교 모음',
              subtitle: '주일예배 · 부교역자 · 초청설교',
              onTap: () {
                Navigator.pop(context);
                context.push('/sermon/board');
                //Navigator.of(context).pushNamed('/sermon/board');
                // 또는 context.push('/sermon/board') 사용 중이면 그걸로 유지
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
