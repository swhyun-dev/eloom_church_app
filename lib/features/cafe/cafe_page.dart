// cafe_page.dart (FINAL - FULL)
// 반영(요청사항):
// 1) 카테고리별 옵션 정책 변경
//    - 커피/논커피: 당도 / 샷선택(연하게/샷추가) / 우유선택(기본/우유조금)
//    - 에이드/스무디: 당도
//    - 음료: 아이스컵 추가(추가함/추가 안함)
//    - 티: 옵션 없음
// 2) 온도 선택을 캡처처럼 명확한 "세그먼트 버튼" UI로 변경
// 3) 옵션 선택 UI는 모두 동일한 요소(단일 선택 체크형)로 통일(중복 불가)
// 4) options JSON 키는 기존 호환 유지(temp, sweetness, extraShot, light, lessMilk, icedCup)

import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/cafe_service.dart';
import '../../state/auth_provider.dart';

/// =======================
/// Utils
/// =======================
String fmtWon(int v) {
  final s = v.toString();
  final r = s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  return '$r원';
}

String? _onlyText(CafeTempPolicy policy) {
  switch (policy) {
    case CafeTempPolicy.hotOnly:
      return 'HOT Only';
    case CafeTempPolicy.icedOnly:
      return 'ICED Only';
    case CafeTempPolicy.both:
      return null;
  }
}

/// options Map -> 안정적인 JSON(키 정렬)로 encode
String encodeOptionsSorted(Map<String, dynamic> m) {
  Map<String, dynamic> sortMap(Map<String, dynamic> src) {
    final tree = SplayTreeMap<String, dynamic>();
    for (final e in src.entries) {
      final v = e.value;
      if (v is Map<String, dynamic>) {
        tree[e.key] = sortMap(v);
      } else {
        tree[e.key] = v;
      }
    }
    return Map<String, dynamic>.from(tree);
  }

  final sorted = sortMap(m);
  return jsonEncode(sorted);
}

Map<String, dynamic> safeDecodeOptions(String? s) {
  if (s == null || s.trim().isEmpty) return {};
  try {
    final j = jsonDecode(s);
    if (j is Map) return Map<String, dynamic>.from(j);
    return {};
  } catch (_) {
    return {};
  }
}

/// =======================
/// Theme color (파란 계열)
/// =======================
const Color kCafePrimary = Color(0xFF1F5AA8);
const Color kCafeDark = Color(0xFF163F78);

const Color kHotBadge = Color(0xFFDC2626); // red
const Color kIcedBadge = Color(0xFF2563EB); // blue

/// =======================
/// Server aligned Models
/// =======================
enum CafeTempPolicy { both, hotOnly, icedOnly }

CafeTempPolicy cafeTempPolicyFrom(String? v) {
  switch ((v ?? '').toUpperCase()) {
    case 'HOT_ONLY':
      return CafeTempPolicy.hotOnly;
    case 'ICED_ONLY':
      return CafeTempPolicy.icedOnly;
    default:
      return CafeTempPolicy.both;
  }
}

extension CafeTempPolicyX on CafeTempPolicy {
  bool get allowHot => this == CafeTempPolicy.both || this == CafeTempPolicy.hotOnly;
  bool get allowIced => this == CafeTempPolicy.both || this == CafeTempPolicy.icedOnly;
}

class CafeMenuPayload {
  final List<String> categories; // 서버 sortOrder 유지
  final Map<String, List<CafeMenuItem>> data;

  const CafeMenuPayload({required this.categories, required this.data});

  List<CafeMenuItem> get allItems {
    final out = <CafeMenuItem>[];
    for (final c in categories) {
      out.addAll(data[c] ?? const []);
    }
    // 혹시 categories에 없는 key도 포함
    for (final e in data.entries) {
      if (!categories.contains(e.key)) out.addAll(e.value);
    }
    return out;
  }
}

class CafeMenuItem {
  final int id;
  final int categoryId;
  final String category;
  final String name;
  final int price;
  final String? note;
  final CafeTempPolicy tempPolicy;
  final bool isSoldOut;
  final bool isActive;
  final int sortOrder;

  const CafeMenuItem({
    required this.id,
    required this.categoryId,
    required this.category,
    required this.name,
    required this.price,
    required this.note,
    required this.tempPolicy,
    required this.isSoldOut,
    required this.isActive,
    required this.sortOrder,
  });

  factory CafeMenuItem.fromJson(Map<String, dynamic> j) {
    return CafeMenuItem(
      id: (j['id'] as num).toInt(),
      categoryId: (j['categoryId'] as num).toInt(),
      category: (j['category'] ?? '기타').toString(),
      name: (j['name'] ?? '').toString(),
      price: (j['price'] as num).toInt(),
      note: j['note']?.toString(),
      tempPolicy: cafeTempPolicyFrom(j['tempPolicy']?.toString()),
      isSoldOut: j['isSoldOut'] == true,
      isActive: j['isActive'] == true,
      sortOrder: (j['sortOrder'] as num? ?? 0).toInt(),
    );
  }
}

/// =======================
/// Category helpers
/// =======================
bool isBakeryCategory(String cat) {
  final c = cat.replaceAll(' ', '');
  return c.contains('베이커리') || c.contains('디저트') || c.contains('빵');
}

// ✅ NEW: 정책 반영 분류
bool isCoffeeOrNonCoffee(String cat) {
  final c = cat.replaceAll(' ', '');
  return c.contains('논커피') || c.contains('커피');
}

bool isAdeOrSmoothie(String cat) {
  final c = cat.replaceAll(' ', '');
  return c.contains('에이드') || c.contains('스무디');
}

bool isDrinkOnly(String cat) {
  final c = cat.replaceAll(' ', '');
  // "티" 제외, "음료"만
  return c.contains('음료') && !c.contains('티');
}

bool isTeaOnly(String cat) {
  final c = cat.replaceAll(' ', '');
  return c.contains('티');
}

/// =======================
/// Cart + Order models
/// =======================
class CafeCartLine {
  final String lineId;
  final CafeMenuItem item;
  final int qty;

  final String? optionsJson; // 서버 orders: options = string(JSON)

  const CafeCartLine({
    required this.lineId,
    required this.item,
    required this.qty,
    this.optionsJson,
  });

  int get lineTotal => item.price * qty;

  CafeCartLine copyWith({int? qty}) => CafeCartLine(
    lineId: lineId,
    item: item,
    qty: qty ?? this.qty,
    optionsJson: optionsJson,
  );

  Map<String, dynamic> get options => safeDecodeOptions(optionsJson);

  String get optionSummary {
    final o = options;
    final parts = <String>[];

    final temp = (o['temp'] ?? '').toString().toUpperCase();
    if (temp == 'HOT' || temp == 'ICED') parts.add(temp);

    final sweetness = (o['sweetness'] ?? '').toString();
    if (sweetness == 'LESS') parts.add('덜달게');
    if (sweetness == 'MORE') parts.add('달게');

    if (o['extraShot'] == true) parts.add('샷추가');
    if (o['light'] == true) parts.add('연하게');
    if (o['lessMilk'] == true) parts.add('우유조금');
    if (o['icedCup'] == true) parts.add('아이스컵 추가');

    return parts.isEmpty ? '-' : parts.join(' / ');
  }

  /// 라인 구분키(같은 메뉴라도 옵션 다르면 다른 라인)
  String get lineKey => '${item.id}::${optionsJson ?? ''}';
}

enum CafeOrderStage { ordered, making, ready, done }

extension CafeOrderStageX on CafeOrderStage {
  String get label {
    switch (this) {
      case CafeOrderStage.ordered:
        return '주문완료';
      case CafeOrderStage.making:
        return '제조중';
      case CafeOrderStage.ready:
        return '제조완료';
      case CafeOrderStage.done:
        return '수령완료';
    }
  }
}

class CafeOrder {
  final String orderId;
  final DateTime createdAt;
  final List<CafeCartLine> lines;
  final int total;
  final int waitingCount;

  final CafeOrderStage stage;
  final DateTime? makingAt;
  final DateTime? readyAt;
  final DateTime? doneAt;

  const CafeOrder({
    required this.orderId,
    required this.createdAt,
    required this.lines,
    required this.total,
    required this.waitingCount,
    this.stage = CafeOrderStage.ordered,
    this.makingAt,
    this.readyAt,
    this.doneAt,
  });

  int get totalCups => lines.fold<int>(0, (s, l) => s + l.qty);
}

/// =======================
/// Providers (Menu: API)
/// =======================
final cafeMenuPayloadProvider = FutureProvider<CafeMenuPayload>((ref) {
  return CafeService().fetchMenu();
});

class CafeCartNotifier extends StateNotifier<List<CafeCartLine>> {
  CafeCartNotifier() : super(const []);

  void addLine(CafeMenuItem item, int qty, Map<String, dynamic> options) {
    final q = qty.clamp(1, 20);
    final optionsJson = options.isEmpty ? null : encodeOptionsSorted(options);

    // 같은 메뉴 + 같은 옵션이면 수량 합치기
    final idx = state.indexWhere((l) => l.item.id == item.id && l.optionsJson == optionsJson);
    if (idx >= 0) {
      final updated = [...state];
      final cur = updated[idx];
      updated[idx] = cur.copyWith(qty: (cur.qty + q).clamp(1, 20));
      state = updated;
      return;
    }

    final line = CafeCartLine(
      lineId: '${item.id}_${DateTime.now().millisecondsSinceEpoch}',
      item: item,
      qty: q,
      optionsJson: optionsJson,
    );
    state = [...state, line];
  }

  void removeLine(String lineId) => state.where((e) => e.lineId != lineId).toList().let((v) => state = v);

  void changeQty(String lineId, int qty) {
    final q = qty.clamp(1, 20);
    state = [
      for (final l in state)
        if (l.lineId == lineId) l.copyWith(qty: q) else l,
    ];
  }

  void clear() => state = const [];
}

extension _LetExt<T> on T {
  R let<R>(R Function(T it) f) => f(this);
}

final cafeCartProvider = StateNotifierProvider<CafeCartNotifier, List<CafeCartLine>>(
      (ref) => CafeCartNotifier(),
);

final cafeTotalProvider = Provider<int>((ref) {
  final lines = ref.watch(cafeCartProvider);
  return lines.fold<int>(0, (sum, l) => sum + l.lineTotal);
});

final cafeCartCountProvider = Provider<int>((ref) {
  final lines = ref.watch(cafeCartProvider);
  return lines.fold<int>(0, (sum, l) => sum + l.qty);
});

class CafeOrdersNotifier extends StateNotifier<List<CafeOrder>> {
  CafeOrdersNotifier() : super(const []);
  void addOrder(CafeOrder o) => state = [o, ...state];
}

final cafeOrdersProvider = StateNotifierProvider<CafeOrdersNotifier, List<CafeOrder>>(
      (ref) => CafeOrdersNotifier(),
);

/// =======================
/// Page
/// =======================
class CafePage extends ConsumerStatefulWidget {
  final int initialTab; // ✅ /cafe?tab=
  const CafePage({super.key, this.initialTab = 0});

  @override
  ConsumerState<CafePage> createState() => _CafePageState();
}

class _CafePageState extends ConsumerState<CafePage> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    final init = widget.initialTab.clamp(0, 3);
    _tab = TabController(length: 4, vsync: this, initialIndex: init);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _goTab(int index) => _tab.animateTo(index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('교회카페'),
        bottom: TabBar(
          controller: _tab,

          // ✅ 탭을 화면 너비에 맞게 "골고루" 분배
          isScrollable: false,
          tabAlignment: TabAlignment.fill,

          // 스타일 통일
          labelColor: kCafePrimary,
          unselectedLabelColor: Colors.black54,
          indicatorColor: kCafePrimary,
          indicatorWeight: 2.2,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900),

          tabs: const [
            Tab(text: '메뉴'),
            Tab(text: '장바구니'),
            Tab(text: '입금계좌'),
            Tab(text: '나의주문내역'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _CafeMenuTab(
            onGoCart: () => _goTab(1),
            onGoOrders: () => _goTab(3),
          ),
          _CafeCartTab(
            onGoOrders: () => _goTab(3),
          ),
          const _CafeAccountTab(),
          const _CafeOrdersTab(),
        ],
      ),
    );
  }
}

/// =======================
/// Tab: 메뉴
/// =======================
class _CafeMenuTab extends ConsumerStatefulWidget {
  final VoidCallback onGoCart;
  final VoidCallback onGoOrders;

  const _CafeMenuTab({
    required this.onGoCart,
    required this.onGoOrders,
  });

  @override
  ConsumerState<_CafeMenuTab> createState() => _CafeMenuTabState();
}

class _CafeMenuTabState extends ConsumerState<_CafeMenuTab> {
  String _cat = '전체';

  @override
  Widget build(BuildContext context) {
    final asyncPayload = ref.watch(cafeMenuPayloadProvider);

    return asyncPayload.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('메뉴를 불러오지 못했습니다.\n$e', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.refresh(cafeMenuPayloadProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
      data: (payload) {
        final cats = <String>['전체', ...payload.categories];
        final allItems = payload.allItems;

        if (_cat != '전체' && !payload.categories.contains(_cat)) _cat = '전체';

        final filtered = _cat == '전체' ? allItems : (payload.data[_cat] ?? const <CafeMenuItem>[]);

        return ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in cats)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c, style: const TextStyle(fontWeight: FontWeight.w800)),
                        selected: _cat == c,
                        onSelected: (_) => setState(() => _cat = c),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text('총 ${filtered.length}건', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final item in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MenuRowCard(
                  item: item,
                  onTap: item.isSoldOut
                      ? null
                      : () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CafeOptionPage(
                          menuItem: item,
                          onGoCart: widget.onGoCart,
                          onGoOrders: widget.onGoOrders,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MenuRowCard extends StatelessWidget {
  final CafeMenuItem item;
  final VoidCallback? onTap;

  const _MenuRowCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final bakery = isBakeryCategory(item.category);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Opacity(
        opacity: disabled ? 0.55 : 1.0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.grey.shade200,
                ),
                child: const Icon(Icons.local_cafe_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900)),
                        ),
                        if (item.isSoldOut)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                            ),
                            child: const Text('품절',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 11)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (!bakery) ..._tempBadges(item.tempPolicy),

                        // ✅ Only 문구는 note가 아니라 tempPolicy 기준
                        if (!bakery && _onlyText(item.tempPolicy) != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _onlyText(item.tempPolicy)!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(fmtWon(item.price), style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _tempBadges(CafeTempPolicy policy) {
    if (policy == CafeTempPolicy.hotOnly) {
      return const [_TempBadge(text: 'HOT', bg: kHotBadge)];
    }
    if (policy == CafeTempPolicy.icedOnly) {
      return const [_TempBadge(text: 'ICED', bg: kIcedBadge)];
    }
    // BOTH => 두개 따로
    return const [
      _TempBadge(text: 'HOT', bg: kHotBadge),
      SizedBox(width: 6),
      _TempBadge(text: 'ICED', bg: kIcedBadge),
    ];
  }
}

class _TempBadge extends StatelessWidget {
  final String text;
  final Color bg;
  const _TempBadge({required this.text, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bg.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(color: bg, fontWeight: FontWeight.w900, fontSize: 11),
      ),
    );
  }
}

/// =======================
/// 옵션 선택 페이지
/// =======================
class CafeOptionPage extends ConsumerStatefulWidget {
  final CafeMenuItem menuItem;
  final VoidCallback onGoCart;
  final VoidCallback onGoOrders;

  const CafeOptionPage({
    super.key,
    required this.menuItem,
    required this.onGoCart,
    required this.onGoOrders,
  });

  @override
  ConsumerState<CafeOptionPage> createState() => _CafeOptionPageState();
}

class _CafeOptionPageState extends ConsumerState<CafeOptionPage> {
  int _qty = 1;

  // temp
  String? _temp; // 'HOT'|'ICED'|null (bakery는 null)

  // ✅ 공통: 당도(선택)
  String? _sweetness; // 'LESS'|'MORE'|null

  // ✅ 커피/논커피: 샷 선택(단일 선택, 미선택 가능)
  String? _shot; // 'LIGHT'|'EXTRA'|null

  // ✅ 커피/논커피: 우유 선택(기본값 = 'NO')
  String _lessMilkPick = 'NO'; // 'NO'|'YES'

  // ✅ 음료: 아이스컵(기본값 = 'NO')
  String _icedCupPick = 'NO'; // 'NO'|'YES'

  bool get _isBakery => isBakeryCategory(widget.menuItem.category);
  bool get _isCoffeeNonCoffee => isCoffeeOrNonCoffee(widget.menuItem.category);
  bool get _isAdeSmoothie => isAdeOrSmoothie(widget.menuItem.category);
  bool get _isDrink => isDrinkOnly(widget.menuItem.category);
  bool get _isTea => isTeaOnly(widget.menuItem.category);

  String? _normalizeTemp(CafeTempPolicy policy, String? cur) {
    if (_isBakery) return null; // ✅ 베이커리는 온도 제거
    if (policy == CafeTempPolicy.hotOnly) return 'HOT';
    if (policy == CafeTempPolicy.icedOnly) return 'ICED';
    // BOTH
    if (cur == 'HOT' || cur == 'ICED') return cur;
    return 'HOT'; // 기본 HOT
  }

  Map<String, dynamic> _buildOptions() {
    final m = <String, dynamic>{};

    final item = widget.menuItem;
    final temp = _normalizeTemp(item.tempPolicy, _temp);
    if (temp != null) m['temp'] = temp;

    // ✅ 커피/논커피: 당도 + 샷선택(연하게/샷추가) + 우유선택
    if (_isCoffeeNonCoffee) {
      if (_sweetness == 'LESS' || _sweetness == 'MORE') m['sweetness'] = _sweetness;

      if (_shot == 'EXTRA') {
        m['extraShot'] = true;
      } else if (_shot == 'LIGHT') {
        m['light'] = true;
      }

      if (_lessMilkPick == 'YES') m['lessMilk'] = true;
    }

    // ✅ 에이드/스무디: 당도만
    if (_isAdeSmoothie) {
      if (_sweetness == 'LESS' || _sweetness == 'MORE') m['sweetness'] = _sweetness;
    }

    // ✅ 음료: 아이스컵 추가만
    if (_isDrink) {
      if (_icedCupPick == 'YES') m['icedCup'] = true;
    }

    // ✅ 티: 옵션 없음(온도만 정책대로)

    return m;
  }

  /// ✅ 장바구니 추가 팝업 (기존 유지)
  Future<void> _showAddedPopup() async {
    final goCart = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: kCafePrimary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: kCafePrimary, size: 28),
                ),
                const SizedBox(height: 12),
                const Text('장바구니에 추가했습니다.', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text(
                  '계속 메뉴를 더 담으시거나\n장바구니로 이동할 수 있어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, height: 1.35, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kCafePrimary,
                            side: const BorderSide(color: kCafePrimary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(dialogCtx, false),
                          child: const Text('메뉴 더보기', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: kCafePrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(dialogCtx, true),
                          child: const Text('장바구니 가기', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    if (goCart == true) {
      Navigator.of(context).pop();
      widget.onGoCart();
    } else if (goCart == false) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _directOrder() async {
    final item = widget.menuItem;
    if (item.isSoldOut) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('품절된 메뉴입니다.')));
      return;
    }

    final token = ref.read(authProvider).token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인 후 주문할 수 있습니다.')));
      return;
    }

    final options = _buildOptions();
    final total = item.price * _qty;
    final optionsJson = options.isEmpty ? null : encodeOptionsSorted(options);

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        final summary = _optionSummary(options);
        return AlertDialog(
          title: const Text('바로주문 확인'),
          content: Text(
            '${item.name}\n'
                '수량: $_qty개\n'
                '옵션: $summary\n'
                '결제금액: ${fmtWon(total)}\n\n'
                '주문을 진행할까요?\n(바로주문은 장바구니를 거치지 않습니다.)',
            style: const TextStyle(height: 1.35),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('취소')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kCafePrimary, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('주문하기', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (ok != true) return;
    if (!mounted) return;

    try {
      final res = await CafeService().createOrder(
        items: [{'menuId': item.id, 'qty': _qty, if (optionsJson != null) 'options': optionsJson}],
      );

      final apiOrder = res['order'] as Map<String, dynamic>?;
      final orderLine = CafeCartLine(
        lineId: '${item.id}_${DateTime.now().millisecondsSinceEpoch}',
        item: item,
        qty: _qty,
        optionsJson: optionsJson,
      );
      final order = CafeOrder(
        orderId: 'OD-${apiOrder?['id'] ?? DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        lines: [orderLine],
        total: total,
        waitingCount: 1 + Random().nextInt(12),
      );

      ref.read(cafeOrdersProvider.notifier).addOrder(order);

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onGoOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('주문 실패: $e')));
    }
  }

  String _optionSummary(Map<String, dynamic> o) {
    final parts = <String>[];
    final temp = (o['temp'] ?? '').toString();
    if (temp.isNotEmpty) parts.add(temp);

    final sweet = (o['sweetness'] ?? '').toString();
    if (sweet == 'LESS') parts.add('덜달게');
    if (sweet == 'MORE') parts.add('달게');

    if (o['extraShot'] == true) parts.add('샷추가');
    if (o['light'] == true) parts.add('연하게');
    if (o['lessMilk'] == true) parts.add('우유조금');
    if (o['icedCup'] == true) parts.add('아이스컵 추가');

    return parts.isEmpty ? '-' : parts.join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.menuItem;
    final cartCount = ref.watch(cafeCartCountProvider);

    _temp = _normalizeTemp(item.tempPolicy, _temp);

    final price = item.price * _qty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('옵션 선택'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
        actions: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              widget.onGoCart();
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 26),
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('$cartCount',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 140),
            children: [
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(26)),
                  child: const Icon(Icons.local_cafe, size: 92),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: Text(item.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900))),
              const SizedBox(height: 10),

              // ✅ 베이커리는 온도 배지 제거
              if (!_isBakery) _TempPolicyRow(policy: item.tempPolicy),

              if (item.note != null && item.note!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    item.note!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, height: 1.35, fontWeight: FontWeight.w700),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // ✅ 온도 선택(BOTH만) - 세그먼트 버튼
              if (!_isBakery && item.tempPolicy == CafeTempPolicy.both) ...[
                _SectionCard(
                  title: '온도 선택',
                  child: _SegmentToggle(
                    leftText: 'ICE',
                    rightText: 'HOT',
                    value: (_temp == 'ICED') ? 'LEFT' : 'RIGHT',
                    onChanged: (v) => setState(() => _temp = (v == 'LEFT') ? 'ICED' : 'HOT'),
                    leftBg: kIcedBadge,
                    rightBg: kHotBadge,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ✅ 커피/논커피 옵션
              if (_isCoffeeNonCoffee) ...[
                _SectionCard(
                  title: '옵션',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OptionSingleSelect(
                        title: '당도 선택',
                        items: const [
                          _OptItem('LESS', '덜달게'),
                          _OptItem('MORE', '달게'),
                        ],
                        value: _sweetness,
                        onChanged: (v) => setState(() => _sweetness = v),
                      ),
                      const SizedBox(height: 12),
                      _OptionSingleSelect(
                        title: '샷 선택',
                        items: const [
                          _OptItem('LIGHT', '연하게'),
                          _OptItem('EXTRA', '샷추가'),
                        ],
                        value: _shot,
                        onChanged: (v) => setState(() => _shot = v),
                      ),
                      const SizedBox(height: 12),
                      _OptionSingleSelect(
                        title: '우유 선택',
                        items: const [
                          _OptItem('NO', '기본'),
                          _OptItem('YES', '우유조금'),
                        ],
                        value: _lessMilkPick,
                        onChanged: (v) => setState(() => _lessMilkPick = v ?? 'NO'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ✅ 에이드/스무디 옵션(당도만)
              if (_isAdeSmoothie) ...[
                _SectionCard(
                  title: '옵션',
                  child: _OptionSingleSelect(
                    title: '당도 선택',
                    items: const [
                      _OptItem('LESS', '덜달게'),
                      _OptItem('MORE', '달게'),
                    ],
                    value: _sweetness,
                    onChanged: (v) => setState(() => _sweetness = v),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ✅ 음료 옵션(아이스컵 추가)
              if (_isDrink) ...[
                _SectionCard(
                  title: '옵션',
                  child: _OptionSingleSelect(
                    title: '아이스컵 추가',
                    items: const [
                      _OptItem('YES', '추가함'),
                      _OptItem('NO', '추가 안함'),
                    ],
                    value: _icedCupPick,
                    onChanged: (v) => setState(() => _icedCupPick = v ?? 'NO'),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ✅ 티: 옵션 없음 (표시 안 함)
              if (_isTea) ...[
                // 필요하면 안내문 넣을 수 있음
              ],
            ],
          ),

          // 하단 고정 바
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: _qty <= 1 ? null : () => setState(() => _qty -= 1),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$_qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        IconButton(
                          onPressed: _qty >= 20 ? null : () => setState(() => _qty += 1),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        const Spacer(),
                        Text(fmtWon(price), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: kCafeDark,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: item.isSoldOut
                                  ? null
                                  : () async {
                                final options = _buildOptions();
                                ref.read(cafeCartProvider.notifier).addLine(item, _qty, options);
                                if (!mounted) return;
                                await _showAddedPopup();
                              },
                              child: const Text('담기', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: kCafePrimary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: item.isSoldOut ? null : _directOrder,
                              child: const Text('바로주문', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TempPolicyRow extends StatelessWidget {
  final CafeTempPolicy policy;
  const _TempPolicyRow({required this.policy});

  @override
  Widget build(BuildContext context) {
    if (policy == CafeTempPolicy.hotOnly) {
      return const Center(child: _TempBadge(text: 'HOT', bg: kHotBadge));
    }
    if (policy == CafeTempPolicy.icedOnly) {
      return const Center(child: _TempBadge(text: 'ICED', bg: kIcedBadge));
    }
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TempBadge(text: 'HOT', bg: kHotBadge),
          SizedBox(width: 8),
          _TempBadge(text: 'ICED', bg: kIcedBadge),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// =======================
/// ✅ 통일된 옵션(단일선택 체크형)
/// =======================
class _OptionSingleSelect extends StatelessWidget {
  final String title;
  final List<_OptItem> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _OptionSingleSelect({
    required this.title,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        for (int i = 0; i < items.length; i++) ...[
          _OptRow(
            text: items[i].label,
            checked: value == items[i].value,
            onTap: () => onChanged(items[i].value),
          ),
          if (i != items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _OptItem {
  final String value;
  final String label;
  const _OptItem(this.value, this.label);
}

class _OptRow extends StatelessWidget {
  final String text;
  final bool checked;
  final VoidCallback onTap;

  const _OptRow({required this.text, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final border = checked ? kCafePrimary : Colors.black26;
    final bg = checked ? kCafePrimary.withValues(alpha: 0.10) : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: checked ? 1.2 : 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 1.5),
                color: checked ? kCafePrimary : Colors.transparent,
              ),
              child: checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================
/// ✅ 온도 세그먼트 토글(캡처 스타일)
/// =======================
class _SegmentToggle extends StatelessWidget {
  final String leftText;
  final String rightText;
  final String value; // 'LEFT' or 'RIGHT'
  final ValueChanged<String> onChanged;
  final Color leftBg;
  final Color rightBg;

  const _SegmentToggle({
    required this.leftText,
    required this.rightText,
    required this.value,
    required this.onChanged,
    required this.leftBg,
    required this.rightBg,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = value == 'LEFT';

    Widget seg({
      required String text,
      required bool selected,
      required Color color,
      required VoidCallback onTap,
      required BorderRadius radius,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? color : Colors.white,
              borderRadius: radius,
              border: Border.all(color: selected ? color : Colors.black26),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        seg(
          text: leftText,
          selected: isLeft,
          color: leftBg,
          onTap: () => onChanged('LEFT'),
          radius: const BorderRadius.horizontal(left: Radius.circular(14)),
        ),
        seg(
          text: rightText,
          selected: !isLeft,
          color: rightBg,
          onTap: () => onChanged('RIGHT'),
          radius: const BorderRadius.horizontal(right: Radius.circular(14)),
        ),
      ],
    );
  }
}

/// =======================
/// Tab: 장바구니
/// =======================
class _CafeCartTab extends ConsumerWidget {
  final VoidCallback onGoOrders;
  const _CafeCartTab({required this.onGoOrders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cafeCartProvider);
    final total = ref.watch(cafeTotalProvider);
    final count = ref.watch(cafeCartCountProvider);

    if (lines.isEmpty) {
      return const Center(child: Text('아직 담은 메뉴가 없습니다.', style: TextStyle(color: Colors.black45)));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            itemCount: lines.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final l = lines[i];
              return Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.grey.shade200,
                      ),
                      child: const Icon(Icons.local_cafe_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.item.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(
                            l.optionSummary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: l.qty <= 1 ? null : () => ref.read(cafeCartProvider.notifier).changeQty(l.lineId, l.qty - 1),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${l.qty}', style: const TextStyle(fontWeight: FontWeight.w900)),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: l.qty >= 20 ? null : () => ref.read(cafeCartProvider.notifier).changeQty(l.lineId, l.qty + 1),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 92,
                      child: Text(fmtWon(l.lineTotal), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                    IconButton(
                      onPressed: () => ref.read(cafeCartProvider.notifier).removeLine(l.lineId),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kCafePrimary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final totalCups = lines.fold<int>(0, (sum, l) => sum + l.qty);

                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => _OrderConfirmDialog(totalCups: totalCups, totalPrice: total),
                  );
                  if (ok != true) return;

                  final token = ref.read(authProvider).token;
                  if (token == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인 후 주문할 수 있습니다.')),
                      );
                    }
                    return;
                  }

                  try {
                    final items = lines.map((l) => <String, dynamic>{
                      'menuId': l.item.id,
                      'qty': l.qty,
                      if (l.optionsJson != null) 'options': l.optionsJson,
                    }).toList();

                    final res = await CafeService().createOrder(
                      items: items,
                    );

                    final apiOrder = res['order'] as Map<String, dynamic>?;
                    final order = CafeOrder(
                      orderId: 'OD-${apiOrder?['id'] ?? DateTime.now().millisecondsSinceEpoch}',
                      createdAt: DateTime.now(),
                      lines: lines,
                      total: total,
                      waitingCount: 1 + Random().nextInt(12),
                    );

                    ref.read(cafeOrdersProvider.notifier).addOrder(order);
                    ref.read(cafeCartProvider.notifier).clear();

                    if (context.mounted) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => CafeOrderCompletePage(order: order),
                        ),
                      );
                    }

                    onGoOrders();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('주문 실패: $e')),
                      );
                    }
                  }
                },
                child: Text('${fmtWon(total)} 주문하기  총 $count개', style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// =======================
/// 주문 완료 풀페이지
/// =======================
class CafeOrderCompletePage extends StatelessWidget {
  final CafeOrder order;
  const CafeOrderCompletePage({super.key, required this.order});

  static const cafeAccount = '신협 131-014-17049-7';
  static const cafeHolder = '예금주: 대한예수교장로회이룸교회';
  static const copyText = '신협 131-014-17049-7 (예금주 대한예수교장로회이룸교회)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(''),
        actions: [
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          const SizedBox(height: 6),
          const Center(child: Text('주문이 완료되었습니다!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
          const SizedBox(height: 18),
          const Center(child: Text('결제금액', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w800))),
          const SizedBox(height: 6),
          Center(child: Text(fmtWon(order.total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
          const SizedBox(height: 12),
          Center(
            child: Text('현재 대기 인원 ${order.waitingCount}명', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
              color: Colors.grey.shade50,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('이룸카페 계좌번호', style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text(cafeAccount, style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text(cafeHolder, style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kCafePrimary, foregroundColor: Colors.white),
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(text: copyText));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('계좌번호가 복사되었습니다.')));
                }
              },
              child: const Text('계좌번호 복사하기', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.black12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('※ 주의사항', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('교회 헌금 계좌로 송금하면 안됩니다.', style: TextStyle(color: Colors.black54)),
                SizedBox(height: 6),
                Text('입금자명은 주문자의 이름을 적어주시기 바랍니다.', style: TextStyle(color: Colors.black54)),
                SizedBox(height: 6),
                Text('쿠폰을 사용하거나 현금 결제를 하시는 성도님은 주문 후, 카운터로 와주시기 바랍니다.',
                    style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// Tab: 입금계좌 (기존 유지)
/// =======================
class _CafeAccountTab extends StatelessWidget {
  const _CafeAccountTab();

  static const cafeAccount = '신협 131-014-17049-7';
  static const cafeHolder = '예금주 : 대한예수교장로회이룸교회';
  static const copyText = '신협 131-014-17049-7 (예금주 대한예수교장로회이룸교회)';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text('이룸카페 계좌번호', style: TextStyle(fontWeight: FontWeight.w900)),
              SizedBox(height: 10),
              Text(cafeAccount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              SizedBox(height: 8),
              Text(cafeHolder, style: TextStyle(fontSize: 12.5, color: Colors.black45, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kCafePrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: copyText));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('계좌번호가 복사되었습니다.')));
              }
            },
            child: const Text('계좌번호 복사하기', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: Text('※ 주의사항', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900))),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('교회 헌금 계좌로 송금하면 안됩니다.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
              SizedBox(height: 10),
              _DotLine('입금자명은 주문자의 이름을 적어주시기 바랍니다.\n예) 주사랑'),
              SizedBox(height: 8),
              _DotLine('쿠폰을 사용하거나 현금 결제를 하시는 성도님은\n주문 후, 카운터로 와주시기 바랍니다.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _DotLine extends StatelessWidget {
  final String text;
  const _DotLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('/ ', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w900)),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.black54, height: 1.25, fontWeight: FontWeight.w700))),
      ],
    );
  }
}

/// =======================
/// Tab: 나의 주문내역(더미, 옵션 표시 포함)
/// =======================
class _CafeOrdersTab extends ConsumerWidget {
  const _CafeOrdersTab();

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}. '
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(cafeOrdersProvider);

    if (orders.isEmpty) {
      return const Center(child: Text('주문 내역이 없습니다.', style: TextStyle(color: Colors.black45)));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final o = orders[i];
        final first = o.lines.first;
        final title = o.lines.length == 1 ? first.item.name : '${first.item.name} 외 ${o.lines.length - 1}건';

        return Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.grey.shade200,
                    ),
                    child: const Icon(Icons.local_cafe_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text(fmtWon(o.total), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                          first.optionSummary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(_fmtDate(o.createdAt),
                    style: const TextStyle(fontSize: 11.5, color: Colors.black38, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kCafePrimary.withValues(alpha: 0.10),
                    foregroundColor: kCafePrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CafeOrderDetailPage(order: o)));
                  },
                  child: const Text('주문상세내역', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrderConfirmDialog extends StatelessWidget {
  final int totalCups;
  final int totalPrice;

  const _OrderConfirmDialog({required this.totalCups, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('주문 확인'),
      content: Text(
        '총 $totalCups잔이 맞으시나요?\n'
            '주문이 완료되면 메뉴 및 옵션 변경은 어렵습니다.\n\n'
            '결제금액: ${fmtWon(totalPrice)}',
        style: const TextStyle(height: 1.35),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: kCafePrimary, foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('주문하기', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}

/// =======================
/// 주문 상세 페이지(옵션 표시 포함)
/// =======================
class CafeOrderDetailPage extends StatefulWidget {
  final CafeOrder order;
  const CafeOrderDetailPage({super.key, required this.order});

  @override
  State<CafeOrderDetailPage> createState() => _CafeOrderDetailPageState();
}

class _CafeOrderDetailPageState extends State<CafeOrderDetailPage> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmtTime(DateTime? d) {
    if (d == null) return '--:--:--';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final steps = [CafeOrderStage.ordered, CafeOrderStage.making, CafeOrderStage.ready, CafeOrderStage.done];

    DateTime? timeOf(CafeOrderStage s) {
      switch (s) {
        case CafeOrderStage.ordered:
          return order.createdAt;
        case CafeOrderStage.making:
          return order.makingAt;
        case CafeOrderStage.ready:
          return order.readyAt;
        case CafeOrderStage.done:
          return order.doneAt;
      }
    }

    bool isActive(CafeOrderStage s) => s == order.stage;
    bool isDone(CafeOrderStage s) => s.index < order.stage.index;

    return Scaffold(
      appBar: AppBar(title: const Text('교회카페')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          _CafeStageBanner(stage: order.stage, controller: _ctrl),
          const SizedBox(height: 10),
          _OrderSequenceRow(steps: steps, isActive: isActive, isDone: isDone, controller: _ctrl),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final s in steps)
                Expanded(
                  child: Text(_fmtTime(timeOf(s)),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('주문정보', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          for (final l in order.lines) ...[
            _OrderLineRow(
              title: l.item.name,
              sub: l.optionSummary,
              left: '${l.qty}개',
              right: fmtWon(l.lineTotal),
            ),
            const SizedBox(height: 10),
          ],
          const Divider(height: 24),
          _OrderLineRow(title: '결제금액', sub: null, left: '', right: fmtWon(order.total), boldRight: true),
          const SizedBox(height: 8),
          _OrderLineRow(
            title: '최종 결제 금액',
            sub: null,
            left: '',
            right: fmtWon(order.total),
            boldRight: true,
            rightColor: kCafePrimary,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kCafePrimary.withValues(alpha: 0.10),
                foregroundColor: kCafePrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('나의주문내역 돌아가기', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderLineRow extends StatelessWidget {
  final String title;
  final String? sub;
  final String left;
  final String right;
  final bool boldRight;
  final Color? rightColor;

  const _OrderLineRow({
    required this.title,
    required this.sub,
    required this.left,
    required this.right,
    this.boldRight = false,
    this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              if (sub != null) ...[
                const SizedBox(height: 4),
                Text(sub!, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w800)),
              ],
            ],
          ),
        ),
        if (left.isNotEmpty)
          SizedBox(width: 46, child: Text(left, textAlign: TextAlign.right, style: const TextStyle(color: Colors.black54))),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            right,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: boldRight ? FontWeight.w900 : FontWeight.w800,
              color: rightColor ?? (boldRight ? Colors.black87 : Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}

/// =======================
/// 아래 배너/상태 UI는 기존 유지(원본 그대로)
/// =======================
class _OrderSequenceRow extends StatelessWidget {
  final List<CafeOrderStage> steps;
  final bool Function(CafeOrderStage) isActive;
  final bool Function(CafeOrderStage) isDone;
  final AnimationController controller;

  const _OrderSequenceRow({
    required this.steps,
    required this.isActive,
    required this.isDone,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Expanded(
            child: _ProcessChipBlink(
              text: steps[i].label,
              active: isActive(steps[i]),
              done: isDone(steps[i]),
              controller: controller,
            ),
          ),
          if (i != steps.length - 1) ...[
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 16, color: Colors.black38),
            const SizedBox(width: 6),
          ],
        ],
      ],
    );
  }
}

class _ProcessChipBlink extends StatelessWidget {
  final String text;
  final bool active;
  final bool done;
  final AnimationController controller;

  const _ProcessChipBlink({
    required this.text,
    required this.active,
    required this.done,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final doneBg = Colors.grey.shade500;
    final todoBg = Colors.grey.shade200;
    final baseBg = active ? kCafePrimary : (done ? doneBg : todoBg);
    final baseFg = active ? Colors.white : Colors.black87;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final t = controller.value;
        final opacity = active ? (0.80 + 0.20 * t) : 1.0;
        final border = active
            ? Border.all(color: kCafePrimary.withValues(alpha: 0.35 + 0.35 * t), width: 1)
            : Border.all(color: Colors.black12, width: 1);

        return Opacity(
          opacity: opacity,
          child: Container(
            height: 30,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: baseBg,
              borderRadius: BorderRadius.circular(10),
              border: border,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: baseFg,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SteamLine extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  const _SteamLine({required this.controller, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        double t = (controller.value + delay) % 1.0;
        final dy = -10.0 * t;
        final op = (1.0 - t).clamp(0.0, 1.0);

        return Opacity(
          opacity: op,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CafeStageBanner extends StatelessWidget {
  final CafeOrderStage stage;
  final AnimationController controller;

  const _CafeStageBanner({
    required this.stage,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    switch (stage) {
      case CafeOrderStage.ordered:
        return _OrderedBanner(controller: controller);
      case CafeOrderStage.making:
        return _MakingBanner(controller: controller);
      case CafeOrderStage.ready:
        return _ReadyBanner(controller: controller);
      case CafeOrderStage.done:
        return _DoneBanner(controller: controller);
    }
  }
}

class _StageCard extends StatelessWidget {
  final Widget child;
  const _StageCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        color: Colors.grey.shade50,
      ),
      child: child,
    );
  }
}

class _OrderedBanner extends StatelessWidget {
  final AnimationController controller;
  const _OrderedBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _StageCard(
      child: Row(
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (_, _) {
              final t = controller.value;
              final scale = 0.95 + (0.05 * t);
              return Transform.scale(
                scale: scale,
                child: const Icon(Icons.check_circle, size: 44, color: Colors.black87),
              );
            },
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('주문이 접수되었습니다', style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('곧 제조가 시작됩니다. 잠시만 기다려주세요.',
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MakingBanner extends StatelessWidget {
  final AnimationController controller;
  const _MakingBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _StageCard(
      child: Row(
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (_, _) {
              final t = controller.value;
              final dx = (t - 0.5) * 2 * 2.0;
              return Transform.translate(
                offset: Offset(dx, 0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      child: Row(
                        children: [
                          _SteamLine(controller: controller, delay: 0.00),
                          const SizedBox(width: 6),
                          _SteamLine(controller: controller, delay: 0.25),
                          const SizedBox(width: 6),
                          _SteamLine(controller: controller, delay: 0.50),
                        ],
                      ),
                    ),
                    const SizedBox(height: 54),
                    const Icon(Icons.local_cafe, size: 44, color: Colors.black87),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('커피를 제조하고 있습니다', style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('완료되면 “제조완료”로 표시됩니다.',
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyBanner extends StatelessWidget {
  final AnimationController controller;
  const _ReadyBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _StageCard(
      child: Row(
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (_, _) {
              final t = controller.value;
              final angle = (t - 0.5) * 2 * 0.12;
              return Transform.rotate(
                angle: angle,
                child: const Icon(Icons.notifications_active, size: 44, color: Colors.black87),
              );
            },
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('제조가 완료되었습니다', style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('카운터에서 주문자 이름 확인 후 수령해주세요.',
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneBanner extends StatelessWidget {
  final AnimationController controller;
  const _DoneBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _StageCard(
      child: Row(
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (_, _) {
              final t = controller.value;
              final op = 0.7 + 0.3 * t;
              return Opacity(
                opacity: op,
                child: const Icon(Icons.verified, size: 44, color: Colors.black87),
              );
            },
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('수령이 완료되었습니다', style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('이룸카페를 이용해주셔서 감사합니다.',
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}