import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../domain/memo/memo_repository.dart';
import '../../domain/models/bible_memo.dart';
import '../controllers/bible_reader_controller.dart';

class BibleNoteTab extends StatefulWidget {
  final BibleReaderController readerController;
  final TabController tabController;

  const BibleNoteTab({
    super.key,
    required this.readerController,
    required this.tabController,
  });

  @override
  State<BibleNoteTab> createState() => _BibleNoteTabState();
}

class _BibleNoteTabState extends State<BibleNoteTab> {
  final repo = GetIt.I<MemoRepository>();
  late Future<List<BibleMemo>> _future;

  @override
  void initState() {
    super.initState();
    _future = repo.getAll();
  }

  Future<void> _reload() async {
    setState(() {
      _future = repo.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BibleMemo>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final memos = snap.data!;
        if (memos.isEmpty) {
          return const Center(child: Text('저장된 메모가 없습니다.'));
        }

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: memos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = memos[i];
              final range = (m.endVerse == null) ? '${m.chapter}:${m.startVerse}' : '${m.chapter}:${m.startVerse}-${m.endVerse}';
              return ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(m.highlightColorValue),
                    shape: BoxShape.circle,
                  ),
                ),
                //title: Text('${m.bookKoName} ${m.chapter}:${m.verse}'),
                title: Text('${m.bookKoName} $range'),
                subtitle: Text(
                  m.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${m.createdAt.year}.${m.createdAt.month.toString().padLeft(2, '0')}.${m.createdAt.day.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () async {
                  widget.tabController.animateTo(0);

                  // ✅ 탭 전환/렌더링 한 프레임 뒤에 점프 실행
                  await Future.delayed(const Duration(milliseconds: 60));

                  widget.readerController.jumpToMemoRange(
                    bookId: m.bookId,
                    bookKoName: m.bookKoName,
                    chapter: m.chapter,
                    startVerse: m.startVerse,
                    endVerse: m.endVerse,
                    colorValue: m.highlightColorValue,
                  );
                },
                onLongPress: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('메모 삭제'),
                      content: const Text('이 메모를 삭제할까요?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await repo.delete(m.id);
                    _reload();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
