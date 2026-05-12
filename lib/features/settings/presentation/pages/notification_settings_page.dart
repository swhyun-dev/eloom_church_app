import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/notification_settings.dart';
import '../../domain/models/notification_topic.dart';
import '../providers/notification_settings_providers.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationSettingsProvider);

    Future<void> toggle(NotificationTopic topic, bool value) async {
      final action = ref.read(toggleNotificationTopicProvider);
      try {
        await action(topic, value);
        ref.invalidate(notificationSettingsProvider);
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정 저장에 실패했습니다.')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('알림 설정')),
      body: AsyncValueBuilder<NotificationSettings>(
        value: async,
        onRetry: () => ref.invalidate(notificationSettingsProvider),
        builder: (settings) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            const _SectionTitle('예배 알림', subtitle: '예배 시작 5분 전 자동 알림'),
            Card(
              child: Column(
                children: [
                  for (final t in NotificationTopicGroups.worship)
                    SwitchListTile(
                      title: Text(t.label,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      value: settings.isOn(t),
                      onChanged: (v) => toggle(t, v),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _SectionTitle('공지 알림', subtitle: '카테고리별 공지 푸시'),
            Card(
              child: Column(
                children: [
                  for (final t in NotificationTopicGroups.board)
                    SwitchListTile(
                      title: Text(t.label,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      value: settings.isOn(t),
                      onChanged: (v) => toggle(t, v),
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
  final String title;
  final String subtitle;
  const _SectionTitle(this.title, {required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }
}
