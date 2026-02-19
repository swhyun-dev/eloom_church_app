import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../state/auth_provider.dart';

class EloomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const EloomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    final canPop = Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,

      // ✅ 뒤로가기 안정화
      automaticallyImplyLeading: false,
      leading: canPop
          ? IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: () => Navigator.of(context).pop(),
      )
          : null,

      title: InkWell(
        borderRadius: BorderRadius.circular(10),
        // ✅ go()는 스택을 갈아엎어서 뒤로가기를 자주 깨뜨림
        // 홈으로 가더라도 "push" 성격으로 가고 싶으면 push()를 쓰거나,
        // 홈으로 강제 이동이 목적이면 go()를 유지하되 leading은 위처럼 커스텀으로 고정.
        onTap: () => context.go('/'),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Text(
            '이룸교회',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.brand,
            ),
          ),
        ),
      ),

      actions: [
        if (auth.isLoggedIn) ...[
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 4),
              child: Text(
                '${auth.name} 성도님',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
        IconButton(
          onPressed: () => context.push(auth.isLoggedIn ? '/my' : '/login'),
          icon: const Icon(Icons.person_outline),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}

