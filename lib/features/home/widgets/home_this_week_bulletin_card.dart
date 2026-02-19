import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../dummy/dummy_data.dart';

class HomeThisWeekBulletinCard extends StatelessWidget {
  const HomeThisWeekBulletinCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미: 가장 최신 주보를 “이번주”로 취급
    final list = [...DummyData.bulletins]..sort((a, b) => b.date.compareTo(a.date));
    final b = list.first;

    final date = '${b.date.year}/${b.date.month.toString().padLeft(2, '0')}/${b.date.day.toString().padLeft(2, '0')}';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push('/bulletins/${b.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 190, // ✅ 여기만 지정하면 Stack 에러 해결
          width: double.infinity,
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
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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
                    _Pill(text: '이번주 주보'),
                    const SizedBox(height: 8),
                    Text(
                      b.title,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(date, style: TextStyle(color: Colors.white.withOpacity(0.85))),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/bulletins'),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.14),
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
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
    );
  }
}
