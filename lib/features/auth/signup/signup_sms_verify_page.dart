import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/http/app_dio.dart';

class SignupSmsVerifyPage extends StatefulWidget {
  final bool agreedApp;
  final bool agreedPrivacy;
  final bool agreedAlarm;

  const SignupSmsVerifyPage({
    super.key,
    required this.agreedApp,
    required this.agreedPrivacy,
    required this.agreedAlarm,
  });

  @override
  State<SignupSmsVerifyPage> createState() => _SignupSmsVerifyPageState();
}

class _SignupSmsVerifyPageState extends State<SignupSmsVerifyPage> {
  final phoneCtrl = TextEditingController();
  final codeCtrl = TextEditingController();

  final Dio dio = AppDio.instance;

  bool agreeForVerify = false;
  bool requested = false;
  bool busy = false;

  String? verificationId;
  int remainSec = 0;

  // ✅ 재요청 쿨다운(429) 처리
  int resendBlockSec = 0;

  Timer? _timer;
  Timer? _resendTimer;

  String? error;

  // ✅ “요청했던 번호”를 기억해두고, 사용자가 수정하면 안내/초기화
  String _requestedPhoneDigits = "";

  @override
  void initState() {
    super.initState();

    // 사용자가 번호를 수정하면, 기존 요청과 불일치 여부를 감지
    phoneCtrl.addListener(() {
      if (!requested) return;
      final current = phoneDigits;
      if (current != _requestedPhoneDigits) {
        // 번호가 바뀌면, 현재 인증요청 상태를 유지해도 혼란이 생기므로
        // UX상 "번호가 변경되었습니다. 다시 요청해주세요." 안내를 띄우되
        // 사용자가 버튼으로 초기화할 수 있도록 둡니다.
        if (mounted) {
          setState(() {
            // 에러가 너무 시끄럽지 않게, 기존 에러가 없을 때만 안내
            error ??= '휴대폰 번호가 변경되었습니다. 변경된 번호로 인증번호를 다시 요청해주세요.';
          });
        }
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

  void _startTimer(int ttlSec) {
    _timer?.cancel();
    setState(() => remainSec = ttlSec);

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

  void _resetVerificationState({bool clearPhone = false}) {
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
      _requestedPhoneDigits = "";

      error = null;
    });
  }

  String _dioErrorMessage(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      if (data is Map) {
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) return msg;

        final retry = data['retryAfterSec'];
        if (status == 429 && retry is num) {
          return '요청이 너무 많습니다. ${retry.toInt()}초 후 다시 시도해주세요.';
        }
      }

      if (status == 429) return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
      if (status == 400) return '요청이 올바르지 않습니다. 입력값을 확인해주세요.';
      if (status != null) return '서버 오류가 발생했습니다. (HTTP $status)';

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return '네트워크가 불안정합니다. 잠시 후 다시 시도해주세요.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return '서버에 연결할 수 없습니다. 서버 주소/네트워크를 확인해주세요.';
      }
      return '요청 중 오류가 발생했습니다.';
    }
    return '오류가 발생했습니다. ($e)';
  }

  Future<void> _requestCode() async {
    FocusScope.of(context).unfocus();

    if (!agreeForVerify) {
      setState(() => error = '문자인증을 위한 개인정보 동의가 필요합니다.');
      return;
    }
    if (phoneDigits.length < 10) {
      setState(() => error = '휴대폰 번호를 정확히 입력해주세요.');
      return;
    }

    // ✅ 쿨다운 중이면 즉시 안내
    if (resendBlockSec > 0) {
      setState(() => error = '재요청 대기 중입니다. $resendBlockSec초 후 다시 시도해주세요.');
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    try {
      final res = await dio.post('/auth/sms/request', data: {
        'phone': phoneDigits,
      });

      final data = (res.data is Map)
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};

      final vid = data['verificationId'] as String?;
      final ttl = (data['ttlSec'] as num?)?.toInt() ?? 180;

      if (vid == null || vid.isEmpty) {
        throw Exception('verificationId missing');
      }

      verificationId = vid;

      setState(() {
        requested = true;
        busy = false;
      });

      // ✅ 요청했던 번호 기록
      _requestedPhoneDigits = phoneDigits;

      _startTimer(ttl);
    } catch (e) {
      // ✅ 429(Too Many Requests): 실패가 아니라 “대기 안내 + 버튼 잠금”
      if (e is DioException && e.response?.statusCode == 429) {
        final data = e.response?.data;
        int retrySec = 0;
        String msg = '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';

        if (data is Map) {
          final m = data['message'];
          final r = data['retryAfterSec'];
          if (m is String && m.isNotEmpty) msg = m;
          if (r is num) retrySec = r.toInt();
        }

        if (retrySec > 0) _startResendCooldown(retrySec);

        setState(() {
          busy = false;
          error = retrySec > 0 ? '$msg ($retrySec초 후 재요청 가능)' : msg;
        });
        return;
      }

      setState(() {
        busy = false;
        error = '인증번호 요청 실패: ${_dioErrorMessage(e)}';
      });
    }
  }

  Future<void> _confirmCode() async {
    FocusScope.of(context).unfocus();

    // ✅ 번호가 바뀌었으면, 기존 인증요청으로 확인 불가 처리
    if (requested && _requestedPhoneDigits.isNotEmpty && phoneDigits != _requestedPhoneDigits) {
      setState(() => error = '휴대폰 번호가 변경되었습니다. 변경된 번호로 인증번호를 다시 요청해주세요.');
      return;
    }

    final vid = verificationId;
    final code = codeCtrl.text.trim();

    if (vid == null || vid.isEmpty) {
      setState(() => error = '인증번호를 먼저 요청해주세요.');
      return;
    }
    if (remainSec == 0) {
      setState(() => error = '인증 시간이 만료되었습니다. 인증번호를 다시 요청해주세요.');
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
      final res = await dio.post('/auth/sms/confirm', data: {
        'verificationId': vid,
        'code': code,
      });

      final data = (res.data is Map)
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};

      final verifiedPhone = (data['verifiedPhone'] as String?) ?? phoneDigits;
      final verifiedToken = data['verifiedToken'] as String?;

      setState(() => busy = false);

      if (!mounted) return;
      context.push('/signup/info', extra: {
        'verifiedPhone': verifiedPhone,
        'verifiedToken': verifiedToken,
        'agreedApp': widget.agreedApp,
        'agreedPrivacy': widget.agreedPrivacy,
        'agreedAlarm': widget.agreedAlarm,
      });
    } catch (e) {
      setState(() {
        busy = false;
        error = '인증 실패: ${_dioErrorMessage(e)}';
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

    // ✅ 이제 번호는 “요청 후에도 수정 가능”이므로 잠금 제거
    final phoneLocked = false;

    final requestBtnDisabled = busy || resendBlockSec > 0;

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
            '회원가입을 위해서\n휴대폰 인증이 필요합니다.',
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

          // ✅ 휴대폰 입력 + “번호 변경” 버튼(요청 후)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: phoneCtrl,
                  enabled: !phoneLocked && !busy,
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
                  onPressed: busy
                      ? null
                      : () {
                    // 번호를 바꿔 재인증하려는 의도이므로 상태 초기화만 해줌
                    _resetVerificationState(clearPhone: false);
                  },
                  child: const Text('번호 변경', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // 요청 버튼
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: requestBtnDisabled ? null : _requestCode,
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
                    child: Text(_mmss, style: const TextStyle(fontWeight: FontWeight.w900)),
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
                onPressed: (busy || remainSec == 0) ? null : _confirmCode,
                child: const Text('인증 확인', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
            if (remainSec == 0)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '인증 시간이 만료되었습니다. 인증번호를 다시 요청해주세요.',
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