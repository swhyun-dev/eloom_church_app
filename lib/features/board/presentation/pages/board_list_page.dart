import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/board_category.dart';
import '../../domain/models/board_post.dart';
import '../providers/board_providers.dart';

class BoardListPage extends ConsumerWidget {
  final String type; // news | notice
  const BoardListPage({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = BoardCategory.fromRouteType(type);
    final asyncList = ref.watch(boardPostsByCategoryProvider(category));

    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(boardPostsByCategoryProvider(category)),
        child: AsyncValueBuilder<List<BoardPost>>(
          value: asyncList,
          onRetry: () => ref.invalidate(boardPostsByCategoryProvider(category)),
          emptyMessage: '게시글이 없습니다.',
          builder: (raw) {
            final posts = [...raw]..sort((a, b) {
                if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
                return b.createdAt.compareTo(a.createdAt);
              });
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: posts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _PostCard(
                post: posts[i],
                showNoticeMeta: type == 'notice',
                onTap: () => context.push('/boards/$type/${posts[i].id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final BoardPost post;
  final bool showNoticeMeta;
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.showNoticeMeta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date =
        '${post.createdAt.year}/${_two(post.createdAt.month)}/${_two(post.createdAt.day)}';

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
