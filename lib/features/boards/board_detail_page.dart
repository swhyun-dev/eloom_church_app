import 'package:flutter/material.dart';
import '../../dummy/dummy_data.dart';

class BoardDetailPage extends StatelessWidget {
  final String type; // news | notice
  final int id;

  const BoardDetailPage({super.key, required this.type, required this.id});

  String get title => type == 'news' ? '교회소식' : '모임공지';

  @override
  Widget build(BuildContext context) {
    final post = DummyData.boardPosts.firstWhere((p) => p.type == type && p.id == id);

    final date = '${post.createdAt.year}/${post.createdAt.month}/${post.createdAt.day}';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          Text(post.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(date, style: const TextStyle(color: Colors.black45)),
          const SizedBox(height: 14),
          if (type == 'notice') ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(text: '대상: ${post.target}'),
                if (post.endAt != null) _Chip(text: '마감: ${post.endAt!.month}/${post.endAt!.day}'),
                if (post.important) const _Chip(text: '중요 공지'),
              ],
            ),
            const SizedBox(height: 14),
          ],
          Text(
            post.content,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                '※ 지금은 더미 상세입니다.\n나중에 관리자에서 이미지/첨부/PDF 등도 같이 붙일 수 있어요.',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
    );
  }
}
