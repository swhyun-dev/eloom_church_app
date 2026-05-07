import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/async_value_builder.dart';
import '../board/domain/models/board_category.dart';
import '../board/domain/models/board_post.dart';
import '../board/presentation/providers/board_providers.dart';

class EduEventDetailPage extends ConsumerWidget {
  final int id;
  const EduEventDetailPage({super.key, required this.id});

  static const _category = BoardCategory.eduNotice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(boardPostByIdProvider((category: _category, id: id)));

    return Scaffold(
      appBar: AppBar(title: const Text('교육일정 상세')),
      body: AsyncValueBuilder<BoardPost?>(
        value: async,
        onRetry: () => ref.invalidate(boardPostsByCategoryProvider(_category)),
        isEmpty: (e) => e == null,
        emptyMessage: '일정을 찾을 수 없습니다.',
        builder: (e) {
          final event = e!;
          final start = event.startAt;
          final end = event.endAt;
          final dateLine = (start != null && end != null)
              ? '${start.year}/${start.month}/${start.day}  '
                  '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} ~ '
                  '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}'
              : '${event.createdAt.year}/${event.createdAt.month}/${event.createdAt.day}';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              Text(event.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(dateLine, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 14),
              Text(event.content,
                  style: const TextStyle(fontSize: 15, height: 1.6)),
            ],
          );
        },
      ),
    );
  }
}
