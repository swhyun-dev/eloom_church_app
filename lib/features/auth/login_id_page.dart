import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/account_role.dart';
import '../../models/church_registry_person.dart';
import '../../services/api_service.dart';
import '../../state/auth_provider.dart';

class LoginIdPage extends ConsumerStatefulWidget {
  final String? from;
  const LoginIdPage({super.key, this.from});

  @override
  ConsumerState<LoginIdPage> createState() => _LoginIdPageState();
}

class _LoginIdPageState extends ConsumerState<LoginIdPage> {
  static const _kSavedIdKey = 'auth_saved_userId';

  final idCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  bool busy = false;
  bool rememberMe = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSavedId();
  }

  Future<void> _loadSavedId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kSavedIdKey);
      if (saved != null && saved.isNotEmpty && mounted) {
        setState(() {
          idCtrl.text = saved;
          rememberMe = true;
        });
      }
    } catch (_) {
      // SharedPreferences 미동작 환경에서도 로그인 화면 자체는 노출되어야 함
    }
  }

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
      final Map<String, dynamic> decoded;
      try {
        decoded = await ApiService().post('/auth/login', {
          'userId': userId,
          'password': password,
        });
      } catch (e) {
        setState(() {
          busy = false;
          error = e.toString().replaceFirst('Exception: ', '');
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

      // 직분/교구/구역 중 하나라도 있으면 registry 객체 생성
      // (목사·사모 등 일부 직분은 교구/구역 정보가 비어 있어도 직분은 표시되어야 함)
      ChurchRegistryPerson? registry;
      final positionVal = (user?['position'] as String?) ?? '';
      final parishVal = (user?['parish'] as String?) ?? '';
      final zoneVal = (user?['zone'] as String?) ?? '';
      final hasAnyRegistry = positionVal.isNotEmpty ||
          parishVal.isNotEmpty ||
          zoneVal.isNotEmpty ||
          (user?['isDistrictLeader'] == true);
      if (hasAnyRegistry) {
        registry = ChurchRegistryPerson(
          name: user!['name'] as String? ?? '',
          phone: user['phone'] as String? ?? '',
          position: positionVal,
          parish: parishVal,
          district: zoneVal,
          isDistrictLeader: user['isDistrictLeader'] as bool? ?? false,
        );
      }

      await ref.read(authProvider.notifier).login(
            name: user?['name'] as String? ?? userId,
            userId: userId,
            phone: user?['phone'] as String? ?? '',
            role: role,
            token: token,
            registry: registry,
          );

      // 간편로그인 정보 저장 — 아이디만 저장(비번은 보안상 X)
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString(_kSavedIdKey, userId);
      } else {
        await prefs.remove(_kSavedIdKey);
      }

      if (!mounted) return;
      final dest = widget.from ?? '/';
      context.go(dest);
    } catch (e, st) {
      // 정확한 원인 추적 — 브라우저 콘솔에서 보임
      // ignore: avoid_print
      print('[login._submit] unexpected error: $e\n$st');
      setState(() {
        busy = false;
        error = '로그인 처리 중 오류가 발생했습니다. ($e)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0B4FA8);
    const labelColor = Color(0xFF111827);
    const subColor = Color(0xFF6B7280);
    const lineColor = Color(0xFFD1D5DB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('로그인',
            style: TextStyle(color: labelColor, fontWeight: FontWeight.w800)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: labelColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
          children: [
            const SizedBox(height: 8),
            const Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 26,
                  color: labelColor,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(text: '안녕하세요!\n'),
                  TextSpan(
                      text: '이룸교회',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  TextSpan(text: '에 오신 것을\n환영합니다.'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '회원 서비스 이용을 위해 로그인 해주세요.',
              style: TextStyle(fontSize: 14, color: subColor),
            ),
            const SizedBox(height: 48),

            TextField(
              controller: idCtrl,
              enabled: !busy,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 15, color: labelColor),
              decoration: const InputDecoration(
                hintText: '아이디를 입력해주세요.',
                hintStyle: TextStyle(color: Color(0xFFB0B7C3), fontSize: 15),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: lineColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pwCtrl,
              enabled: !busy,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(fontSize: 15, color: labelColor),
              decoration: const InputDecoration(
                hintText: '비밀번호를 입력해주세요.',
                hintStyle: TextStyle(color: Color(0xFFB0B7C3), fontSize: 15),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: lineColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 간편로그인 정보 저장
            InkWell(
              onTap: busy ? null : () => setState(() => rememberMe = !rememberMe),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: rememberMe,
                      onChanged: busy
                          ? null
                          : (v) => setState(() => rememberMe = v ?? false),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                      side: const BorderSide(color: Color(0xFFB0B7C3)),
                      activeColor: primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '간편로그인 정보 저장',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!,
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],

            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16),
                ),
                onPressed: busy ? null : _submit,
                child: busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('로그인'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16),
                ),
                onPressed: busy ? null : () => context.push('/signup/terms'),
                child: const Text('회원가입'),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _BottomLink(text: '이용약관'),
                Text('  |  ',
                    style: TextStyle(
                        color: Color(0xFF9CA3AF), fontWeight: FontWeight.w700)),
                _BottomLink(text: '개인정보처리방침'),
                Text('  |  ',
                    style: TextStyle(
                        color: Color(0xFF9CA3AF), fontWeight: FontWeight.w700)),
                _BottomLink(text: '이용안내'),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: labelColor,
        unselectedItemColor: subColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        onTap: (i) {
          if (i == 0) context.go('/');
          if (i == 1) context.go('/my');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'My'),
        ],
      ),
    );
  }
}

class _BottomLink extends StatelessWidget {
  final String text;
  const _BottomLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        color: Color(0xFF6B7280),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
