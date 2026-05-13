import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_provider.dart';
import '../settings/presentation/pages/notification_settings_page.dart';
import 'privacy_policy_page.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('마이페이지')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.push('/login'),
            child: const Text('로그인 하러가기'),
          ),
        ),
      );
    }

    final isPending = auth.isPending; // ✅ 교적 미매칭 → 준회원

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: '뒤로',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            child: const Text('로그아웃'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          // ✅ 프로필 카드
          _ProfileCard(
            name: auth.name ?? '-',
            position: auth.registry?.position,
            isDistrictLeader: auth.isDistrictLeader,
            isPending: isPending,
          ),

          const SizedBox(height: 12),

          // ✅ 내 정보
          const _SectionTitle('내 정보'),
          const SizedBox(height: 8),

          _InfoTile(title: '이름', value: auth.name ?? '-'),
          _InfoTile(title: '아이디', value: auth.userId ?? '-'),
          _InfoTile(title: '휴대폰', value: _fmtPhone(auth.phone)),
          _InfoTile(title: '주소', value: auth.address ?? '-'),

          const SizedBox(height: 12),

          // ✅ 교적 정보(성도만)
          const _SectionTitle('교적 정보'),
          const SizedBox(height: 8),

          if (isPending) ...[
            const _InfoNoticeCard(
              text: '교인등록 필요',
              icon: Icons.info_outline,
            ),
          ] else ...[
            _InfoTile(title: '직분', value: auth.registry?.position ?? '-'),
            _InfoTile(title: '교구', value: auth.registry?.parish ?? '-'),
            _InfoTile(title: '구역', value: auth.registry?.district ?? '-'),
            if (auth.isDistrictLeader)
              const _InfoNoticeCard(
                text: '구역장',
                icon: Icons.verified,
              ),
          ],

          const SizedBox(height: 14),

          // ✅ 아래 섹션들
          const _SectionTitle('설정/기타'),
          const SizedBox(height: 8),

          _SingleLinkSection(
            title: '알림 설정',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const NotificationSettingsPage()),
            ),
          ),
          _SingleLinkSection(
            title: '폰트 크기 / 앱 정보',
            onTap: () => context.push('/settings'),
          ),
          _SingleLinkSection(
            title: '개인정보처리방침',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              );
            },
          ),

          const SizedBox(height: 12),

          // ✅ 회원탈퇴 — 설정/기타 맨 하단
          Card(
            child: ListTile(
              title: const Text(
                '회원 탈퇴',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red),
              ),
              subtitle: const Text(
                '탈퇴 시 계정 정보가 삭제됩니다.',
                style: TextStyle(color: Colors.black54),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('회원 탈퇴'),
                    content: const Text(
                      '정말 탈퇴하시겠습니까?\n탈퇴 시 복구가 어렵습니다.',
                      style: TextStyle(height: 1.35),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('탈퇴', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                );

                if (ok != true) return;

                try {
                  await ref.read(authProvider.notifier).withdraw();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('회원 탈퇴가 완료되었습니다.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('탈퇴 처리 중 오류가 발생했습니다: $e')),
                    );
                  }
                }
              },
            ),
          ),

        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String? position; // 직분 (집사 / 권사 / 목사 / 성도 등)
  final bool isDistrictLeader;
  final bool isPending;

  const _ProfileCard({
    required this.name,
    required this.position,
    required this.isDistrictLeader,
    required this.isPending,
  });

  /// 호칭 — 직분이 있으면 '{position}님', 없으면 '성도님' 기본
  String get _displayName {
    if (isPending) return name;
    final p = (position ?? '').trim();
    final suffix = p.isNotEmpty ? '$p님' : '성도님';
    return '$name $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person_outline,
                  color: Colors.blue, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _displayName,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 직책(구역장 등)만 뱃지 — 일반 성도/집사 등은 뱃지 X
                      if (isDistrictLeader && !isPending) ...[
                        const SizedBox(width: 8),
                        const _Chip(
                            text: '구역장',
                            tone: _Tone.green,
                            icon: Icons.verified),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 교적 인증 완료 강조 (아이콘 + 진한 색)
                  Row(
                    children: [
                      Icon(
                        isPending
                            ? Icons.error_outline
                            : Icons.check_circle_rounded,
                        size: 18,
                        color: isPending
                            ? const Color(0xFFEA580C)
                            : const Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPending ? '교적 DB 매칭이 필요합니다' : '교적 인증 완료',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isPending
                              ? const Color(0xFFEA580C)
                              : const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(title, style: const TextStyle(color: Colors.black54)),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoNoticeCard extends StatelessWidget {
  final String text;
  final IconData icon;
  const _InfoNoticeCard({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Tone { blue, green, gray }

class _Chip extends StatelessWidget {
  final String text;
  final _Tone tone;
  final IconData? icon;

  const _Chip({
    required this.text,
    required this.tone,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;

    switch (tone) {
      case _Tone.blue:
        bg = Colors.blue.withValues(alpha: 0.10);
        fg = Colors.blue;
        break;
      case _Tone.green:
        bg = Colors.green.withValues(alpha: 0.12);
        fg = Colors.green;
        break;
      case _Tone.gray:
        bg = Colors.black.withValues(alpha: 0.06);
        fg = Colors.black54;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: fg),
          ),
        ],
      ),
    );
  }
}

String _fmtPhone(String? raw) {
  if (raw == null) return '-';
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 11) {
    return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
  }
  if (digits.length == 10) {
    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
  }
  return raw;
}

class _SingleLinkSection extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SingleLinkSection({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
