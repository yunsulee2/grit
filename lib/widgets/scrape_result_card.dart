import 'package:flutter/material.dart';
import '../models/extracted_product.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../utils/formatters.dart';
import '../services/site_detector.dart';
import '../services/scrape_service.dart';

/// Compact card showing extracted product summary.
/// Used inline in Step 0 after successful scraping.
class ScrapeResultCard extends StatelessWidget {
  final ExtractedProduct product;
  final VoidCallback onAccept;
  final VoidCallback onEdit;

  const ScrapeResultCard({
    super.key,
    required this.product,
    required this.onAccept,
    required this.onEdit,
  });

  int get _imageCount {
    int count = 0;
    if (product.mainImage.value != null) count++;
    count += product.galleryImages.value?.length ?? 0;
    count += product.detailImages.value?.length ?? 0;
    return count;
  }

  int get _optionCount {
    final opts = product.options.value;
    if (opts == null) return 0;
    return opts.fold<int>(0, (sum, o) => sum + o.values.length);
  }

  String get _thumbnailUrl {
    final main = product.mainImage.value;
    if (main != null && main.isNotEmpty) return ScrapeService.proxyImageUrl(main);
    final gallery = product.galleryImages.value;
    if (gallery != null && gallery.isNotEmpty) return ScrapeService.proxyImageUrl(gallery.first);
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final site = SiteDetector.detect(product.sourceUrl);
    final name = product.productName.value ?? '상품명 없음';
    final brand = product.brandName.value;
    final category = product.category.value;
    final price = product.originalPrice.value;
    final imgCount = _imageCount;
    final optCount = _optionCount;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.success, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success header
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '상품 정보를 가져왔어요!',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Product info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: AppRadius.borderSm,
                child: _thumbnailUrl.isNotEmpty
                    ? Image.network(
                        _thumbnailUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),

              const SizedBox(width: AppSpacing.md),

              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (brand != null && brand.isNotEmpty) brand,
                        if (category != null && category.isNotEmpty) category,
                      ].join(' · '),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (price != null && price > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '원가 ${formatPrice(price)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Site badge
              _SiteBadgeSmall(site: site),
            ],
          ),

          // Extracted summary chips
          if (imgCount > 0 || optCount > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                if (imgCount > 0)
                  _InfoChip(icon: Icons.image_outlined, label: '이미지 $imgCount장'),
                if (optCount > 0)
                  _InfoChip(icon: Icons.tune, label: '옵션 $optCount개'),
                if (product.nutritionInfo.value != null)
                  _InfoChip(icon: Icons.restaurant_outlined, label: '영양정보'),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderSm,
                      ),
                    ),
                    child: const Text('수정하면서 시작'),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderSm,
                      ),
                    ),
                    child: const Text('이대로 시작하기'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.background,
      child: const Icon(Icons.image_outlined, color: AppColors.textTertiary, size: 28),
    );
  }
}

class _SiteBadgeSmall extends StatelessWidget {
  final SupportedSite site;
  const _SiteBadgeSmall({required this.site});

  Color get _color {
    switch (site) {
      case SupportedSite.coupang:
        return const Color(0xFFE8192C);
      case SupportedSite.naver:
        return const Color(0xFF03C75A);
      case SupportedSite.kakao:
        return const Color(0xFFFFE000);
      case SupportedSite.other:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        SiteDetector.displayName(site),
        style: AppTextStyles.labelSmall.copyWith(
          color: _color == const Color(0xFFFFE000) ? AppColors.textPrimary : _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
