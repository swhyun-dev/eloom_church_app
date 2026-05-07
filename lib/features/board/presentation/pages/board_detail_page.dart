import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/board_category.dart';
import '../../domain/models/board_post.dart';
import '../providers/board_providers.dart';

class BoardDetailPage extends ConsumerWidget {
  final String type; // news | notice
  final int id;

  const BoardDetailPage({super.key, required this.type, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = BoardCategory.fromRouteType(type);
    final async = ref.watch(boardPostByIdProvider((category: category, id: id)));

    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: AsyncValueBuilder<BoardPost?>(
        value: async,
        onRetry: () => ref.invalidate(boardPostsByCategoryProvider(category)),
        isEmpty: (p) => p == null,
        emptyMessage: '게시글을 찾을 수 없습니다.',
        builder: (p) {
          final post = p!;
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
              if (type == 'notice' && post.endAt != null) ...[
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
