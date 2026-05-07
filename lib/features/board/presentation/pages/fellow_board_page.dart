import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/board_category.dart';
import '../../domain/models/board_post.dart';
import '../providers/board_providers.dart';

class FellowBoardPage extends ConsumerWidget {
  const FellowBoardPage({super.key});

  static const _category = BoardCategory.memberNews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(boardPostsByCategoryProvider(_category));

    return Scaffold(
      appBar: AppBar(title: const Text('교우동정')),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(boardPostsByCategoryProvider(_category)),
        child: AsyncValueBuilder<List<BoardPost>>(
          value: asyncList,
          onRetry: () => ref.invalidate(boardPostsByCategoryProvider(_category)),
          emptyMessage: '등록된 교우동정이 없습니다.',
          builder: (raw) {
            final items = [...raw]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = items[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.push('/boards/fellow/${p.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x11000000)),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _fmtDate(p.createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
}
