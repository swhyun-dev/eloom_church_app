import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 첫 프레임 이후 실행 (context 안정)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer(const Duration(milliseconds: 3000), () {
        if (!mounted) return;

        final auth = ref.read(authProvider);
        // ✅ 로그인 상태면 홈, 아니면 홈(또는 로그인으로 보내고 싶으면 /login)
        final next = auth.isLoggedIn ? '/' : '/';
        context.go(next);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FA),
      body: Center(
        child: Image.asset(
          'assets/images/splash.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
