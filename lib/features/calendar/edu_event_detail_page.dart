import 'package:flutter/material.dart';
import '../../models/edu_event.dart';
import '../../services/edu_event_service.dart';

class EduEventDetailPage extends StatefulWidget {
  final int id;
  const EduEventDetailPage({super.key, required this.id});

  @override
  State<EduEventDetailPage> createState() => _EduEventDetailPageState();
}

class _EduEventDetailPageState extends State<EduEventDetailPage> {
  late final Future<EduEvent?> _future;

  @override
  void initState() {
    super.initState();
    _future = EduEventService().fetchById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('교육일정 상세')),
      body: FutureBuilder<EduEvent?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('오류: ${snap.error}'));
          }
          final e = snap.data;
          if (e == null) {
            return const Center(child: Text('일정을 찾을 수 없습니다.'));
          }

          final date =
              '${e.startAt.year}/${e.startAt.month}/${e.startAt.day}  '
              '${e.startAt.hour.toString().padLeft(2, '0')}:${e.startAt.minute.toString().padLeft(2, '0')} ~ '
              '${e.endAt.hour.toString().padLeft(2, '0')}:${e.endAt.minute.toString().padLeft(2, '0')}';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              Text(e.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(date, style: const TextStyle(color: Colors.black54)),
              if (e.location != null) ...[
                const SizedBox(height: 4),
                Text('장소: ${e.location}', style: const TextStyle(color: Colors.black54)),
              ],
              if (e.host != null) ...[
                const SizedBox(height: 4),
                Text('담당: ${e.host}', style: const TextStyle(color: Colors.black54)),
              ],
              const SizedBox(height: 14),
              Text(e.description,
                  style: const TextStyle(fontSize: 15, height: 1.6)),
              if (e.applyUrl != null) ...[
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text('신청 링크: ${e.applyUrl}',
                        style: const TextStyle(color: Colors.black54)),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
