import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/edu_event.dart';
import '../../services/edu_event_service.dart';

class EduCalendarPage extends StatefulWidget {
  const EduCalendarPage({super.key});

  @override
  State<EduCalendarPage> createState() => _EduCalendarPageState();
}

class _EduCalendarPageState extends State<EduCalendarPage> {
  late final Future<List<EduEvent>> _future;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _future = EduEventService().fetchAll();
  }

  List<EduEvent> _eventsOf(DateTime day, List<EduEvent> all) {
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    return all.where((e) => sameDay(e.startAt, day)).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('교육일정')),
      body: FutureBuilder<List<EduEvent>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('오류: ${snap.error}'));
          }

          final all = snap.data ?? [];
          final selected = _selectedDay ?? _focusedDay;
          final events = _eventsOf(selected, all);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2025, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: false,
                    ),
                    eventLoader: (day) => _eventsOf(day, all),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '선택한 날짜 일정 (${selected.year}/${selected.month}/${selected.day})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (events.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('등록된 교육 일정이 없습니다.'),
                  ),
                )
              else
                ...events.map((e) => _EventCard(
                      event: e,
                      onTap: () => context.push('/calendar/edu/${e.id}'),
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EduEvent event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final time =
        '${event.startAt.hour.toString().padLeft(2, '0')}:${event.startAt.minute.toString().padLeft(2, '0')} ~ '
        '${event.endAt.hour.toString().padLeft(2, '0')}:${event.endAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_eduBadge(event.startAt) != null)
                      _Tag(text: _eduBadge(event.startAt)!),
                  ],
                ),
                const SizedBox(height: 6),
                Text(time, style: const TextStyle(color: Colors.black54)),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _eduBadge(DateTime startAt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final s = DateTime(startAt.year, startAt.month, startAt.day);
  final diff = s.difference(today).inDays;
  if (diff == 0) return '오늘';
  if (diff > 0 && diff <= 6) return '이번주';
  return null;
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
