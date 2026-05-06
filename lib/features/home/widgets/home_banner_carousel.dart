import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/banner_service.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  late final Future<List<BannerData>> _future;
  final _ctrl = PageController();
  int _idx = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _future = BannerService().fetchActive();
  }

  void _startTimer(int count) {
    _timer?.cancel();
    if (count <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_ctrl.hasClients || !mounted) return;
      _idx = (_idx + 1) % count;
      _ctrl.animateToPage(
        _idx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerData>>(
      future: _future,
      builder: (context, snap) {
        final banners = snap.data ?? [];

        if (snap.connectionState == ConnectionState.done && banners.isEmpty) {
          return const SizedBox.shrink();
        }

        if (snap.connectionState == ConnectionState.done && _timer == null) {
          _startTimer(banners.length);
        }

        final count = banners.isEmpty ? 1 : banners.length;

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE7ECF2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: banners.isEmpty
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : PageView.builder(
                          controller: _ctrl,
                          onPageChanged: (i) => setState(() => _idx = i),
                          itemCount: banners.length,
                          itemBuilder: (_, i) {
                            return Image.network(
                              banners[i].imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    size: 42, color: Color(0xFFB7D7E7)),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (banners.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(count, (i) {
                  final active = i == _idx;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF1F7AAE)
                          : const Color(0xFF1F7AAE).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
          ],
        );
      },
    );
  }
}
