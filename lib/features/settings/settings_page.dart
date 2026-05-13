import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'presentation/pages/notification_settings_page.dart';
import 'settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          // 1) 폰트 크기
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('폰트 크기', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PresetChip(
                        label: '작게',
                        active: _near(s.fontScale, 0.90),
                        onTap: () => ref.read(appSettingsProvider.notifier).setFontScale(0.90),
                      ),
                      _PresetChip(
                        label: '기본',
                        active: _near(s.fontScale, 1.00),
                        onTap: () => ref.read(appSettingsProvider.notifier).setFontScale(1.00),
                      ),
                      _PresetChip(
                        label: '크게',
                        active: _near(s.fontScale, 1.15),
                        onTap: () => ref.read(appSettingsProvider.notifier).setFontScale(1.15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('작게', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      Expanded(
                        child: Slider(
                          min: 0.85,
                          max: 1.25,
                          divisions: 8,
                          value: s.fontScale,
                          onChanged: (v) => ref.read(appSettingsProvider.notifier).setFontScale(v),
                        ),
                      ),
                      const Text('크게', style: TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                  Text(
                    '현재: ${(s.fontScale * 100).round()}%',
                    style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2) 알림 설정 — 카테고리별 토글 페이지로 진입
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('알림 설정',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('예배·공지 카테고리별 알림 ON/OFF'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationSettingsPage()),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 3) 앱정보 (✅ 설정에 유지)
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('앱 정보/버전', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('버전/빌드 정보 확인'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const _AppInfoDialog(),
                );
              },
            ),
          ),

          // ✅ (삭제) 개인정보처리방침은 My로 이동
        ],
      ),
    );
  }
}

class _AppInfoDialog extends StatelessWidget {
  const _AppInfoDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('앱 정보'),
      content: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const SizedBox(
              width: 200,
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final info = snap.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('이룸교회',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 12),
              _InfoRow(label: '버전', value: info.version),
              _InfoRow(label: '빌드', value: info.buildNumber),
              _InfoRow(label: '패키지', value: info.packageName),
            ],
          );
        },
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('확인')),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(label,
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

bool _near(double a, double b) => (a - b).abs() < 0.03;

class _PresetChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.blue.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12.5,
            color: active ? Colors.blue : Colors.black87,
          ),
        ),
      ),
    );
  }
}