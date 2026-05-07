import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../banner/domain/models/banner_slot.dart';
import '../../banner/presentation/providers/banner_providers.dart';

class HomeBannerCarousel extends ConsumerStatefulWidget {
  const HomeBannerCarousel({super.key});

  @override
  ConsumerState<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends ConsumerState<HomeBannerCarousel> {
  final _ctrl = PageController();
  int _idx = 0;
  Timer? _timer;
  int _lastTimerCount = 0;

  void _ensureTimer(int count) {
    if (count == _lastTimerCount) return;
    _lastTimerCount = count;
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
    final async = ref.watch(activeBannersProvider);

    return async.when(
      loading: () => _frame(
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();
        _ensureTimer(banners.length);

        return Column(
          children: [
            _frame(
              PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _idx = i),
                itemCount: banners.length,
                itemBuilder: (_, i) => _BannerImage(banner: banners[i]),
              ),
            ),
            const SizedBox(height: 8),
            if (banners.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(banners.length, (i) {
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

  Widget _frame(Widget child) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7ECF2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 7,
            child: child,
          ),
        ),
      );
}

class _BannerImage extends StatelessWidget {
  final BannerSlot banner;
  const _BannerImage({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      banner.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Center(
        child: Icon(Icons.broken_image_outlined, size: 42, color: Color(0xFFB7D7E7)),
      ),
    );
  }
}
