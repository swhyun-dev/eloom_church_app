import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? from; // ✅ 라우터에서 decode된 값이 들어옴
  const LoginPage({super.key, this.from});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final idCtrl = TextEditingController();
  final pwCtrl = TextEditingController();

  bool rememberSimpleLogin = false;

  @override
  void dispose() {
    idCtrl.dispose();
    pwCtrl.dispose();
    super.dispose();
  }

  InputDecoration _underlineInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    );
  }

  void _login() {
    // 1) 로그인 상태 업데이트 (더미)
    ref.read(authProvider.notifier).login(
      name: '홍길동',
      userId: 'hong',
      phone: '01012345678',
    );

    // 2) ✅ 복귀 경로 결정: 생성자 from(최우선) → 쿼리 from(보조) → 홈
    final qpFrom = GoRouterState.of(context).uri.queryParameters['from'];
    final target = (widget.from != null && widget.from!.trim().isNotEmpty)
        ? widget.from!
        : (qpFrom != null && qpFrom.trim().isNotEmpty)
        ? Uri.decodeComponent(qpFrom)
        : '/';

    // 3) ✅ 로그인 페이지를 스택에서 치우고 이동
    context.go(target);
  }

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
            const SizedBox(height: 26),

            // 아이디
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
              ),
              child: TextField(
                controller: idCtrl,
                keyboardType: TextInputType.text,
                decoration: _underlineInput('아이디를 입력해주세요.'),
              ),
            ),
            const SizedBox(height: 10),

            // 비밀번호
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
              ),
              child: TextField(
                controller: pwCtrl,
                obscureText: true,
                decoration: _underlineInput('비밀번호를 입력해주세요.'),
              ),
            ),

            const SizedBox(height: 14),

            // 간편로그인 저장
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => rememberSimpleLogin = !rememberSimpleLogin),
              child: Row(
                children: [
                  Checkbox(
                    value: rememberSimpleLogin,
                    onChanged: (v) => setState(() => rememberSimpleLogin = v ?? false),
                  ),
                  const Text(
                    '간편로그인 정보 저장',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 로그인 버튼
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                onPressed: _login,
                child: const Text('로그인'),
              ),
            ),

            const SizedBox(height: 10),

            // 회원가입 버튼
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

            // 하단 링크
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
