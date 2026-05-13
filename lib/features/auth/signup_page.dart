import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../services/registry_matcher.dart';
import '../../../state/auth_provider.dart';

class SignupPage extends ConsumerStatefulWidget {
  final String verifiedPhone; // 숫자만
  const SignupPage({super.key, required this.verifiedPhone});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final nameCtrl = TextEditingController();
  final idCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  final pw2Ctrl = TextEditingController();
  final addrCtrl = TextEditingController(); // 선택된 도로명 주소가 들어감

  bool agreed = false;
  String? error;

  @override
  void dispose() {
    nameCtrl.dispose();
    idCtrl.dispose();
    pwCtrl.dispose();
    pw2Ctrl.dispose();
    addrCtrl.dispose();
    super.dispose();
  }

  bool _pwMatch() => pwCtrl.text.trim() == pw2Ctrl.text.trim();

  Future<void> _openTerms(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('개인정보 수집/이용 동의', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: const Text(
                        _termsText,
                        style: TextStyle(fontSize: 13.5, height: 1.6, color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('확인'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickAddress() async {
    final result = await context.push<String>('/address-search');
    if (!mounted) return;
    if (result != null && result.trim().isNotEmpty) {
      setState(() => addrCtrl.text = result.trim());
    }
  }

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    final userId = idCtrl.text.trim();
    final pw = pwCtrl.text.trim();
    final pw2 = pw2Ctrl.text.trim();
    final addr = addrCtrl.text.trim(); // 빈 문자열 가능
    final phone = widget.verifiedPhone;

    if (name.isEmpty || userId.isEmpty || pw.isEmpty || pw2.isEmpty) {
      setState(() => error = '필수 항목을 입력해주세요.');
      return;
    }
    if (!_pwMatch()) {
      setState(() => error = '비밀번호가 일치하지 않습니다.');
      return;
    }
    if (!agreed) {
      setState(() => error = '개인정보 수집/이용에 동의해주세요.');
      return;
    }

    // ✅ 교적 매칭(이름 + 전화번호)
    final matched = RegistryMatcher.match(name: name, phone: phone);

    // ✅ 가입 완료 (현재는 로컬 상태만 변경)
    await ref.read(authProvider.notifier).applySignupResult(
      name: name,
      userId: userId,
      phone: phone,
      address: addr,
      agreedPrivacy: agreed,
      matchedRegistry: matched,
    );

    final roleLabel = matched != null ? '성도' : '준회원';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('회원가입 완료: $roleLabel')),
    );

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.verifiedPhone;

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text('인증된 휴대폰 번호로 가입을 진행합니다.', style: TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 6),
          Text('휴대폰: $phone', style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),

          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: '이름',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: idCtrl,
            decoration: InputDecoration(
              labelText: '아이디',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: pwCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '비밀번호',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: (_) {
              if (error == '비밀번호가 일치하지 않습니다.') setState(() => error = null);
            },
          ),
          const SizedBox(height: 10),

          // ✅ 비밀번호 확인
          TextField(
            controller: pw2Ctrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '비밀번호 확인',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              helperText: pw2Ctrl.text.isEmpty
                  ? null
                  : (_pwMatch() ? '비밀번호가 일치합니다.' : '비밀번호가 일치하지 않습니다.'),
              helperStyle: TextStyle(
                color: pw2Ctrl.text.isEmpty ? Colors.black45 : (_pwMatch() ? Colors.green : Colors.red),
                fontWeight: FontWeight.w700,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),

          // ✅ 주소(도로명) 검색
          TextField(
            controller: addrCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: '주소(도로명, 선택)',
              hintText: '주소 검색 버튼을 눌러 선택하세요',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _pickAddress,
                tooltip: '주소 검색',
              ),
            ),
            onTap: _pickAddress,
          ),
          const SizedBox(height: 14),

          // ✅ 약관 + 동의
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => agreed = !agreed),
            child: Row(
              children: [
                Checkbox(value: agreed, onChanged: (v) => setState(() => agreed = v ?? false)),
                const Expanded(
                  child: Text('개인정보 수집/이용에 동의합니다.', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                TextButton(
                  onPressed: () => _openTerms(context),
                  child: const Text('약관보기'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('가입하기'),
          ),

          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}

const String _termsText =
    '1. 수집 항목\n'
    '- 필수: 이름, 휴대폰 번호, 아이디, 비밀번호, 주소\n'
    '- (교적 매칭 시) 교적 정보: 직분, 교구, 구역, 구역장 여부\n\n'
    '2. 수집/이용 목적\n'
    '- 회원 식별 및 본인확인\n'
    '- 교적 DB 매칭을 통한 성도 인증(이름/휴대폰 번호)\n'
    '- 교회 소식/모임 공지 등 서비스 제공\n\n'
    '3. 보유 및 이용 기간\n'
    '- 회원 탈퇴 시까지 보관하며, 관련 법령에 따라 보존이 필요한 경우 해당 기간 보관할 수 있습니다.\n\n'
    '4. 동의 거부 권리 및 불이익\n'
    '- 개인정보 수집/이용에 대한 동의를 거부할 수 있으나, 동의 거부 시 회원가입이 제한됩니다.\n\n'
    '※ 본 약관은 샘플이며, 실제 서비스 운영 시 교회 방침 및 법률 검토를 권장합니다.';
