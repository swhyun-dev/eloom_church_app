import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

          // 2) 알림 설정(푸쉬)
          Card(
            child: SwitchListTile(
              value: s.pushEnabled,
              onChanged: (v) => ref.read(appSettingsProvider.notifier).setPushEnabled(v),
              title: const Text('푸쉬 알림', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('예배/공지/교육일정 알림을 받습니다. (더미)'),
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
      content: const Text(
        '이룸교회 앱\n'
            'Version: 0.1.0 (dummy)\n'
            'Build: 1 (dummy)\n\n'
            '※ 추후 실제 버전 정보로 연동됩니다.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
      ],
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
          color: active ? Colors.blue.withOpacity(0.12) : Colors.black.withOpacity(0.04),
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