import 'package:flutter/material.dart';

class BulletinPage extends StatefulWidget {
  const BulletinPage({super.key});

  @override
  State<BulletinPage> createState() => _BulletinPageState();
}

class _BulletinPageState extends State<BulletinPage> {
  // 더미: 날짜 선택
  int year = 2026;
  int month = 1;
  int day = 25;

  // 더미: 주보 페이지(이미지/네트워크/PDF로 바뀔 예정)
  int pageIndex = 0;
  final int totalPages = 2;

  List<int> get years => List.generate(10, (i) => 2020 + i);
  List<int> get months => List.generate(12, (i) => i + 1);

  /// ✅ "주일"만(=일요일) 선택되도록: 해당 연/월의 일요일 날짜들만 반환
  List<int> get sundayDays => _getSundays(year, month);

  @override
  void initState() {
    super.initState();
    _ensureValidDay(); // 초기 day가 주일이 아니면 보정
  }

  void _ensureValidDay() {
    final list = sundayDays;
    if (list.isEmpty) return;

    // 현재 선택 day가 목록에 없으면(=주일이 아니면) 첫 주일로 보정
    if (!list.contains(day)) {
      day = list.first;
    }
  }

  void _setYear(int v) {
    setState(() {
      year = v;
      _ensureValidDay();
    });
  }

  void _setMonth(int v) {
    setState(() {
      month = v;
      _ensureValidDay();
    });
  }

  void _setDay(int v) {
    setState(() {
      day = v;
    });
  }

  /// ✅ 특정 연/월에서 "일요일" 날짜만 뽑기
  List<int> _getSundays(int y, int m) {
    final lastDay = DateTime(y, m + 1, 0).day; // 해당 월 마지막 날짜
    final result = <int>[];

    for (int d = 1; d <= lastDay; d++) {
      final dt = DateTime(y, m, d);
      if (dt.weekday == DateTime.sunday) {
        result.add(d);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('교회주보'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 날짜 선택 바
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _DropdownBox<int>(
                      value: year,
                      items: years,
                      labelBuilder: (v) => '$v년',
                      onChanged: _setYear,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DropdownBox<int>(
                      value: month,
                      items: months,
                      labelBuilder: (v) => '$v월',
                      onChanged: _setMonth,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ✅ day 드롭다운: 일요일(주일)만 표시
                  Expanded(
                    child: _DropdownBox<int>(
                      value: day,
                      items: sundayDays,
                      // 표시 라벨은 요청대로 "4일/11일/18일"처럼 "일" 단위 그대로
                      labelBuilder: (v) => '$v일',
                      onChanged: _setDay,
                    ),
                  ),
                ],
              ),
            ),

            // 주보 카드 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                        color: Colors.black.withOpacity(0.06),
                      ),
                    ],
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          color: cs.surface,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 54,
                                color: cs.onSurface.withOpacity(0.35),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$year.$month.${day.toString().padLeft(2, '0')} 주보\n(더미 페이지 ${pageIndex + 1}/$totalPages)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '여기에 실제 주보 이미지를 넣으면\n스크린샷처럼 보여요.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.55),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 네비 버튼 (동그란 버튼 2개)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleNavButton(
                    icon: Icons.chevron_left,
                    filled: false,
                    onTap: pageIndex > 0 ? () => setState(() => pageIndex--) : null,
                  ),
                  const SizedBox(width: 14),
                  _CircleNavButton(
                    icon: Icons.chevron_right,
                    filled: true,
                    onTap: pageIndex < totalPages - 1 ? () => setState(() => pageIndex++) : null,
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

class _DropdownBox<T> extends StatelessWidget {
  const _DropdownBox({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.expand_more),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
          ),
        ),
        items: items
            .map(
              (v) => DropdownMenuItem<T>(
            value: v,
            child: Text(labelBuilder(v), overflow: TextOverflow.ellipsis),
          ),
        )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _CircleNavButton extends StatelessWidget {
  const _CircleNavButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    final bg = filled ? cs.primary : cs.surface;
    final fg = filled ? cs.onPrimary : cs.onSurface;
    final border = filled ? Colors.transparent : Colors.black.withOpacity(0.12);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border),
          ),
          child: Icon(icon, color: fg, size: 26),
        ),
      ),
    );
  }
}