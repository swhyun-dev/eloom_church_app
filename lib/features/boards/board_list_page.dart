import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/board_service.dart';

class BoardListPage extends StatefulWidget {
  final String type; // news | notice
  const BoardListPage({super.key, required this.type});

  @override
  State<BoardListPage> createState() => _BoardListPageState();
}

class _BoardListPageState extends State<BoardListPage> {
  late final Future<List<BoardPostData>> _future;

  String get title => widget.type == 'news' ? '교회소식' : '모임공지';

  String get _category =>
      widget.type == 'news' ? 'CHURCH_NEWS' : 'MEETING_NOTICE';

  @override
  void initState() {
    super.initState();
    _future = BoardService().fetchByCategory(_category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<BoardPostData>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('오류: ${snap.error}'));
          }
          final posts = (snap.data ?? [])
            ..sort((a, b) {
              if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
              return b.createdAt.compareTo(a.createdAt);
            });

          if (posts.isEmpty) {
            return const Center(child: Text('게시글이 없습니다.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: posts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final p = posts[i];
              return _PostCard(
                post: p,
                showNoticeMeta: widget.type == 'notice',
                onTap: () => context.push('/boards/${widget.type}/${p.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final BoardPostData post;
  final bool showNoticeMeta;
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.showNoticeMeta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = '${post.createdAt.year}/${_two(post.createdAt.month)}/${_two(post.createdAt.day)}';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                if (post.isPinned)
                  _Badge(text: '고정', bg: Colors.black.withValues(alpha: 0.06), fg: Colors.black87),
                const Spacer(),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.black45)),
              ]),
              const SizedBox(height: 8),
              Text(
                post.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              if (showNoticeMeta && post.endAt != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Mini(text: '마감: ${post.endAt!.month}/${post.endAt!.day}'),
                    const SizedBox(width: 8),
                    if (_ddayLabel(post.endAt!) != null)
                      _Mini(text: _ddayLabel(post.endAt!)!),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Badge({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _Mini extends StatelessWidget {
  final String text;
  const _Mini({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    );
  }
}

String? _ddayLabel(DateTime endAt) {
  final now = DateTime.now();
  final end = DateTime(endAt.year, endAt.month, endAt.day, 23, 59, 59);
  final diff = end.difference(now).inDays;

  if (diff < 0) return '마감';
  if (diff == 0) return 'D-DAY';
  if (diff <= 2) return 'D-$diff';
  return null;
}
