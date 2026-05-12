import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/async_value_builder.dart';
import '../../domain/models/church_info.dart';
import '../providers/church_info_providers.dart';

class ChurchLocationPage extends ConsumerWidget {
  const ChurchLocationPage({super.key});

  Future<void> _call(BuildContext context, String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('전화 발신을 시작할 수 없습니다. ($phone)')),
        );
      }
    }
  }

  Future<void> _openMap(BuildContext context, String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('지도를 열 수 없습니다.')),
        );
      }
    }
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('주소가 복사되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(churchInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('오시는길')),
      body: AsyncValueBuilder<ChurchInfo?>(
        value: async,
        onRetry: () => ref.invalidate(churchInfoProvider),
        isEmpty: (info) => info == null,
        emptyMessage: '교회 정보를 불러올 수 없습니다.',
        builder: (info) => _LocationBody(
          info: info!,
          onCall: (p) => _call(context, p),
          onOpenMap: (u) => _openMap(context, u),
          onCopy: (t) => _copy(context, t),
        ),
      ),
    );
  }
}

class _LocationBody extends StatelessWidget {
  final ChurchInfo info;
  final void Function(String phone) onCall;
  final void Function(String url) onOpenMap;
  final void Function(String text) onCopy;

  const _LocationBody({
    required this.info,
    required this.onCall,
    required this.onOpenMap,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _SectionTitle('주소'),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.fullAddress,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, height: 1.5)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => onCopy(info.fullAddress),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('주소 복사'),
                    ),
                    if (info.naverMapUrl != null &&
                        info.naverMapUrl!.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () => onOpenMap(info.naverMapUrl!),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('네이버지도'),
                      ),
                    if (info.kakaoMapUrl != null &&
                        info.kakaoMapUrl!.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () => onOpenMap(info.kakaoMapUrl!),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('카카오맵'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _SectionTitle('연락처'),
        Card(
          child: Column(
            children: [
              if (info.phone != null && info.phone!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(info.phone!,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('전화'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onCall(info.phone!),
                ),
              if (info.fax != null && info.fax!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.print_outlined),
                  title: Text(info.fax!,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('팩스'),
                ),
              if (info.email != null && info.email!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(info.email!,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('이메일'),
                ),
            ],
          ),
        ),
        if (info.parkingGuide != null && info.parkingGuide!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SectionTitle('주차 안내'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(info.parkingGuide!,
                  style: const TextStyle(height: 1.6)),
            ),
          ),
        ],
        if (info.trafficGuide != null && info.trafficGuide!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SectionTitle('교통편'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(info.trafficGuide!,
                  style: const TextStyle(height: 1.6)),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
    );
  }
}
