import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupPhoneVerifyPage extends StatefulWidget {
  final bool agreedApp;
  final bool agreedPrivacy;
  final bool agreedAlarm;

  const SignupPhoneVerifyPage({
    super.key,
    required this.agreedApp,
    required this.agreedPrivacy,
    required this.agreedAlarm,
  });

  @override
  State<SignupPhoneVerifyPage> createState() => _SignupPhoneVerifyPageState();
}

class _SignupPhoneVerifyPageState extends State<SignupPhoneVerifyPage> {
  final nameCtrl = TextEditingController();
  final birthCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final captchaCtrl = TextEditingController();

  bool agreeForVerify = false; // "전화번호 인증 개인정보 수집 및 이용 동의"
  String? error;

  @override
  void dispose() {
    nameCtrl.dispose();
    birthCtrl.dispose();
    phoneCtrl.dispose();
    captchaCtrl.dispose();
    super.dispose();
  }

  InputDecoration _underline(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    );
  }

  Widget _lineField({required String label, required TextEditingController ctrl, String? hint, TextInputType? type}) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: TextField(
              controller: ctrl,
              keyboardType: type,
              decoration: _underline(hint ?? ''),
            ),
          ),
        ),
      ],
    );
  }

  void _kakaoVerifyMock() {
    final name = nameCtrl.text.trim();
    final birth = birthCtrl.text.trim();
    final phone = phoneCtrl.text.trim();

    if (name.isEmpty || birth.isEmpty || phone.isEmpty) {
      setState(() => error = '필수 항목을 입력해주세요.');
      return;
    }
    if (!agreeForVerify) {
      setState(() => error = '전화번호 인증을 위한 개인정보 동의가 필요합니다.');
      return;
    }

    // ✅ TODO: 실제 카카오/문자인증 연동 시 여기를 교체
    final verifiedPhoneDigitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');

    context.push(
      '/signup/info',
      extra: {
        'verifiedPhone': verifiedPhoneDigitsOnly,
        'agreedApp': widget.agreedApp,
        'agreedPrivacy': widget.agreedPrivacy,
        'agreedAlarm': widget.agreedAlarm,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const kakaoYellow = Color(0xFFFEE500);

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
            '회원가입을 위해서\n전화번호를 인증해주세요.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.3),
          ),
          const SizedBox(height: 24),

          _lineField(label: '이름', ctrl: nameCtrl, hint: '이름'),
          const SizedBox(height: 10),
          _lineField(label: '생년월일', ctrl: birthCtrl, hint: 'YYYYMMDD, 8자리', type: TextInputType.number),
          const SizedBox(height: 10),
          _lineField(label: '휴대폰번호', ctrl: phoneCtrl, hint: '숫자만 입력', type: TextInputType.phone),
          const SizedBox(height: 14),

          // 보안문자(UI만)
          Row(
            children: [
              const SizedBox(
                width: 80,
                child: Text('보안문자', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFF9FAFB),
                ),
                child: const Text('GSRMQ', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  child: TextField(
                    controller: captchaCtrl,
                    decoration: _underline('위에 보이는 문자를 입력해주세요.'),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 개인정보 동의
          InkWell(
            onTap: () => setState(() => agreeForVerify = !agreeForVerify),
            child: Row(
              children: [
                Checkbox(value: agreeForVerify, onChanged: (v) => setState(() => agreeForVerify = v ?? false)),
                const Expanded(
                  child: Text(
                    '전화번호 인증 개인정보 수집 및 이용에 동의합니다.',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '수집항목: 이름, 생년월일, 휴대폰 번호\n인증 완료 후 즉시 폐기됩니다.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.4),
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kakaoYellow,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _kakaoVerifyMock,
              child: const Text('카카오톡 인증하기', style: TextStyle(fontWeight: FontWeight.w900)),
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
