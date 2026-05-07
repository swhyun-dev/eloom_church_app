import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/bulletin.dart';
import '../providers/bulletin_providers.dart';

class BulletinGalleryPage extends ConsumerWidget {
  const BulletinGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(bulletinListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('교회주보')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(bulletinListProvider),
        child: AsyncValueBuilder<List<Bulletin>>(
          value: asyncList,
          onRetry: () => ref.invalidate(bulletinListProvider),
          emptyMessage: '등록된 주보가 없습니다.',
          builder: (list) {
            final sorted = [...list]..sort((a, b) => b.date.compareTo(a.date));
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: sorted.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.7,
              ),
              itemBuilder: (context, i) => _BulletinCard(bulletin: sorted[i]),
            );
          },
        ),
      ),
    );
  }
}

class _BulletinCard extends StatelessWidget {
  final Bulletin bulletin;
  const _BulletinCard({required this.bulletin});

  @override
  Widget build(BuildContext context) {
    final b = bulletin;
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
  }
}
