import 'package:flutter/material.dart';
import '../../services/bulletin_service.dart';

class BulletinDetailPage extends StatefulWidget {
  final int id;
  const BulletinDetailPage({super.key, required this.id});

  @override
  State<BulletinDetailPage> createState() => _BulletinDetailPageState();
}

class _BulletinDetailPageState extends State<BulletinDetailPage> {
  late final Future<BulletinData?> _future;

  @override
  void initState() {
    super.initState();
    _future = BulletinService().fetchById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주보 상세')),
      body: FutureBuilder<BulletinData?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('오류: ${snap.error}'));
          }
          final b = snap.data;
          if (b == null) {
            return const Center(child: Text('주보를 찾을 수 없습니다.'));
          }

          final date = '${b.date.year}/${b.date.month}/${b.date.day}';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              Text(b.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(date, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 14),
              ...b.imageUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(height: 220, color: Colors.black12),
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
