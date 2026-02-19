import 'package:flutter/material.dart';

// ✅ v4만 사용
import 'home_end_drawer_v4.dart';

class HomeEndDrawer extends StatelessWidget {
  const HomeEndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 설정값 무시하고 항상 v4
    return const HomeEndDrawerV4();
  }
}