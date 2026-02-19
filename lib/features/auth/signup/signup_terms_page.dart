import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupTermsPage extends StatefulWidget {
  const SignupTermsPage({super.key});

  @override
  State<SignupTermsPage> createState() => _SignupTermsPageState();
}

class _SignupTermsPageState extends State<SignupTermsPage> {
  bool allAgree = false;
  bool agreeApp = false;     // 필수
  bool agreePrivacy = false; // 필수
  bool agreeAlarm = false;   // 필수(이미지 기준)

  bool get canNext => agreeApp && agreePrivacy && agreeAlarm;

  void _toggleAll(bool v) {
    setState(() {
      allAgree = v;
      agreeApp = v;
      agreePrivacy = v;
      agreeAlarm = v;
    });
  }

  void _syncAll() {
    final v = agreeApp && agreePrivacy && agreeAlarm;
    setState(() => allAgree = v);
  }

  Future<void> _openTermsDetail(String title, String content) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('약관 상세내용', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(content, style: const TextStyle(fontSize: 13.5, height: 1.6)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row({
    required bool value,
    required String title,
    required bool required,
    VoidCallback? onDetail,
    required ValueChanged<bool> onChanged,
  }) {
    const reqColor = Color(0xFFEF4444);
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(text: title),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: required ? '(필수)' : '(선택)',
                      style: TextStyle(
                        color: required ? reqColor : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onDetail != null)
              InkWell(
                onTap: onDetail,
                child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
              ),
          ],
        ),
      ),
    );
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
            '서비스 이용을 위해\n필수 약관동의가 필요합니다.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.3),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
            child: Column(
              children: [
                _row(
                  value: allAgree,
                  title: '모두 동의합니다.',
                  required: true,
                  onChanged: _toggleAll,
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                _row(
                  value: agreeApp,
                  title: '어플리케이션(APP) 이용약관',
                  required: true,
                  onDetail: () => _openTermsDetail('이룸교회 어플리케이션(APP) 이용약관', _appTerms),
                  onChanged: (v) {
                    setState(() => agreeApp = v);
                    _syncAll();
                  },
                ),
                _row(
                  value: agreePrivacy,
                  title: '개인정보 수집 및 이용 동의',
                  required: true,
                  onDetail: () => _openTermsDetail('개인정보 수집 및 이용 동의', _privacyTerms),
                  onChanged: (v) {
                    setState(() => agreePrivacy = v);
                    _syncAll();
                  },
                ),
                _row(
                  value: agreeAlarm,
                  title: '알림 서비스 이용 동의',
                  required: true,
                  onDetail: () => _openTermsDetail('알림 서비스 이용 동의', _alarmTerms),
                  onChanged: (v) {
                    setState(() => agreeAlarm = v);
                    _syncAll();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('취소하기', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF93C5FD),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: canNext
                        ? () => context.push(
                      '/signup/phone',
                      extra: {
                        'agreedApp': agreeApp,
                        'agreedPrivacy': agreePrivacy,
                        'agreedAlarm': agreeAlarm,
                      },
                    )
                        : null,
                    child: const Text('동의하기', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const String _appTerms = '... (샘플 약관 텍스트) ...';
const String _privacyTerms = '... (샘플 개인정보 동의 텍스트) ...';
const String _alarmTerms = '... (샘플 알림 동의 텍스트) ...';
