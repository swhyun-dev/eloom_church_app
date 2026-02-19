import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FellowBoardPage extends StatelessWidget {
  const FellowBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_FellowPost>[
      _FellowPost(
        id: 'f1',
        category: '장례',
        title: '김OO 성도님 장례 안내',
        date: DateTime.now().subtract(const Duration(days: 1)),
        content:
        '• 빈소: OO장례식장 3호실\n'
            '• 입관: 1/20(화) 15:00\n'
            '• 발인: 1/21(수) 08:30\n\n'
            '유가족을 위해 함께 기도 부탁드립니다.',
      ),
      _FellowPost(
        id: 'f2',
        category: '결혼',
        title: '박OO 성도님 자녀 결혼식 안내',
        date: DateTime.now().subtract(const Duration(days: 3)),
        content:
        '• 일시: 1/25(일) 오후 2:00\n'
            '• 장소: OO웨딩홀 5층\n\n'
            '축복과 축하로 함께해 주세요.',
      ),
      _FellowPost(
        id: 'f3',
        category: '출산',
        title: '이OO 성도님 출산 소식 (축하드립니다)',
        date: DateTime.now().subtract(const Duration(days: 5)),
        content:
        '하나님의 은혜로 건강하게 출산하셨습니다.\n'
            '산모와 아이의 건강을 위해 기도 부탁드립니다.',
      ),
      _FellowPost(
        id: 'f4',
        category: '중보',
        title: '정OO 성도님 입원 중입니다. 기도 부탁드립니다.',
        date: DateTime.now().subtract(const Duration(days: 7)),
        content:
        '현재 치료 중이십니다.\n'
            '회복을 위해 중보기도 부탁드립니다.',
      ),
      _FellowPost(
        id: 'f5',
        category: '새가족',
        title: '새가족 환영: 최OO 성도님(인도: 김OO 집사)',
        date: DateTime.now().subtract(const Duration(days: 9)),
        content:
        '새가족으로 함께하게 되었습니다.\n'
            '따뜻한 환영과 교제 부탁드립니다.',
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('교우동정'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final p = items[i];

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => context.push('/boards/fellow/${p.id}'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x11000000)),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.blue.withOpacity(0.08),
                    ),
                    child: Text(
                      p.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      p.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _fmtDate(p.date),
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
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

class _FellowPost {
  final String id;
  final String category;
  final String title;
  final DateTime date;
  final String content;

  const _FellowPost({
    required this.id,
    required this.category,
    required this.title,
    required this.date,
    required this.content,
  });
}

String _fmtDate(DateTime d) =>
    '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
