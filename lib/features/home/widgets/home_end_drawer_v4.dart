import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/links.dart';
import '../../../state/auth_provider.dart';

class HomeEndDrawerV4 extends ConsumerStatefulWidget {
  const HomeEndDrawerV4({super.key});

  @override
  ConsumerState<HomeEndDrawerV4> createState() => _HomeEndDrawerV4State();
}

class _HomeEndDrawerV4State extends ConsumerState<HomeEndDrawerV4> {
  int selected = 0;

  final List<String> leftMenus = const [
    '설교',
    '교회주보',
    '성경읽기',
    '기도제목',
    '온라인헌금',
    '교회카페',
    '구역모임',
    '사역신청',
    '홈페이지',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Drawer(
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
        child: Column(
          children: [
            // ✅ 상단바: 뒤로 / 로그인 / 설정
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (!auth.isLoggedIn) context.push('/login');
                    },
                    child: Text(
                      auth.isLoggedIn ? '로그인됨' : '로그인',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),

                  // ✅ 설정 연결
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // ✅ 위에서부터
                children: [
                  // ✅ 좌측 메뉴(연한 하늘색)
                  Container(
                    width: 130,
                    color: const Color(0xFFEAF3FF),
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: leftMenus.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final isSelected = selected == i;
                        final title = leftMenus[i];

                        return InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => setState(() => selected = i),
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF39B54A) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ✅ 우측 패널: 항상 위에서 시작 + 스크롤 가능
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: ListView(
                        key: ValueKey(selected), // ✅ 좌측 변경 시 우측 상태/스크롤 초기화
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                        children: [
                          _RightPanelV4(
                            selectedIndex: selected,
                            isLoggedIn: auth.isLoggedIn,
                            onClose: () => Navigator.pop(context),
                          ),
                        ],
                      ),
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
}

/// ✅ 우측 패널: 모든 메뉴를 "아코디언 + 하위항목" 으로 통일
class _RightPanelV4 extends StatelessWidget {
  final int selectedIndex;
  final bool isLoggedIn;
  final VoidCallback onClose;

  const _RightPanelV4({
    required this.selectedIndex,
    required this.isLoggedIn,
    required this.onClose,
  });

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    switch (selectedIndex) {
      case 0: // 설교
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccordionTile(
              title: '유튜브 실시간 생방송',
              children: [
                _SubMenuItem(
                  text: '실시간 Live 보기',
                  onTap: () async {
                    onClose();
                    await _openExternal(AppLinks.sermonLiveUrl);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ✅ 추가: 설교모음(허브)으로 이동하는 메뉴
            _AccordionTile(
              title: '설교모음',
              children: [
                _SubMenuItem(
                  text: '설교모음(전체 보기)',
                  onTap: () {
                    onClose();
                    context.push('/sermon/board'); // 기존 SermonBoardPage 라우트
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ✅ 개선: 지난 설교 말씀은 "바로 링크로 직행"
            _AccordionTile(
              title: '지난 설교 말씀',
              children: [
                _SubMenuItem(
                  text: '주일예배설교',
                  onTap: () async {
                    onClose();
                    await _openExternal('https://www.eloomtv.com/main/sub.html?pageCode=8');
                  },
                ),
                _SubMenuItem(
                  text: '부교역자설교',
                  onTap: () async {
                    onClose();
                    await _openExternal('https://www.eloomtv.com/main/sub.html?pageCode=9');
                  },
                ),
                _SubMenuItem(
                  text: '초청강사설교',
                  onTap: () async {
                    onClose();
                    await _openExternal('https://www.eloomtv.com/main/sub.html?pageCode=10');
                  },
                ),
                _SubMenuItem(
                  text: '특별집회',
                  onTap: () async {
                    onClose();
                    await _openExternal('https://www.eloomtv.com/main/sub.html?pageCode=11');
                  },
                ),
              ],
            ),
          ],
        );

      case 1: // 교회주보
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccordionTile(
              title: '교회주보',
              children: [
                _SubMenuItem(
                  text: '교회 주보 보기',
                  onTap: () {
                    onClose();
                    context.push('/bulletin');
                  },
                ),
                _SubMenuItem(
                  text: '주보 광고 요청',
                  onTap: () {
                    onClose();
                    // 아직 라우트 없으면 일단 bulletins로 보내고 나중에 분리
                    context.push('/bulletins');
                  },
                ),
              ],
            ),
          ],
        );

      case 2: // 성경읽기
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccordionTile(
              title: '성경읽기',
              children: [
                _SubMenuItem(
                  text: '성경 본문 읽기',
                  onTap: () {
                    onClose();
                    context.push('/bible');
                  },
                ),
                _SubMenuItem(
                  text: '검색',
                  onTap: () {
                    onClose();
                    context.push('/bible');
                  },
                ),
                _SubMenuItem(
                  text: '예배노트',
                  onTap: () {
                    onClose();
                    context.push('/bible');
                  },
                ),
              ],
            ),
          ],
        );

      case 3: // 기도제목
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccordionTile(
              title: '기도제목',
              children: [
                _SubMenuItem(
                  text: '공동기도제목',
                  onTap: () {
                    onClose();
                    context.push('/prayer?tab=0');
                  },
                ),
                _SubMenuItem(
                  text: isLoggedIn ? '개인기도제목' : '개인기도제목 (로그인 필요)',
                  onTap: () {
                    onClose();
                    if (!isLoggedIn) {
                      context.push('/login?from=${Uri.encodeComponent('/prayer?tab=1')}');
                      return;
                    }
                    context.push('/prayer?tab=1');
                  },
                ),
              ],
            ),
          ],
        );

      case 4: // 온라인헌금
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccordionTile(
              title: '온라인헌금',
              children: [
                _SubMenuItem(
                  text: '계좌번호 보기',
                  onTap: () {
                    onClose();
                    context.push('/offering');
                  },
                ),
                _SubMenuItem(
                  text: isLoggedIn ? '기부금 영수증 신청' : '기부금 영수증 신청 (로그인 필요)',
                  onTap: () {
                    onClose();

                    const target = '/offering/receipt';

                    if (!isLoggedIn) {
                      // ✅ 로그인 후 다시 영수증 페이지로 복귀
                      context.push('/login?from=${Uri.encodeComponent(target)}');
                      return;
                    }

                    // ✅ 실제 존재하는 페이지로 이동
                    context.push(target);
                  },
                ),
              ],
            ),
          ],
        );


      case 5: // 교회카페
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccordionTile(
              title: '교회카페',
              children: [
                _SubMenuItem(
                  text: isLoggedIn ? '메뉴/주문하기' : '메뉴/주문하기 (로그인 필요)',
                  onTap: () {
                    onClose();
                    const target = '/cafe?tab=0';
                    if (!isLoggedIn) {
                      context.push('/login?from=${Uri.encodeComponent(target)}');
                      return;
                    }
                    context.push(target);
                  },
                ),
                _SubMenuItem(
                  text: isLoggedIn ? '나의 주문 내역' : '나의 주문 내역 (로그인 필요)',
                  onTap: () {
                    onClose();
                    const target = '/cafe?tab=3';
                    if (!isLoggedIn) {
                      context.push('/login?from=${Uri.encodeComponent(target)}');
                      return;
                    }
                    context.push(target);
                  },
                ),
              ],
            ),
          ],
        );

      case 6: // 구역모임
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccordionTile(
              title: '구역모임',
              children: [
                _SubMenuItem(
                  text: isLoggedIn ? '내 구역 정보' : '내 구역 정보 (로그인 필요)',
                  onTap: () {
                    onClose();
                    final to = '/cell?tab=0';
                    if (!isLoggedIn) {
                      context.push('/login?from=${Uri.encodeComponent(to)}');
                      return;
                    }
                    context.push(to);
                  },
                ),
                _SubMenuItem(
                  text: isLoggedIn ? '구역 게시판' : '구역 게시판 (로그인 필요)',
                  onTap: () {
                    onClose();
                    final to = '/cell?tab=1';
                    if (!isLoggedIn) {
                      context.push('/login?from=${Uri.encodeComponent(to)}');
                      return;
                    }
                    context.push(to);
                  },
                )
              ],
            ),
          ],
        );


      case 7: // ✅ 사역신청
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccordionTile(
              title: '사역신청',
              children: [
                _SubMenuItem(
                  text: isLoggedIn ? '사역 신청 하기' : '사역 신청 하기 (로그인 필요)',
                  onTap: () {
                    onClose();
                    const target = '/ministry?tab=0';
                    if (!isLoggedIn) {
                      context.push('/login?from=${Uri.encodeComponent(target)}');
                      return;
                    }
                    context.push(target);
                  },
                ),
                _SubMenuItem(
                  text: isLoggedIn ? '나의 신청 내역' : '나의 신청 내역 (로그인 필요)',
                  onTap: () {
                    onClose();
                    const target = '/ministry?tab=1';
                    if (!isLoggedIn) {
                      context.push('/login?from=${Uri.encodeComponent(target)}');
                      return;
                    }
                    context.push(target);
                  },
                ),
              ],
            ),
          ],
        );

      case 8: // ✅ 홈페이지 (기존 case 7 → 8로 이동)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccordionTile(
              title: '홈페이지',
              children: [
                _SubMenuItem(
                  text: '교회 홈페이지 열기',
                  onTap: () async {
                    onClose();
                    await _openExternal(AppLinks.homepage);
                  },
                ),
                _SubMenuItem(
                  text: '교회 소식 보기',
                  onTap: () {
                    onClose();
                    context.push('/boards/news');
                  },
                ),
              ],
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/// ✅ 아코디언 타일(펼침/접힘)
class _AccordionTile extends StatefulWidget {
  final String title;
  final List<Widget> children;

  const _AccordionTile({
    required this.title,
    required this.children,
  });

  @override
  State<_AccordionTile> createState() => _AccordionTileState();
}

class _AccordionTileState extends State<_AccordionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        // ✅ 왼쪽 정렬/상단 정렬 안정화 (중앙으로 밀리는 현상 방지)
        childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        initiallyExpanded: true, // ✅ v4는 스샷처럼 기본으로 펼쳐진 느낌이 자연스러움(원치 않으면 false)
        onExpansionChanged: (v) => setState(() => _expanded = v),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15.5, // ✅ 타이틀도 살짝 키움
          ),
        ),
        trailing: Icon(
          _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: Colors.black54,
        ),
        children: widget.children,
      ),
    );
  }
}

/// ✅ 하위 메뉴 한 줄: 왼쪽 정렬 + 글씨 조금 키움
class _SubMenuItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SubMenuItem({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft, // ✅ 왼쪽 정렬 고정
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 14.5, // ✅ 기존 13 -> 14.5
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
