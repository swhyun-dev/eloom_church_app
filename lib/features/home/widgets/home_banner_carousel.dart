import 'dart:async';
import 'package:flutter/material.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  final _ctrl = PageController();
  int _idx = 0;
  Timer? _timer;

  // ✅ assets/images 폴더의 파일명으로 수정하세요
  final banners = const [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_ctrl.hasClients) return;
      _idx = (_idx + 1) % banners.length;
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
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _idx = i),
                itemCount: banners.length,
                itemBuilder: (_, i) {
                  return Image.asset(
                    banners[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 42,
                          color: Color(0xFFB7D7E7),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

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
                color: active ? const Color(0xFF1F7AAE) : const Color(0xFF1F7AAE).withOpacity(0.18),
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}
