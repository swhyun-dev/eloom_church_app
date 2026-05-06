import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  final String? from;
  const LoginPage({super.key, this.from});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0B4FA8);

    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            const SizedBox(height: 6),
            const Text(
              '안녕하세요!\n이룸교회에 오신 것을\n환영합니다.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.25),
            ),
            const SizedBox(height: 12),
            const Text(
              '회원 서비스 이용을 위해 로그인 해주세요.',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 36),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                onPressed: () {
                  final encoded = from != null ? Uri.encodeComponent(from!) : null;
                  final query = encoded != null ? '?from=$encoded' : '';
                  context.push('/login/id$query');
                },
                child: const Text('아이디로 로그인'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                onPressed: () => context.push('/signup/terms'),
                child: const Text('회원가입'),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BottomLink(text: '이용약관', onTap: () {}),
                const Text('  |  ', style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w700)),
                _BottomLink(text: '개인정보처리방침', onTap: () {}),
                const Text('  |  ', style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w700)),
                _BottomLink(text: '이용안내', onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _BottomLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
