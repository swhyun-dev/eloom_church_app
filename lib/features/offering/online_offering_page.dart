// online_offering_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class OnlineOfferingPage extends StatelessWidget {
  const OnlineOfferingPage({super.key});

  static const bankLine = '신협 131-017-44000-1';
  static const holderLine = '예금주 대한예수교장로회이룸교회';
  static const copyText = '신협 131-017-44000-1 (예금주 대한예수교장로회이룸교회)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('온라인 헌금')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _AccountCard(
            bank: bankLine,
            holder: holderLine,
            onCopy: () async {
              await Clipboard.setData(const ClipboardData(text: copyText));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('계좌번호가 복사되었습니다.')),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          _GuideCard(),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.push('/offering/receipt'),
            child: const Text('기부금 영수증 신청하기'),
          ),
          const SizedBox(height: 10),
          const Text(
            '※ 미로그인 시 로그인 페이지로 이동합니다.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String bank;
  final String holder;
  final VoidCallback onCopy;

  const _AccountCard({
    required this.bank,
    required this.holder,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('계좌번호', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(bank, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(holder, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('계좌번호 복사'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade50,
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('입금자명 예시', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('예시) 주사랑_감사', style: TextStyle(fontSize: 15)),
            SizedBox(height: 8),
            Text(
              '헌금 종류/이름을 구분해 주시면 확인이 더 빠릅니다.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
