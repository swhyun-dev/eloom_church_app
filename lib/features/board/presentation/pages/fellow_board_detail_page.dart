import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/board_category.dart';
import '../../domain/models/board_post.dart';
import '../providers/board_providers.dart';

class FellowBoardDetailPage extends ConsumerWidget {
  final String id;
  const FellowBoardDetailPage({super.key, required this.id});

  static const _category = BoardCategory.memberNews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intId = int.tryParse(id) ?? -1;
    final async = ref.watch(boardPostByIdProvider((category: _category, id: intId)));

    return Scaffold(
      appBar: AppBar(title: const Text('교우동정')),
      body: AsyncValueBuilder<BoardPost?>(
        value: async,
        onRetry: () => ref.invalidate(boardPostsByCategoryProvider(_category)),
        isEmpty: (p) => p == null,
        emptyMessage: '게시글을 찾을 수 없습니다.',
        builder: (p) {
          final post = p!;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fmtDate(post.createdAt),
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Text(
                  post.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      post.content,
                      style: const TextStyle(fontSize: 14.5, height: 1.6),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
}
