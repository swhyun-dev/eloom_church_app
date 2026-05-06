import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../domain/memo/memo_repository.dart';
import '../../domain/models/bible_memo.dart';
import '../controllers/bible_reader_controller.dart';

Future<void> showMemoBottomSheet(
    BuildContext context, {
      required BibleReaderController readerController,
    }) async {
  final repo = GetIt.I<MemoRepository>();
  final c = TextEditingController();

  final initialSel = readerController.getSelectionWithColorRange();
  if (initialSel == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('먼저 구절을 선택하세요.')),
    );
    return;
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return AnimatedBuilder(
        animation: readerController,
        builder: (_, _) {
          final sel = readerController.getSelectionWithColorRange();
          if (sel == null) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('선택된 구절이 없습니다.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('닫기'),
                  ),
                ],
              ),
            );
          }

          final color = Color(sel.colorValue);
          final rangeText = (sel.endVerse == null)
              ? '${sel.bookKoName} ${sel.chapter}:${sel.startVerse}'
              : '${sel.bookKoName} ${sel.chapter}:${sel.startVerse}-${sel.endVerse}';

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$rangeText 메모',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black26),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: color.withValues(alpha: 0.20),
                    border: Border.all(color: color.withValues(alpha: 0.55)),
                  ),
                  child: const Text(
                    '현재 형광펜 색상/범위로 저장됩니다.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: c,
                  autofocus: true,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: '메모를 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('취소'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final text = c.text.trim();
                          if (text.isEmpty) return;

                          final now = DateTime.now();

                          final memo = BibleMemo(
                            id: now.microsecondsSinceEpoch.toString(),
                            bookId: sel.bookId,
                            bookKoName: sel.bookKoName,
                            chapter: sel.chapter,

                            // ✅ 기존 호환용(대표 절)
                            verse: sel.startVerse,

                            content: text,
                            createdAt: now,
                            highlightColorValue: sel.colorValue,

                            // ✅ 범위 저장
                            startVerse: sel.startVerse,
                            endVerse: sel.endVerse,
                          );

                          await repo.add(memo);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: const Text('저장'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
