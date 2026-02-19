import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../dummy/dummy_data.dart';

class BulletinGalleryPage extends StatelessWidget {
  const BulletinGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final list = [...DummyData.bulletins]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text('교회주보')),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // 큰 썸네일 느낌(원하면 2로 변경)
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
                    child: Image.network(
                      b.thumbUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [Colors.black.withOpacity(0.55), Colors.transparent],
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
                        Text(date, style: TextStyle(color: Colors.white.withOpacity(0.85))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
