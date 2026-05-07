import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/http/app_dio.dart';
import '../../models/account_role.dart';
import '../../models/church_registry_person.dart';
import '../../state/auth_provider.dart';

class LoginPhonePage extends ConsumerStatefulWidget {
  final String? from;
  const LoginPhonePage({super.key, this.from});

  @override
  ConsumerState<LoginPhonePage> createState() => _LoginPhonePageState();
}

class _LoginPhonePageState extends ConsumerState<LoginPhonePage> {
  final phoneCtrl = TextEditingController();
  final codeCtrl = TextEditingController();

  final Dio _dio = AppDio.instance;

  bool agreeForVerify = false;
  bool requested = false;
  bool busy = false;

  String? verificationId;
  String _requestedPhone = '';
  int remainSec = 0;
  int resendBlockSec = 0;

  Timer? _timer;
  Timer? _resendTimer;

  String? error;

  @override
  void initState() {
    super.initState();
    phoneCtrl.addListener(() {
      if (!requested) return;
      if (phoneDigits != _requestedPhone) {
        setState(() {
          error ??= '번호가 변경되었습니다. 다시 요청해주세요.';
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resendTimer?.cancel();
    phoneCtrl.dispose();
    codeCtrl.dispose();
    super.dispose();
  }

  String get phoneDigits => phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

  void _startTimer(int ttl) {
    _timer?.cancel();
    setState(() => remainSec = ttl);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (remainSec <= 1) {
        t.cancel();
        setState(() => remainSec = 0);
        return;
      }
      setState(() => remainSec -= 1);
    });
  }

  void _startResendCooldown(int sec) {
    _resendTimer?.cancel();
    setState(() => resendBlockSec = sec);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (resendBlockSec <= 1) {
        t.cancel();
        setState(() => resendBlockSec = 0);
        return;
      }
      setState(() => resendBlockSec -= 1);
    });
  }

  void _reset({bool clearPhone = false}) {
    _timer?.cancel();
    _resendTimer?.cancel();
    setState(() {
      if (clearPhone) phoneCtrl.clear();
      codeCtrl.clear();
      requested = false;
      busy = false;
      verificationId = null;
      remainSec = 0;
      resendBlockSec = 0;
      _requestedPhone = '';
      error = null;
    });
  }

  String _errorMsg(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
      final status = e.response?.statusCode;
      if (status == 429) return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
      if (e.type == DioExceptionType.connectionError) {
        return '서버에 연결할 수 없습니다.';
      }
    }
    return '오류가 발생했습니다.';
  }

  Future<void> _requestCode() async {
    FocusScope.of(context).unfocus();
    if (!agreeForVerify) {
      setState(() => error = '개인정보 수집 동의가 필요합니다.');
      return;
    }
    if (phoneDigits.length < 10) {
      setState(() => error = '휴대폰 번호를 정확히 입력해주세요.');
      return;
    }
    if (resendBlockSec > 0) {
      setState(() => error = '$resendBlockSec초 후 재요청 가능합니다.');
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    try {
      final res = await _dio.post('/auth/sms/request', data: {'phone': phoneDigits});
      final data = Map<String, dynamic>.from(res.data as Map);
      final vid = data['verificationId'] as String?;
      final ttl = (data['ttlSec'] as num?)?.toInt() ?? 180;

      if (vid == null) throw Exception('verificationId missing');

      verificationId = vid;
      _requestedPhone = phoneDigits;

      setState(() {
        requested = true;
        busy = false;
      });
      _startTimer(ttl);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 429) {
        final data = e.response?.data;
        int retrySec = 0;
        if (data is Map) {
          final r = data['retryAfterSec'];
          if (r is num) retrySec = r.toInt();
        }
        if (retrySec > 0) _startResendCooldown(retrySec);
        setState(() {
          busy = false;
          error = '요청이 너무 많습니다. ${retrySec > 0 ? '$retrySec초 후 재요청 가능' : '잠시 후 다시 시도해주세요'}';
        });
        return;
      }
      setState(() {
        busy = false;
        error = _errorMsg(e);
      });
    }
  }

  Future<void> _confirmAndLogin() async {
    FocusScope.of(context).unfocus();

    if (requested && phoneDigits != _requestedPhone) {
      setState(() => error = '번호가 변경되었습니다. 다시 요청해주세요.');
      return;
    }

    final vid = verificationId;
    final code = codeCtrl.text.trim();

    if (vid == null) {
      setState(() => error = '인증번호를 먼저 요청해주세요.');
      return;
    }
    if (remainSec == 0) {
      setState(() => error = '인증 시간이 만료되었습니다. 다시 요청해주세요.');
      return;
    }
    if (code.length < 4) {
      setState(() => error = '인증번호를 입력해주세요.');
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    try {
      // Step 1: confirm OTP
      final confirmRes = await _dio.post('/auth/sms/confirm', data: {
        'verificationId': vid,
        'code': code,
      });
      final confirmData = Map<String, dynamic>.from(confirmRes.data as Map);
      final verifiedPhone = (confirmData['verifiedPhone'] as String?) ?? phoneDigits;

      // Step 2: login
      final loginRes = await _dio.post('/auth/sms/login', data: {
        'verifiedPhone': verifiedPhone,
      });
      final loginData = Map<String, dynamic>.from(loginRes.data as Map);

      final token = loginData['token'] as String?;
      final user = loginData['user'] as Map<String, dynamic>?;

      final apiRole = user?['role'] as String? ?? 'PENDING';
      const roleMap = {
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
          phone: verifiedPhone,
          position: user['position'] as String? ?? '',
          parish: user['parish'] as String,
          district: user['zone'] as String,
          isDistrictLeader: user['isDistrictLeader'] as bool? ?? false,
        );
      }

      ref.read(authProvider.notifier).login(
        name: user?['name'] as String? ?? '',
        userId: user?['userId'] as String? ?? '',
        phone: verifiedPhone,
        role: role,
        token: token,
        registry: registry,
      );

      if (!mounted) return;

      final target = (widget.from != null && widget.from!.isNotEmpty) ? widget.from! : '/';
      context.go(target);
    } on DioException catch (e) {
      setState(() {
        busy = false;
        error = _errorMsg(e);
      });
    } catch (e) {
      setState(() {
        busy = false;
        error = '오류가 발생했습니다. ($e)';
      });
    }
  }

  String get _mmss {
    final m = (remainSec ~/ 60).toString().padLeft(2, '0');
    final s = (remainSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const Text(
            '가입하신 휴대폰 번호로\n인증 후 로그인 합니다.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.3),
          ),
          const SizedBox(height: 18),

          InkWell(
            onTap: busy ? null : () => setState(() => agreeForVerify = !agreeForVerify),
            child: Row(
              children: [
                Checkbox(
                  value: agreeForVerify,
                  onChanged: busy ? null : (v) => setState(() => agreeForVerify = v ?? false),
                ),
                const Expanded(
                  child: Text(
                    '문자인증을 위한 개인정보 수집 및 이용에 동의합니다.',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '수집항목: 휴대폰 번호\n인증 목적 외 사용하지 않습니다.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.4),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: phoneCtrl,
                  enabled: !busy,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: '휴대폰 번호',
                    hintText: '숫자만 입력 (예: 01012345678)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (requested) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: busy ? null : () => _reset(clearPhone: false),
                  child: const Text('번호 변경', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: (busy || resendBlockSec > 0) ? null : _requestCode,
              child: Text(
                resendBlockSec > 0
                    ? '재요청 대기 (${resendBlockSec}s)'
                    : (requested ? '인증번호 재요청' : '인증번호 요청'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),

          if (requested) ...[
            const SizedBox(height: 16),
            TextField(
              controller: codeCtrl,
              enabled: !busy && remainSec > 0,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '인증번호',
                hintText: '6자리 입력',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: remainSec > 0
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Center(
                          widthFactor: 1,
                          child: Text(_mmss,
                              style: const TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (busy || remainSec == 0) ? null : _confirmAndLogin,
                child: busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('로그인', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
            if (remainSec == 0)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '인증 시간이 만료되었습니다. 다시 요청해주세요.',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
                ),
              ),
          ],

          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}
