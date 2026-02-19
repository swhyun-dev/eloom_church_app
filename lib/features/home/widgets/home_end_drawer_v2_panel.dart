import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../state/auth_provider.dart';
import '../../sermon/widget/sermon_select_sheet.dart';
import '../../../config/links.dart';

class HomeEndDrawerV2Panel extends ConsumerStatefulWidget {
  const HomeEndDrawerV2Panel({super.key});

  @override
  ConsumerState<HomeEndDrawerV2Panel> createState() => _HomeEndDrawerV2PanelState();
}

class _HomeEndDrawerV2PanelState extends ConsumerState<HomeEndDrawerV2Panel> {
  _TopKey selected = _TopKey.sermon;

  // 톤 조절(원하면 바꾸세요)
  static const Color _leftBg = Color(0xFFEAF5FA);
  static const Color _active = Color(0xFF48B04A);

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ───────── 헤더 ─────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '이룸교회',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(auth.isLoggedIn ? '/my' : '/login');
                    },
                    child: Text(auth.isLoggedIn ? 'My' : '로그인'),
                  ),
                  IconButton(
                    tooltip: '설정',
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  auth.isLoggedIn ? '${auth.name} 성도님 환영합니다' : '로그인 후 이용 가능합니다',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ),
            const Divider(height: 1),

            // ───────── 2단 패널 ─────────
            Expanded(
              child: Row(
                children: [
                  // 좌측: 상위 메뉴
                  Container(
                    width: 130,
                    color: _leftBg,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        _TopItem(
                          label: '설교',
                          active: selected == _TopKey.sermon,
                          activeColor: _active,
                          onTap: () => setState(() => selected = _TopKey.sermon),
                        ),
                        _TopItem(
                          label: '교회주보',
                          active: selected == _TopKey.bulletin,
                          activeColor: _active,
                          onTap: () => setState(() => selected = _TopKey.bulletin),
                        ),
                        _TopItem(
                          label: '성경읽기',
                          active: selected == _TopKey.bible,
                          activeColor: _active,
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/bible');
                          },
                        ),
                        _TopItem(
                          label: '기도제목',
                          active: selected == _TopKey.prayer,
                          activeColor: _active,
                          onTap: () => setState(() => selected = _TopKey.prayer),
                        ),
                        _TopItem(
                          label: '온라인헌금',
                          active: selected == _TopKey.offering,
                          activeColor: _active,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/offering');
                          },
                        ),
                        const SizedBox(height: 6),
                        const Divider(height: 1),

                        _TopItem(
                          label: '교회카페',
                          active: selected == _TopKey.cafe,
                          activeColor: _active,
                          onTap: () => _guardOrGo(
                            context,
                            auth.isLoggedIn,
                            requireLogin: true,
                            onAllowed: () => context.go('/cafe'),
                          ),
                        ),
                        _TopItem(
                          label: '구역모임',
                          active: selected == _TopKey.cell,
                          activeColor: _active,
                          onTap: () => _guardOrGo(
                            context,
                            auth.isLoggedIn,
                            requireLogin: true,
                            onAllowed: () => context.go('/cell'),
                          ),
                        ),
                        _TopItem(
                          label: '홈페이지',
                          active: selected == _TopKey.web,
                          activeColor: _active,
                          onTap: () async {
                            Navigator.pop(context);
                            final uri = Uri.parse(AppLinks.homepage);
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          },
                        ),
                      ],
                    ),
                  ),

                  // 우측: 하위 메뉴
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                      children: [
                        _RightTitle(_titleOf(selected)),
                        const SizedBox(height: 10),
                        ..._buildRightItems(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRightItems(BuildContext context) {
    switch (selected) {
      case _TopKey.sermon:
        return [
          _RightItem(
            title: '유튜브 실시간 생방송',
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const SermonSelectSheet(),
              );
            },
          ),
          _RightItem(
            title: '실시간 Live 보기',
            onTap: () {
              Navigator.pop(context);
              context.push('/sermon/live');
            },
          ),
          _RightItem(
            title: '지난 설교 말씀',
            onTap: () {
              Navigator.pop(context);
              context.push('/sermon/board');
            },
          ),
        ];

      case _TopKey.bulletin:
        return [
          _RightItem(
            title: '주보 모아보기',
            onTap: () {
              Navigator.pop(context);
              context.go('/bulletin');
            },
          ),
          _RightItem(
            title: '이번 주 주보',
            onTap: () {
              Navigator.pop(context);
              context.go('/bulletin');
            },
          ),
        ];

      case _TopKey.prayer:
        return [
          _RightItem(
            title: '기도제목 게시판',
            onTap: () {
              Navigator.pop(context);
              context.go('/boards/prayer');
            },
          ),
        ];

    // 단일 메뉴들은 좌측에서 바로 이동하므로 안내만 표시(원하면 비워도 됨)
      case _TopKey.bible:
        return const [_HintText('좌측에서 성경읽기를 선택하면 바로 이동합니다.')];
      case _TopKey.offering:
        return const [_HintText('좌측에서 온라인헌금을 선택하면 바로 이동합니다.')];
      case _TopKey.cafe:
        return const [_HintText('좌측에서 교회카페를 선택하면 이동합니다. (로그인 필요)')];
      case _TopKey.cell:
        return const [_HintText('좌측에서 구역모임을 선택하면 이동합니다. (로그인 필요)')];
      case _TopKey.web:
        return const [_HintText('좌측에서 홈페이지를 선택하면 외부 브라우저로 열립니다.')];
    }
  }

  String _titleOf(_TopKey key) {
    switch (key) {
      case _TopKey.sermon:
        return '설교';
      case _TopKey.bulletin:
        return '교회주보';
      case _TopKey.bible:
        return '성경읽기';
      case _TopKey.prayer:
        return '기도제목';
      case _TopKey.offering:
        return '온라인헌금';
      case _TopKey.cafe:
        return '교회카페';
      case _TopKey.cell:
        return '구역모임';
      case _TopKey.web:
        return '홈페이지';
    }
  }

  /// ✅ 기존 _Item의 로그인 가드 로직과 동일한 흐름
  void _guardOrGo(
      BuildContext context,
      bool loggedIn, {
        required bool requireLogin,
        required VoidCallback onAllowed,
      }) {
    Navigator.pop(context);

    if (requireLogin && !loggedIn) {
      final loc = GoRouterState.of(context).uri.toString();
      final encoded = Uri.encodeComponent(loc);
      context.push('/login?from=$encoded');
      return;
    }
    onAllowed();
  }
}

enum _TopKey { sermon, bulletin, bible, prayer, offering, cafe, cell, web }

class _TopItem extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _TopItem({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: active ? FontWeight.w900 : FontWeight.w700,
              color: active ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _RightTitle extends StatelessWidget {
  final String title;
  const _RightTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
    );
  }
}

class _RightItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _RightItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _HintText extends StatelessWidget {
  final String text;
  const _HintText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
        ),
      ),
    );
  }
}
