import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'prayer_models.dart';
import 'widgets/privacy_chip.dart';
import '../../services/prayer_service.dart';
import '../../state/auth_provider.dart';

class MyPrayerDetailPage extends ConsumerStatefulWidget {
  final String id;

  const MyPrayerDetailPage({super.key, required this.id});

  @override
  ConsumerState<MyPrayerDetailPage> createState() => _MyPrayerDetailPageState();
}

class _MyPrayerDetailPageState extends ConsumerState<MyPrayerDetailPage> {
  late final Future<PrayerData?> _future;

  @override
  void initState() {
    super.initState();
    final token = ref.read(authProvider).token;
    final intId = int.tryParse(widget.id) ?? -1;
    _future = PrayerService(token: token).fetchMine().then(
          (list) {
            try {
              return list.firstWhere((p) => p.id == intId);
            } catch (_) {
              return null;
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기도제목'),
        centerTitle: true,
      ),
      body: FutureBuilder<PrayerData?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('오류: ${snap.error}'));
          }
          final d = snap.data;
          if (d == null) {
            return Scaffold(
              body: const Center(child: Text('항목을 찾을 수 없습니다.')),
            );
          }

          final st = _privacyStyle(d.isPublic);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black.withValues(alpha: 0.45)),
                  const SizedBox(width: 8),
                  Text(
                    formatYmd(d.createdAt),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PrivacyChip(isPublic: d.isPublic, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                d.title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                ),
                child: Text(
                  d.content,
                  style: const TextStyle(fontSize: 14.5, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: st.bg.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: st.fg.withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(st.icon, color: st.fg),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        d.isPublic
                            ? '이 기도제목은 "공개" 상태입니다.\n(구역/본인만 열람 가능)'
                            : '이 기도제목은 "비공개" 상태입니다.\n(구역원에게 공유되지 않습니다)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: st.fg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('목록보기'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PrivacyBadgeStyle {
  final String text;
  final IconData icon;
  final Color bg;
  final Color fg;

  const _PrivacyBadgeStyle({
    required this.text,
    required this.icon,
    required this.bg,
    required this.fg,
  });
}

_PrivacyBadgeStyle _privacyStyle(bool isPublic) {
  if (isPublic) {
    return const _PrivacyBadgeStyle(
      text: '공개',
      icon: Icons.public,
      bg: Color(0xFFE8F5E9),
      fg: Color(0xFF2E7D32),
    );
  }
  return const _PrivacyBadgeStyle(
    text: '비공개',
    icon: Icons.lock_outline,
    bg: Color(0xFFFFEBEE),
    fg: Color(0xFFC62828),
  );
}
