// 교회카페 — 주문 시스템 준비중 안내 화면.
// 기존 주문/결제/메뉴 UI는 git 히스토리(이전 커밋)에 보존됨.
// 서비스 오픈 시 이전 구현을 복원하거나 새 디자인으로 교체.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CafePage extends StatelessWidget {
  final int initialTab;
  const CafePage({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('교회카페'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_cafe_outlined,
                    size: 64,
                    color: Color(0xFFA0522D),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  '교회카페 준비중',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '카페 주문 시스템을 준비하고 있습니다.\n곧 정식 서비스로 만나뵙겠습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B4FA8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text(
                      '홈으로',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
