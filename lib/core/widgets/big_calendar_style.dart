import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../theme/app_theme.dart';

/// 어르신 친화 캘린더 스타일 — 큰 글씨, 한글 요일, 명확한 색상.
/// /calendar/church, /calendar/edu 등 캘린더 화면에서 공통 사용.

HeaderStyle bigCalendarHeaderStyle() => const HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
      headerPadding: EdgeInsets.symmetric(vertical: 10),
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: Color(0xFF111827),
      ),
      leftChevronIcon: Icon(Icons.chevron_left, size: 32),
      rightChevronIcon: Icon(Icons.chevron_right, size: 32),
    );

CalendarStyle bigCalendarStyle() => CalendarStyle(
      cellMargin: const EdgeInsets.all(4),
      outsideDaysVisible: false,
      defaultTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      weekendTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFEF4444),
      ),
      todayDecoration: BoxDecoration(
        color: AppTheme.brand.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      todayTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: AppTheme.brand,
      ),
      selectedDecoration: const BoxDecoration(
        color: AppTheme.brand,
        shape: BoxShape.circle,
      ),
      selectedTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
      markerDecoration: const BoxDecoration(
        color: AppTheme.brand,
        shape: BoxShape.circle,
      ),
      markerSize: 6,
      markersOffset: const PositionedOffset(bottom: 4),
      markersMaxCount: 3,
    );

CalendarBuilders<T> bigCalendarBuilders<T>() => CalendarBuilders<T>(
      dowBuilder: (context, day) {
        const kr = ['월', '화', '수', '목', '금', '토', '일'];
        final Color color;
        if (day.weekday == DateTime.sunday) {
          color = const Color(0xFFEF4444);
        } else if (day.weekday == DateTime.saturday) {
          color = const Color(0xFF3B82F6);
        } else {
          color = const Color(0xFF374151);
        }
        return Center(
          child: Text(
            kr[day.weekday - 1],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        );
      },
    );
