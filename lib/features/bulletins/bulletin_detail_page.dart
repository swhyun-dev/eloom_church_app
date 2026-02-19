import 'package:flutter/material.dart';
import '../../dummy/dummy_data.dart';

class BulletinDetailPage extends StatelessWidget {
  final int id;
  const BulletinDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final b = DummyData.bulletins.firstWhere((x) => x.id == id);
    final date = '${b.date.year}/${b.date.month}/${b.date.day}';

    return Scaffold(
      appBar: AppBar(title: const Text('주보 상세')),
      body: ListView(
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
                    errorBuilder: (_, __, ___) => Container(height: 220, color: Colors.black12),
                  ),
                ),
              )),
          if (b.pdfUrl != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text('PDF 링크: ${b.pdfUrl}', style: const TextStyle(color: Colors.black54)),
              ),
            ),
        ],
      ),
    );
  }
}
