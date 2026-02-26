import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.overlayBadge,
  });

  final List<String> imageUrls;
  final Widget? overlayBadge;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.imageUrls.length;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: total,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _ImagePage(url: widget.imageUrls[index]);
            },
          ),

          // Dot indicators — bottom center
          if (total > 1)
            Positioned(
              bottom: AppSpacing.md,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(total, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.textInverse
                          : AppColors.textInverse.withValues(alpha: 0.5),
                      borderRadius: AppRadius.borderFull,
                    ),
                  );
                }),
              ),
            ),

          // Counter badge — bottom right
          if (total > 1)
            Positioned(
              bottom: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  '${_currentIndex + 1}/$total',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Overlay badge slot — top left (e.g. countdown timer)
          if (widget.overlayBadge != null)
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: widget.overlayBadge!,
            ),
        ],
      ),
    );
  }
}

class _ImagePage extends StatelessWidget {
  const _ImagePage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, _) => Container(
        color: AppColors.border,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
