import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/bulletin_service.dart';

class BulletinGalleryPage extends StatefulWidget {
  const BulletinGalleryPage({super.key});

  @override
  State<BulletinGalleryPage> createState() => _BulletinGalleryPageState();
}

class _BulletinGalleryPageState extends State<BulletinGalleryPage> {
  late final Future<List<BulletinData>> _future;

  @override
  void initState() {
    super.initState();
    _future = BulletinService().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('교회주보')),
      body: FutureBuilder<List<BulletinData>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('오류: ${snap.error}'));
          }
          final list = (snap.data ?? [])..sort((a, b) => b.date.compareTo(a.date));
          if (list.isEmpty) {
            return const Center(child: Text('등록된 주보가 없습니다.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: list.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.7,
            ),
            itemBuilder: (context, i) {
              final b = list[i];
              final date = '${b.date.year}/${b.date.month}/${b.date.day}';

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/bulletins/${b.id}'),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: b.thumbUrl.isNotEmpty
                            ? Image.network(
                                b.thumbUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(color: Colors.black12),
                              )
                            : Container(color: Colors.black12),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(date, style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
                          ],
                        ),
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
