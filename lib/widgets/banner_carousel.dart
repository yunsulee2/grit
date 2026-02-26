import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_colors.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late Timer _autoPlayTimer;

  final List<_BannerData> _banners = [
    _BannerData(
      title: '피트니스 식품 공동구매',
      subtitle: '같이 사면 더 싸다!\n최대 30% 할인',
      gradient: [AppColors.primary, const Color(0xFFFF8F65)],
      icon: Icons.fitness_center,
    ),
    _BannerData(
      title: '신규 오픈 이벤트',
      subtitle: '첫 구매 시\n2,000원 즉시 할인',
      gradient: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      icon: Icons.card_giftcard,
    ),
    _BannerData(
      title: '닭가슴살 특가전',
      subtitle: '이번 주 베스트\n닭가슴살 모음',
      gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      icon: Icons.local_fire_department,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_controller.hasClients) {
        final next = (_currentPage + 1) % _banners.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: banner.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            banner.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            banner.subtitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      banner.icon,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              );
            },
          ),
          // Dot indicator
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _banners.length,
                (i) => Container(
                  width: i == _currentPage ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;

  _BannerData({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });
}
