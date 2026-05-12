import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/church_event_api.dart';
import '../../data/church_event_repository_impl.dart';
import '../../domain/church_event_repository.dart';
import '../../domain/models/church_event.dart';

final churchEventRepositoryProvider = Provider<ChurchEventRepository>((ref) {
  return ChurchEventRepositoryImpl(api: ChurchEventApi());
});

typedef MonthKey = ({int year, int month});

/// 월별 일정.
final churchEventsByMonthProvider =
    FutureProvider.family<List<ChurchEvent>, MonthKey>((ref, key) async {
  return ref
      .watch(churchEventRepositoryProvider)
      .fetchMonth(year: key.year, month: key.month);
});

/// 단건.
final churchEventByIdProvider =
    FutureProvider.family<ChurchEvent?, int>((ref, id) async {
  return ref.watch(churchEventRepositoryProvider).fetchById(id);
});
