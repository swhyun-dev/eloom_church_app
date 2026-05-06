import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/account_role.dart';
import '../../models/church_registry_person.dart';
import '../../state/auth_provider.dart';

class LoginIdPage extends ConsumerStatefulWidget {
  final String? from;
  const LoginIdPage({super.key, this.from});

  @override
  ConsumerState<LoginIdPage> createState() => _LoginIdPageState();
}

class _LoginIdPageState extends ConsumerState<LoginIdPage> {
  final idCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  bool busy = false;
  bool obscure = true;
  String? error;

  @override
  void dispose() {
    idCtrl.dispose();
    pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userId = idCtrl.text.trim();
    final password = pwCtrl.text;

    if (userId.isEmpty || password.isEmpty) {
      setState(() => error = '아이디와 비밀번호를 입력해주세요.');
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'password': password}),
      );

      final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

      if (res.statusCode < 200 || res.statusCode >= 300) {
        setState(() {
          busy = false;
          error = (decoded['message'] as String?) ?? '로그인에 실패했습니다.';
        });
        return;
      }

      final token = decoded['token'] as String?;
      final user = decoded['user'] as Map<String, dynamic>?;

      final apiRole = user?['role'] as String? ?? 'PENDING';
      final roleMap = {
        'ADMIN': AccountRole.admin,
        'SUPER_ADMIN': AccountRole.admin,
        'MINISTER': AccountRole.staff,
        'MEMBER': AccountRole.member,
        'PENDING': AccountRole.pending,
      };
      final role = roleMap[apiRole] ?? AccountRole.pending;

      ChurchRegistryPerson? registry;
      if (user?['zone'] != null && user?['parish'] != null) {
        registry = ChurchRegistryPerson(
          name: user!['name'] as String? ?? '',
          phone: user['phone'] as String? ?? '',
          position: user['position'] as String? ?? '',
          parish: user['parish'] as String,
          district: user['zone'] as String,
          isDistrictLeader: user['isDistrictLeader'] as bool? ?? false,
        );
      }

      ref.read(authProvider.notifier).login(
        name: user?['name'] as String? ?? userId,
        userId: userId,
        phone: user?['phone'] as String? ?? '',
        role: role,
        token: token,
        registry: registry,
      );

      if (!mounted) return;

      final dest = widget.from ?? '/';
      context.go(dest);
    } catch (e) {
      setState(() {
        busy = false;
        error = '네트워크 오류가 발생했습니다. ($e)';
      });
    }
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
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            const Text(
              '아이디로 로그인',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              '가입 시 등록한 아이디와 비밀번호를 입력해주세요.',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: idCtrl,
              enabled: !busy,
              textInputAction: TextInputAction.next,
              decoration: _inputDeco('아이디'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pwCtrl,
              enabled: !busy,
              obscureText: obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: _inputDeco('비밀번호').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 20),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
            ),

            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 13)),
            ],

            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                onPressed: busy ? null : _submit,
                child: busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('로그인'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
