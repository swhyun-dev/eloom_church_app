import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/async_value_builder.dart';
import '../../state/auth_provider.dart';
import 'domain/models/app_notification.dart';
import 'presentation/providers/notification_providers.dart';

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

  Future<void> _openTarget(
      BuildContext context, WidgetRef ref, AppNotification x) async {
    // 클릭 시 비동기로 읽음 처리 (응답 기다리지 않음).
    if (!x.isRead) {
      // ignore: discarded_futures
      ref.read(markNotificationReadProvider)(x.id).then((_) {
        ref.invalidate(inboxProvider);
      }).catchError((_) {});
    }

    final route = x.route;
    if (route == null || route.isEmpty) return;

    final auth = ref.read(authProvider);
    if (x.kind.requiresLogin && !auth.isLoggedIn) {
      final from = Uri.encodeComponent(route);
      if (!context.mounted) return;
      context.push('/login?from=$from');
      return;
    }
    if (!context.mounted) return;
    context.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inboxProvider);

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
            tooltip: '모두 읽음',
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () async {
              final markAll = ref.read(markAllNotificationsReadProvider);
              try {
                await markAll();
                ref.invalidate(inboxProvider);
              } catch (_) {}
            },
          ),
          IconButton(
            tooltip: '홈',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/'),
          ),
          IconButton(
            tooltip: '설정',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _line),
        ),
      ),
      body: AsyncValueBuilder(
        value: async,
        onRetry: () => ref.invalidate(inboxProvider),
        isEmpty: (n) => n.items.isEmpty,
        emptyMessage: '알림 내역이 없습니다.',
        builder: (NotificationList notifList) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
          itemCount: notifList.items.length,
          separatorBuilder: (_, _) =>
              const Divider(height: 1, color: _line),
          itemBuilder: (context, i) {
            final x = notifList.items[i];
            return Dismissible(
              key: ValueKey(x.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red.shade400,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) async {
                try {
                  await ref.read(deleteNotificationProvider)(x.id);
                  ref.invalidate(inboxProvider);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('삭제에 실패했습니다.')),
                  );
                }
              },
              child: InkWell(
                onTap: () => _openTarget(context, ref, x),
                child: Container(
                  color: x.isRead ? null : const Color(0xFFF1F7FF),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!x.isRead) ...[
                            const _UnreadDot(),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              x.kind.label,
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
                        x.title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.25,
                        ),
                      ),
                      if (x.body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          x.body,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF1F7AAE),
        shape: BoxShape.circle,
      ),
    );
  }
}
