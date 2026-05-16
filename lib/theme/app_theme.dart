import 'package:flutter/material.dart';

class AppTheme {
  // 브랜드 메인 — 짙은 파랑. 슬라이드 메뉴 선택 / 캘린더 강조 / 버튼 포인트 등 전반 통일.
  static const brand = Color(0xFF0B4FA8);

  // ✅ 스플래시 배경과 동일 톤
  static const bg = Color(0xFFEAF5FA);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: bg,

      // Drawer / BottomSheet / Dialog 기본 배경
      canvasColor: bg,

      // Material3 색상 정리
      colorScheme: base.colorScheme.copyWith(
        primary: brand,
        surface: bg,
        background: bg, // ignore: deprecated_member_use
        onPrimary: Colors.white,
        onSurface: const Color(0xFF1F2937),
      ),

      // ✅ Pretendard 전역 적용 (🔥 핵심 해결)
      textTheme: base.textTheme.apply(
        fontFamily: 'Pretendard',
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
        iconTheme: IconThemeData(
          color: Color(0xFF111827),
        ),
      ),

      // 카드
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: Colors.black.withValues(alpha: 0.08),
        thickness: 1,
      ),

      // BottomSheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
