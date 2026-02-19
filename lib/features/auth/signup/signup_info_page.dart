import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../services/registry_matcher.dart';
import '../../../state/auth_provider.dart';

class SignupInfoPage extends ConsumerStatefulWidget {
  final String verifiedPhone;
  final bool agreedApp;
  final bool agreedPrivacy;
  final bool agreedAlarm;

  const SignupInfoPage({
    super.key,
    required this.verifiedPhone,
    required this.agreedApp,
    required this.agreedPrivacy,
    required this.agreedAlarm,
  });

  @override
  ConsumerState<SignupInfoPage> createState() => _SignupInfoPageState();
}

class _SignupInfoPageState extends ConsumerState<SignupInfoPage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final idCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  final pw2Ctrl = TextEditingController();
  final zipCtrl = TextEditingController();
  final addrCtrl = TextEditingController();
  final emailIdCtrl = TextEditingController();

  String emailDomain = '선택하기';
  String? error;

  @override
  void initState() {
    super.initState();
    // ✅ 인증된 휴대폰번호 자동 세팅
    phoneCtrl.text = widget.verifiedPhone;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    idCtrl.dispose();
    pwCtrl.dispose();
    pw2Ctrl.dispose();
    zipCtrl.dispose();
    addrCtrl.dispose();
    emailIdCtrl.dispose();
    super.dispose();
  }

  bool _pwMatch() => pwCtrl.text.trim() == pw2Ctrl.text.trim();

  Widget _row({
    required String label,
    required Widget field,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 92,
            child: Row(
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
                if (required)
                  const Text(' *', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Expanded(child: field),
        ],
      ),
    );
  }

  InputDecoration _boxHint(String hint, {bool disabled = false}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: disabled,
      fillColor: disabled ? const Color(0xFFF3F4F6) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _submit() {
    final name = nameCtrl.text.trim();
    final userId = idCtrl.text.trim();
    final pw = pwCtrl.text.trim();
    final pw2 = pw2Ctrl.text.trim();

    if (name.isEmpty || userId.isEmpty || pw.isEmpty || pw2.isEmpty) {
      setState(() => error = '필수 항목을 입력해주세요.');
      return;
    }
    if (!_pwMatch()) {
      setState(() => error = '비밀번호가 일치하지 않습니다.');
      return;
    }

    // ✅ 교적 DB 매칭 (이름 + 휴대폰번호)
    final matched = RegistryMatcher.match(
      name: name,
      phone: widget.verifiedPhone,
    );

    ref.read(authProvider.notifier).applySignupResult(
      name: matched?.name ?? name,
      userId: userId,
      phone: widget.verifiedPhone,
      address: addrCtrl.text.trim(),
      agreedPrivacy: widget.agreedPrivacy,
      matchedRegistry: matched,
    );

    ref.read(authProvider.notifier).login(
      name: matched?.name ?? name,
      userId: userId,
      phone: widget.verifiedPhone,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('가입 완료! 자동 로그인 되었습니다.')),
    );

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0B4FA8);

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const Text(
            '회원가입을 위해서\n정보를 입력해주세요.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.3),
          ),
          const SizedBox(height: 12),

          // ✅ 교적 매칭 안내 박스
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '이름은 교적 정보와 정확히 일치해야 정상적으로 매칭됩니다.\n'
                  '띄어쓰기, 개명 전/후 이름이 다를 경우 매칭되지 않을 수 있습니다.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.4),
            ),
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '* 필수항목',
              style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),

          // ✅ 이름 (교적 매칭 핵심)
          _row(
            label: '이름',
            required: true,
            field: TextField(
              controller: nameCtrl,
              decoration: _boxHint('교적에 등록된 이름을 입력해주세요'),
            ),
          ),

          // ✅ 휴대폰번호 (인증 완료 / 수정 불가)
          _row(
            label: '휴대폰번호',
            required: true,
            field: TextField(
              controller: phoneCtrl,
              readOnly: true,
              decoration: _boxHint('', disabled: true),
            ),
          ),

          _row(
            label: '아이디',
            required: true,
            field: TextField(
              controller: idCtrl,
              decoration: _boxHint('6자리 이상 영문, 숫자'),
            ),
          ),
          _row(
            label: '비밀번호',
            required: true,
            field: TextField(
              controller: pwCtrl,
              obscureText: true,
              decoration: _boxHint('비밀번호를 입력해주세요'),
            ),
          ),
          _row(
            label: '비밀번호확인',
            required: true,
            field: TextField(
              controller: pw2Ctrl,
              obscureText: true,
              decoration: _boxHint('비밀번호를 한번 더 입력해주세요'),
              onChanged: (_) {
                if (error == '비밀번호가 일치하지 않습니다.') setState(() => error = null);
              },
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _submit,
              child: const Text('회원가입완료', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),

          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}