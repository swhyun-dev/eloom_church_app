import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/board_service.dart';

class FellowBoardPage extends StatefulWidget {
  const FellowBoardPage({super.key});

  @override
  State<FellowBoardPage> createState() => _FellowBoardPageState();
}

class _FellowBoardPageState extends State<FellowBoardPage> {
  late final Future<List<BoardPostData>> _future;

  @override
  void initState() {
    super.initState();
    _future = BoardService().fetchByCategory('MEMBER_NEWS');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('교우동정')),
      body: FutureBuilder<List<BoardPostData>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('오류: ${snap.error}'));
          }
          final items = (snap.data ?? [])
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (items.isEmpty) {
            return const Center(child: Text('등록된 교우동정이 없습니다.'));
          }

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
    );
  }
}

String _fmtDate(DateTime d) =>
    '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
