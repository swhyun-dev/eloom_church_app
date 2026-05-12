import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/church_event.dart';
import '../providers/church_event_providers.dart';

/// 백엔드 ChurchEvent 기반 교회일정 캘린더 — 라우터 /calendar/church 로 진입.
/// 기존 /calendar/edu (BoardCategory.eduNotice) 와 별도 존재한다.
class ChurchEventCalendarPage extends ConsumerStatefulWidget {
  const ChurchEventCalendarPage({super.key});

  @override
  ConsumerState<ChurchEventCalendarPage> createState() =>
      _ChurchEventCalendarPageState();
}

class _ChurchEventCalendarPageState
    extends ConsumerState<ChurchEventCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? _focusedDay;
    final key = (year: _focusedDay.year, month: _focusedDay.month);
    final async = ref.watch(churchEventsByMonthProvider(key));

    return Scaffold(
      appBar: AppBar(title: const Text('교회일정')),
      body: AsyncValueBuilder<List<ChurchEvent>>(
        value: async,
        onRetry: () => ref.invalidate(churchEventsByMonthProvider(key)),
        builder: (events) {
          List<ChurchEvent> eventsOf(DateTime day) =>
              events.where((e) => e.occursOn(day)).toList()
                ..sort((a, b) => a.startAt.compareTo(b.startAt));

          final dayEvents = eventsOf(selected);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar<ChurchEvent>(
                    firstDay: DateTime.utc(2025, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                    onDaySelected: (sel, foc) => setState(() {
                      _selectedDay = sel;
                      _focusedDay = foc;
                    }),
                    onPageChanged: (foc) => setState(() => _focusedDay = foc),
                    eventLoader: eventsOf,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '선택한 날짜 일정 (${selected.year}/${selected.month}/${selected.day})',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (dayEvents.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('등록된 일정이 없습니다.'),
                  ),
                )
              else
                ...dayEvents.map(_EventCard.new),
            ],
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final ChurchEvent event;
  const _EventCard(this.event);

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final time =
        '${_two(event.startAt.hour)}:${_two(event.startAt.minute)} ~ '
        '${_two(event.endAt.hour)}:${_two(event.endAt.minute)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(event.title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(event.category.label,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$time${event.location != null ? '  ·  ${event.location}' : ''}',
                style: const TextStyle(color: Colors.black54),
              ),
              if (event.description != null && event.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(event.description!,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
