import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SermonBoardPage extends StatelessWidget {
  const SermonBoardPage({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = const <_SermonCollectionItem>[
      _SermonCollectionItem(
        title: '주일예배설교',
        subtitle: 'Sunday Worship',
        url: 'https://www.eloomtv.com/main/sub.html?pageCode=8',
        icon: Icons.church,
      ),
      _SermonCollectionItem(
        title: '부교역자설교',
        subtitle: 'Assistant Pastors',
        url: 'https://www.eloomtv.com/main/sub.html?pageCode=9',
        icon: Icons.record_voice_over,
      ),
      _SermonCollectionItem(
        title: '초청강사설교',
        subtitle: 'Guest Speakers',
        url: 'https://www.eloomtv.com/main/sub.html?pageCode=10',
        icon: Icons.person,
      ),
      _SermonCollectionItem(
        title: '특별집회',
        subtitle: 'Special Meetings',
        url: 'https://www.eloomtv.com/main/sub.html?pageCode=11',
        icon: Icons.event,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('설교 모음')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text(
            '원하시는 설교 모음을 선택하세요.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25, // 카드 비율
            ),
            itemBuilder: (context, i) {
              final it = items[i];
              return _SermonCard(
                title: it.title,
                subtitle: it.subtitle,
                icon: it.icon,
                onTap: () => _openUrl(context, it.url),
              );
            },
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: const Text(
              '설교 영상은 이룸TV 홈페이지로 연결됩니다.',
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class _SermonCollectionItem {
  final String title;
  final String subtitle;
  final String url;
  final IconData icon;

  const _SermonCollectionItem({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.icon,
  });
}

class _SermonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SermonCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 18, color: Colors.blue),
                ),
                const Spacer(),
                const Icon(Icons.open_in_new, size: 18, color: Colors.black45),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12.5, color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            const Text(
              '홈페이지로 이동',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
