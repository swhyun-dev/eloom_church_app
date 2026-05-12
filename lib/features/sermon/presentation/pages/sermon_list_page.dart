import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/sermon.dart';
import '../../domain/models/sermon_category.dart';
import '../providers/sermon_providers.dart';

/// 백엔드에 등록된 설교 모음 (카테고리 필터). 외부 URL 기반 sermon_board_page와는
/// 별도이며, 라우터 `/sermon/list` 로 진입한다.
class SermonListPage extends ConsumerStatefulWidget {
  const SermonListPage({super.key});

  @override
  ConsumerState<SermonListPage> createState() => _SermonListPageState();
}

class _SermonListPageState extends ConsumerState<SermonListPage> {
  SermonCategory? _category;

  Future<void> _openYoutube(BuildContext context, String idOrUrl) async {
    final raw = idOrUrl.trim();
    final url = raw.startsWith('http')
        ? raw
        : 'https://www.youtube.com/watch?v=$raw';
    final ok = await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('영상을 열 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(sermonsByCategoryProvider(_category));

    return Scaffold(
      appBar: AppBar(title: const Text('설교 모음')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: '전체',
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                for (final c in SermonCategory.values)
                  _FilterChip(
                    label: c.label,
                    selected: _category == c,
                    onTap: () => setState(() => _category = c),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: AsyncValueBuilder<List<Sermon>>(
              value: async,
              onRetry: () =>
                  ref.invalidate(sermonsByCategoryProvider(_category)),
              isEmpty: (l) => l.isEmpty,
              emptyMessage: '등록된 설교가 없습니다.',
              builder: (items) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final s = items[i];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                      title: Text(s.title,
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${s.category.label}'
                            '${s.speaker != null ? '  ·  ${s.speaker}' : ''}'
                            '${s.bibleText != null ? '  ·  ${s.bibleText}' : ''}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${s.preachedAt.year}/${s.preachedAt.month.toString().padLeft(2, '0')}/${s.preachedAt.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                      trailing: s.youtubeId != null
                          ? IconButton(
                              tooltip: '영상 열기',
                              icon: const Icon(Icons.play_circle_outline,
                                  size: 28, color: Colors.red),
                              onPressed: () =>
                                  _openYoutube(context, s.youtubeId!),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
