import 'package:flutter/material.dart';
import '../../services/board_service.dart';

class BoardDetailPage extends StatefulWidget {
  final String type; // news | notice
  final int id;

  const BoardDetailPage({super.key, required this.type, required this.id});

  String get title => type == 'news' ? '교회소식' : '모임공지';

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  late final Future<BoardPostData?> _future;

  String get _category =>
      widget.type == 'news' ? 'CHURCH_NEWS' : 'MEETING_NOTICE';

  @override
  void initState() {
    super.initState();
    _future = BoardService().fetchOne(_category, widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<BoardPostData?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('오류: ${snap.error}'));
          }
          final post = snap.data;
          if (post == null) {
            return const Center(child: Text('게시글을 찾을 수 없습니다.'));
          }

          final date =
              '${post.createdAt.year}/${post.createdAt.month}/${post.createdAt.day}';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              Text(post.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(date, style: const TextStyle(color: Colors.black45)),
              const SizedBox(height: 14),
              if (widget.type == 'notice' && post.endAt != null) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(text: '마감: ${post.endAt!.month}/${post.endAt!.day}'),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              Text(
                post.content,
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ],
          );
        },
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
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
    );
  }
}
