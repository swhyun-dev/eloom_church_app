import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_provider.dart';
import 'models/notification_models.dart';
import 'state/notification_provider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  static const _line = Color(0xFFE5E7EB);
  static const _muted = Color(0xFF9CA3AF);

  String _fmt(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y/$m/$d $hh:$mm';
  }

  void _openTarget(BuildContext context, WidgetRef ref, NoticeItem x) {
    final auth = ref.read(authProvider);

    if (x.requiresLogin && !auth.isLoggedIn) {
      final from = Uri.encodeComponent(x.route);
      context.push('/login?from=$from');
      return;
    }

    context.push(x.route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: '홈',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/'),
          ),
          IconButton(
            tooltip: '설정',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: 설정 페이지 연결
              context.push('/settings');
            },
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _line),
        ),
      ),
      body: items.isEmpty
          ? const Center(
        child: Text('알림 내역이 없습니다.',
            style: TextStyle(fontWeight: FontWeight.w700)),
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1, color: _line),
        itemBuilder: (context, i) {
          final x = items[i];

          return InkWell(
            onTap: () => _openTarget(context, ref, x),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 좌측 타입 / 우측 시간
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          x.type.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        _fmt(x.createdAt),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    x.message,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
