import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/async_value_builder.dart';
import 'domain/models/ministry_application.dart';
import 'domain/models/ministry_dept.dart';
import 'domain/models/ministry_status.dart';
import 'presentation/providers/ministry_providers.dart';

class MinistryPage extends ConsumerStatefulWidget {
  final int initialTab; // 0=신청, 1=내역
  const MinistryPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<MinistryPage> createState() => _MinistryPageState();
}

class _MinistryPageState extends ConsumerState<MinistryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  static const Color _primary = Color(0xFF0B4FA8);
  static const Color _line = Color(0xFFE5E7EB);
  static const Color _muted = Color(0xFF6B7280);

  // 부서별 세부 역할 (Flutter UI 의도 유지 — 백엔드로는 motivation으로 전송)
  final Map<MinistryDept, List<String>> roles = const {
    MinistryDept.worship: ['예배 안내', '새가족 안내'],
    MinistryDept.praise: [
      '호산나성가대(2부예배)',
      '찬양팀(1부예배)',
      '찬양팀(2부예배)',
      '찬양팀(저녁예배)',
      '찬양팀(수요예배)',
    ],
    MinistryDept.vehicle: ['주차 안내 및 차량 통제', '셔틀버스 운행'],
    MinistryDept.media: ['방송실(PPT)', '교회행사홍보 디자인팀'],
    MinistryDept.education: [
      '주일학교교사/보조교사(영유아부)',
      '주일학교교사/보조교사(유초등부)',
      '주일학교교사/보조교사(중고등부)',
    ],
    MinistryDept.service: ['식당봉사', '카페봉사'],
    MinistryDept.evangelism: ['주간전도팀'],
  };

  MinistryDept? selectedDept;
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(myMinistryApplicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('사역신청'),
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
        bottom: TabBar(
          controller: _tab,
          labelColor: _primary,
          unselectedLabelColor: Colors.black54,
          indicatorColor: _primary,
          indicatorWeight: 2.2,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900),
          tabs: const [
            Tab(text: '사역 신청 하기'),
            Tab(text: '나의 신청 내역'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ApplyTab(
            roles: roles,
            selectedDept: selectedDept,
            selectedRole: selectedRole,
            // 같은 항목 재탭 시 해제(deselect), 다른 항목 탭 시 그쪽으로 단일 선택
            onSelect: (dept, role) => setState(() {
              if (selectedDept == dept && selectedRole == role) {
                selectedDept = null;
                selectedRole = null;
              } else {
                selectedDept = dept;
                selectedRole = role;
              }
            }),
            onSubmit: () => _openConfirm(context),
          ),
          AsyncValueBuilder<List<MinistryApplication>>(
            value: asyncList,
            onRetry: () => ref.invalidate(myMinistryApplicationsProvider),
            isEmpty: (l) => l.isEmpty,
            emptyMessage: '신청 내역이 없습니다.',
            builder: (items) => _HistoryTab(items: items),
          ),
        ],
      ),
    );
  }

  void _openConfirm(BuildContext pageCtx) {
    if (selectedDept == null || selectedRole == null) {
      ScaffoldMessenger.of(pageCtx).showSnackBar(
        const SnackBar(content: Text('신청할 사역을 선택해 주세요.')),
      );
      return;
    }

    final deptLabel = selectedDept!.label;
    final roleLabel = selectedRole!;

    showModalBottomSheet(
      context: pageCtx,
      useSafeArea: true,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => sheetCtx.pop(),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                '사역을 신청하시겠습니까?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const Text(
                '신청내역',
                style: TextStyle(
                  fontSize: 12.5,
                  color: _muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$deptLabel - $roleLabel',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15.5),
                  ),
                  onPressed: () async {
                    final submit = ref.read(submitMinistryProvider);
                    sheetCtx.pop();
                    try {
                      await submit(
                        department: selectedDept!,
                        motivation: roleLabel,
                      );
                      ref.invalidate(myMinistryApplicationsProvider);
                      if (!mounted) return;
                      _openComplete(
                          deptLabel: deptLabel, roleLabel: roleLabel);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('신청에 실패했습니다: $e')),
                      );
                    }
                  },
                  child: const Text('신청하기'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: _line),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15.5),
                  ),
                  onPressed: () => sheetCtx.pop(),
                  child: const Text('취소하기'),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  void _openComplete({
    required String deptLabel,
    required String roleLabel,
  }) {
    final now = DateTime.now();
    final dateStr = '${now.year}년 ${now.month}월 ${now.day}일';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ministry_complete',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, _, _) {
        return Material(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () {
                      ctx.pop();
                      _tab.animateTo(1);
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 30),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          '사역 신청이 완료되었습니다!',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          '신청내역',
                          style: TextStyle(
                            fontSize: 13,
                            color: _muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$deptLabel - $roleLabel',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '신청일 : $dateStr',
                          style: const TextStyle(
                            fontSize: 13,
                            color: _muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _line),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoBullet(
                                  text: '담당자 확인 후, 안내 연락을 드리겠습니다.'),
                              SizedBox(height: 6),
                              _InfoBullet(
                                  text: '부서 상황에 따라 신청한 사역이 불가할 수 있습니다.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _line),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      onPressed: () {
                        ctx.pop();
                        _tab.animateTo(1);
                      },
                      child: const Text('닫기'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final String text;
  const _InfoBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color: _MinistryPageState._primary)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _MinistryPageState._primary,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _ApplyTab extends StatelessWidget {
  static const Color _primary = Color(0xFF0B4FA8);

  final Map<MinistryDept, List<String>> roles;
  final MinistryDept? selectedDept;
  final String? selectedRole;
  final void Function(MinistryDept dept, String role) onSelect;
  final VoidCallback onSubmit;

  const _ApplyTab({
    required this.roles,
    required this.selectedDept,
    required this.selectedRole,
    required this.onSelect,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      children: [
        for (final entry in roles.entries) ...[
          _DeptCard(
            title: entry.key.label,
            items: entry.value,
            selected: (role) =>
                selectedDept == entry.key && selectedRole == role,
            onTap: (role) => onSelect(entry.key, role),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 2),
        const Text(
          '• 한번 신청에 두개 이상 선택은 불가합니다.\n• 부서 상황에 따라 신청한 사역이 불가할 수 있습니다.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black45,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            onPressed: onSubmit,
            child: const Text('신청하기'),
          ),
        ),
      ],
    );
  }
}

class _DeptCard extends StatelessWidget {
  static const Color _line = Color(0xFFE5E7EB);

  final String title;
  final List<String> items;
  final bool Function(String role) selected;
  final void Function(String role) onTap;

  const _DeptCard({
    required this.title,
    required this.items,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
          const SizedBox(height: 8),
          for (final role in items) ...[
            InkWell(
              onTap: () => onTap(role),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        role,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.95,
                      child: Checkbox(
                        value: selected(role),
                        onChanged: (_) => onTap(role),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (role != items.last)
              const Divider(height: 1, color: _line),
          ],
        ],
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  static const Color _line = Color(0xFFE5E7EB);
  static const Color _primary = Color(0xFF0B4FA8);

  final List<MinistryApplication> items;
  const _HistoryTab({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final x = items[i];
        final date =
            '${x.createdAt.year}/${x.createdAt.month.toString().padLeft(2, '0')}/${x.createdAt.day.toString().padLeft(2, '0')}';

        final btn = switch (x.status) {
          MinistryStatus.pending => OutlinedButton(
              onPressed: () async {
                final cancel = ref.read(cancelMinistryProvider);
                try {
                  await cancel(x.id);
                  ref.invalidate(myMinistryApplicationsProvider);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('취소에 실패했습니다: $e')),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _line),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
              ),
              child: const Text('취소하기'),
            ),
          MinistryStatus.approved => ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
              ),
              child: const Text('승인'),
            ),
          MinistryStatus.rejected => ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black26,
                foregroundColor: Colors.white,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
              ),
              child: const Text('반려'),
            ),
          MinistryStatus.canceled => OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _line),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
              ),
              child: const Text('취소됨'),
            ),
        };

        return Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${x.department.label}-${x.motivation}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36, child: btn),
            ],
          ),
        );
      },
    );
  }
}
