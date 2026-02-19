import 'package:flutter/material.dart';
import '../../dummy/dummy_data.dart';

class EduEventDetailPage extends StatelessWidget {
  final int id;
  const EduEventDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final e = DummyData.eduEvents.firstWhere((x) => x.id == id);
    final date =
        '${e.startAt.year}/${e.startAt.month}/${e.startAt.day}  '
        '${e.startAt.hour.toString().padLeft(2, '0')}:${e.startAt.minute.toString().padLeft(2, '0')} ~ '
        '${e.endAt.hour.toString().padLeft(2, '0')}:${e.endAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('교육일정 상세')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          Text(e.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(date, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Text('장소: ${e.location}', style: const TextStyle(color: Colors.black54)),
          Text('담당: ${e.host}', style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 14),
          Text(e.description, style: const TextStyle(fontSize: 15, height: 1.6)),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                e.applyUrl == null ? '신청 링크 없음' : '신청 링크: ${e.applyUrl}',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
