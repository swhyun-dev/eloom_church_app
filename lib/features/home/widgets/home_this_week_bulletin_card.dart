import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../bulletin/presentation/providers/bulletin_providers.dart';

class HomeThisWeekBulletinCard extends ConsumerWidget {
  const HomeThisWeekBulletinCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(bulletinListProvider);

    return asyncList.when(
      loading: () => const SizedBox(
        height: 190,
        child: Card(child: Center(child: CircularProgressIndicator())),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        final b = (list.toList()..sort((a, b) => b.date.compareTo(a.date))).first;
        final date =
            '${b.date.year}/${b.date.month.toString().padLeft(2, '0')}/${b.date.day.toString().padLeft(2, '0')}';

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push('/bulletins/${b.id}'),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 190,
              width: double.infinity,
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
                          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _Pill(text: '이번주 주보'),
                        const SizedBox(height: 8),
                        Text(
                          b.title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(date, style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/bulletins'),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.14),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('주보 더보기'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
    );
  }
}
