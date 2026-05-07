import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/bulletin.dart';
import '../providers/bulletin_providers.dart';

class BulletinDetailPage extends ConsumerWidget {
  final int id;
  const BulletinDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bulletinByIdProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('주보 상세')),
      body: AsyncValueBuilder<Bulletin?>(
        value: async,
        onRetry: () => ref.invalidate(bulletinListProvider),
        isEmpty: (b) => b == null,
        emptyMessage: '주보를 찾을 수 없습니다.',
        builder: (b) {
          final bulletin = b!;
          final date = '${bulletin.date.year}/${bulletin.date.month}/${bulletin.date.day}';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              Text(bulletin.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(date, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 14),
              ...bulletin.imageUrls.map((url) => Padding(
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
