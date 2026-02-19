import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'prayer_models.dart';
import 'prayer_write_page.dart';
import 'widgets/privacy_chip.dart';

/// ✅ 임시(더미) 개인 기도제목 저장소
/// 나중에 Riverpod/DB/API로 교체할 대상
class MyPrayerStore {
  static final List<MyPrayerItem> items = [
    MyPrayerItem(
      id: 'm1',
      date: DateTime(2026, 1, 21),
      title: '가족 건강을 위해',
      content: '부모님 건강과 마음의 평안을 위해 기도합니다.',
      isPublic: false,
    ),
    MyPrayerItem(
      id: 'm2',
      date: DateTime(2026, 1, 18),
      title: '직장/진로 인도하심',
      content: '새 프로젝트가 잘 진행되고 지혜가 있도록 기도합니다.',
      isPublic: true,
    ),
  ];

  static MyPrayerItem? find(String id) {
    try {
      return items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  static void update(MyPrayerItem updated) {
    final idx = items.indexWhere((e) => e.id == updated.id);
    if (idx >= 0) items[idx] = updated;
  }

  static void remove(String id) {
    items.removeWhere((e) => e.id == id);
  }
}

class MyPrayerDetailPage extends StatefulWidget {
  final String id;

  const MyPrayerDetailPage({super.key, required this.id});

  @override
  State<MyPrayerDetailPage> createState() => _MyPrayerDetailPageState();
}

class _MyPrayerDetailPageState extends State<MyPrayerDetailPage> {
  MyPrayerItem? item;


  @override
  void initState() {
    super.initState();
    item = MyPrayerStore.find(widget.id);
  }

  Future<void> _edit() async {
    if (item == null) return;

    final edited = await Navigator.of(context).push<MyPrayerItem>(
      MaterialPageRoute(
        builder: (_) => PrayerWritePage(initial: item),
      ),
    );

    if (!mounted) return;
    if (edited != null) {
      MyPrayerStore.update(edited);
      setState(() => item = edited);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수정 완료')),
      );
    }
  }

  Future<void> _delete() async {
    if (item == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제하시겠습니까?'),
        content: const Text('삭제하면 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );

    if (!mounted) return;
    if (ok == true) {
      MyPrayerStore.remove(widget.id);
      context.pop(); // 상세 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제 완료')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final x = item;
    if (x == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('기도제목')),
        body: const Center(child: Text('항목을 찾을 수 없습니다.')),
      );
    }

    final st = privacyStyle(x.isPublic);

    return Scaffold(
      appBar: AppBar(
        title: const Text('기도제목'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: '수정',
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: '삭제',
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black.withOpacity(0.45)),
              const SizedBox(width: 8),
              Text(
                formatYmd(x.date),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.65),
                ),
              ),
              const SizedBox(width: 10),
              PrivacyChip(isPublic: x.isPublic, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            x.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.08)),
            ),
            child: Text(
              x.content,
              style: const TextStyle(fontSize: 14.5, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),

          // ✅ 공개/비공개 안내 문구도 상세에서 명확히
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: st.bg.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: st.fg.withOpacity(0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(st.icon, color: st.fg),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    x.isPublic
                        ? '이 기도제목은 “공개” 상태입니다.\n(구역/본인만 열람 가능)'
                        : '이 기도제목은 “비공개” 상태입니다.\n(구역원에게 공유되지 않습니다)',
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
      ),
    );
  }
}

class _PrivacyChip extends StatelessWidget {
  final _PrivacyBadgeStyle style;
  const _PrivacyChip({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.fg.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.fg),
          const SizedBox(width: 6),
          Text(
            style.text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: style.fg,
            ),
          ),
        ],
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

_PrivacyBadgeStyle privacyStyle(bool isPublic) {
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