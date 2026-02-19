import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('개인정보처리방침')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Text(
          '개인정보처리방침 (샘플)\n\n'
              '1. 수집 항목\n'
              '- 이름, 휴대폰 번호, 아이디, 비밀번호(암호화 저장), (선택) 주소\n\n'
              '2. 이용 목적\n'
              '- 회원관리, 교적 매칭(이름/전화번호), 교회 소식 제공\n\n'
              '3. 보관 기간\n'
              '- 회원 탈퇴 시까지\n\n'
              '4. 문의\n'
              '- 이룸교회 사무실\n\n'
              '※ 본 문서는 샘플이며 실제 운영 전 법률 검토를 권장합니다.',
          style: TextStyle(height: 1.6),
        ),
      ),
    );
  }
}
