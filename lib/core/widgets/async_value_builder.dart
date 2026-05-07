import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_view.dart';
import 'error_view.dart';

/// Riverpod AsyncValue를 표준 loading/error/empty/data 분기 UI로 렌더링.
///
/// 사용 예:
/// ```
/// AsyncValueBuilder<List<Notice>>(
///   value: ref.watch(noticeListProvider),
///   onRetry: () => ref.invalidate(noticeListProvider),
///   emptyMessage: '등록된 공지가 없습니다.',
///   builder: (notices) => ListView.builder(...),
/// )
/// ```
class AsyncValueBuilder<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  /// data가 비었는지 판정. List/Iterable이면 자동(`isEmpty`), 아니면 직접 지정.
  final bool Function(T data)? isEmpty;
  final String? emptyMessage;

  /// 에러 시 재시도 콜백. null이면 버튼 미표시.
  final VoidCallback? onRetry;

  /// 로딩 위젯 커스터마이즈 (기본: CircularProgressIndicator 중앙).
  final Widget? loading;

  const AsyncValueBuilder({
    super.key,
    required this.value,
    required this.builder,
    this.isEmpty,
    this.emptyMessage,
    this.onRetry,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading ?? const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: _humanize(e),
        onRetry: onRetry,
      ),
      data: (data) {
        if (_checkEmpty(data)) {
          return EmptyView(message: emptyMessage ?? '표시할 내용이 없습니다.');
        }
        return builder(data);
      },
    );
  }

  bool _checkEmpty(T data) {
    if (isEmpty != null) return isEmpty!(data);
    if (data is Iterable) return data.isEmpty;
    if (data is Map) return data.isEmpty;
    return false;
  }

  String _humanize(Object e) {
    final s = e.toString();
    return s.startsWith('Exception: ') ? s.substring('Exception: '.length) : s;
  }
}
