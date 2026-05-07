import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/notice.dart';
import '../providers/notice_providers.dart';

class NoticeListPage extends ConsumerWidget {
  const NoticeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotices = ref.watch(noticeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(noticeListProvider),
        child: AsyncValueBuilder<List<Notice>>(
          value: asyncNotices,
          onRetry: () => ref.invalidate(noticeListProvider),
          emptyMessage: '등록된 공지가 없습니다.',
          builder: (notices) {
            final sorted = [...notices]..sort((a, b) {
                if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
                return b.createdAt.compareTo(a.createdAt);
              });

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: sorted.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
              itemBuilder: (context, i) => _NoticeRow(notice: sorted[i]),
            );
          },
        ),
      ),
    );
  }
}

class _NoticeRow extends StatelessWidget {
  final Notice notice;

  const _NoticeRow({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (notice.isPinned) ...[
                const Icon(Icons.push_pin, size: 14, color: Color(0xFF1F7AAE)),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  notice.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _fmtDate(notice.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          if (notice.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              notice.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
}
