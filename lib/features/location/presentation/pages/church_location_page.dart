import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

class _LocationBody extends StatefulWidget {
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
  State<_LocationBody> createState() => _LocationBodyState();
}

class _LocationBodyState extends State<_LocationBody> {
  WebViewController? _mapController;

  @override
  void initState() {
    super.initState();
    final lat = widget.info.mapLatitude;
    final lng = widget.info.mapLongitude;
    final query = (lat != null && lng != null)
        ? '$lat,$lng'
        : widget.info.fullAddress;
    // Google Maps embed — API 키 불필요. 한국 지명 정상 표시.
    final url =
        'https://www.google.com/maps?q=${Uri.encodeComponent(query)}&z=16&output=embed';

    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        // ✅ 지도
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SizedBox(
                height: 260,
                child: _mapController == null
                    ? const Center(child: CircularProgressIndicator())
                    : WebViewWidget(controller: _mapController!),
              ),
              // 외부 지도 앱 빠른 진입
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final url = info.kakaoMapUrl?.isNotEmpty == true
                              ? info.kakaoMapUrl!
                              : 'https://map.kakao.com/?q=${Uri.encodeComponent(info.fullAddress)}';
                          widget.onOpenMap(url);
                        },
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('카카오맵으로 열기'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final url = info.naverMapUrl?.isNotEmpty == true
                              ? info.naverMapUrl!
                              : 'https://map.naver.com/v5/search/${Uri.encodeComponent(info.fullAddress)}';
                          widget.onOpenMap(url);
                        },
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('네이버지도'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

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
                OutlinedButton.icon(
                  onPressed: () => widget.onCopy(info.fullAddress),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('주소 복사'),
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
                  onTap: () => widget.onCall(info.phone!),
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
