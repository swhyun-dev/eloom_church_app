import 'package:flutter/material.dart';
import '../../services/board_service.dart';

class FellowBoardDetailPage extends StatefulWidget {
  final String id;
  const FellowBoardDetailPage({super.key, required this.id});

  @override
  State<FellowBoardDetailPage> createState() => _FellowBoardDetailPageState();
}

class _FellowBoardDetailPageState extends State<FellowBoardDetailPage> {
  late final Future<BoardPostData?> _future;

  @override
  void initState() {
    super.initState();
    final intId = int.tryParse(widget.id) ?? -1;
    _future = BoardService().fetchOne('MEMBER_NEWS', intId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('교우동정')),
      body: FutureBuilder<BoardPostData?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('오류: ${snap.error}'));
          }
          final post = snap.data;
          if (post == null) {
            return const Center(child: Text('게시글을 찾을 수 없습니다.'));
          }

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
}

String _fmtDate(DateTime d) =>
    '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
