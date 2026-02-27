import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';

/// Bottom sheet showing step-by-step guide on how to find and copy a product link.
class LinkHelpSheet extends StatelessWidget {
  const LinkHelpSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const LinkHelpSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppRadius.borderFull,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              '링크 복사하는 법',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Step 1
            _HelpStep(
              step: 1,
              icon: Icons.shopping_bag_outlined,
              title: '쇼핑몰에서 상품을 찾으세요',
              description: '쿠팡, 네이버 등 쇼핑몰 앱이나 사이트에서\n등록할 상품 페이지를 열어주세요',
            ),

            const SizedBox(height: AppSpacing.lg),

            // Step 2
            _HelpStep(
              step: 2,
              icon: Icons.share_outlined,
              title: '공유 버튼을 누르세요',
              description: '상품 페이지에서 공유(↗) 버튼을 찾아\n눌러주세요',
            ),

            const SizedBox(height: AppSpacing.lg),

            // Step 3
            _HelpStep(
              step: 3,
              icon: Icons.content_copy,
              title: '\'링크 복사\'를 선택하세요',
              description: '공유 메뉴에서 \'링크 복사\' 또는\n\'URL 복사\'를 눌러주세요',
            ),

            const SizedBox(height: AppSpacing.lg),

            // Step 4
            _HelpStep(
              step: 4,
              icon: Icons.paste,
              title: '여기서 \'붙여넣기\'를 누르세요',
              description: '이 화면으로 돌아와서\n\'붙여넣기\' 버튼을 눌러주세요',
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Supported sites
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    '지원 쇼핑몰',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SiteLogo(label: '쿠팡', color: const Color(0xFFE8192C)),
                      const SizedBox(width: AppSpacing.lg),
                      _SiteLogo(label: '네이버', color: const Color(0xFF03C75A)),
                      const SizedBox(width: AppSpacing.lg),
                      _SiteLogo(label: '카카오', color: const Color(0xFFFFE000), darkText: true),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '그 외 쇼핑몰도 시도해 보세요',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Close button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderSm,
                  ),
                ),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpStep extends StatelessWidget {
  final int step;
  final IconData icon;
  final String title;
  final String description;

  const _HelpStep({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number circle
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.textPrimary),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SiteLogo extends StatelessWidget {
  final String label;
  final Color color;
  final bool darkText;

  const _SiteLogo({
    required this.label,
    required this.color,
    this.darkText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: darkText ? AppColors.textPrimary : Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
