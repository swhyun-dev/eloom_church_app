import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/links.dart';

class SermonLivePage extends StatelessWidget {
  const SermonLivePage({super.key});

  Future<void> _openLive() async {
    final uri = Uri.parse(AppLinks.sermonLiveUrl);

    // externalApplication: 유튜브 앱/브라우저로 열기 (가장 안정적)
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      // fallback (외부 열기 실패 시)
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('유튜브 실시간 생방송')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주일예배 Live',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              '아래 버튼을 누르면 유튜브 라이브로 이동합니다.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openLive,
                icon: const Icon(Icons.live_tv),
                label: const Text('라이브 바로가기'),
              ),
            ),

            const SizedBox(height: 12),
            Text(
              AppLinks.sermonLiveUrl,
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
