import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PhoneVerifyPage extends StatefulWidget {
  const PhoneVerifyPage({super.key});

  @override
  State<PhoneVerifyPage> createState() => _PhoneVerifyPageState();
}

class _PhoneVerifyPageState extends State<PhoneVerifyPage> {
  final phoneCtrl = TextEditingController();
  final codeCtrl = TextEditingController();

  bool sent = false;
  String? error;

  String _digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  void dispose() {
    phoneCtrl.dispose();
    codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('휴대폰 인증')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text(
            '휴대폰 인증 후 회원가입을 진행합니다.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: '휴대폰 번호',
              hintText: '01012345678',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              final phone = _digits(phoneCtrl.text);
              if (phone.length < 10) {
                setState(() {
                  error = '휴대폰 번호를 정확히 입력해주세요.';
                });
                return;
              }
              setState(() {
                sent = true;
                error = null;
              });
              // TODO: 실제 SMS 발송 로직(Firebase Phone Auth 등)로 교체
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('인증번호가 발송되었습니다. (더미: 1234)')),
              );
            },
            child: const Text('인증번호 받기'),
          ),

          if (sent) ...[
            const SizedBox(height: 14),
            TextField(
              controller: codeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '인증번호',
                hintText: '1234',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final code = codeCtrl.text.trim();
                if (code != '1234') {
                  setState(() => error = '인증번호가 올바르지 않습니다.');
                  return;
                }
                final phone = _digits(phoneCtrl.text);
                // ✅ 인증 완료 → 회원가입 폼으로 이동(전화번호 전달)
                context.push('/signup', extra: phone);
              },
              child: const Text('인증 완료'),
            ),
          ],

          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}
