import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../widgets/responsive_container.dart';
import '../data/mock_data.dart';
import '../models/fund.dart';
import '../widgets/share_buttons.dart';
import '../utils/formatters.dart';
import '../widgets/fund_image.dart';

class PaymentCompleteScreen extends StatelessWidget {
  final String fundId;

  const PaymentCompleteScreen({super.key, required this.fundId});

  Fund? _findFund() {
    try {
      return mockFunds.firstWhere((f) => f.id == fundId);
    } catch (_) {
      return mockFunds.isNotEmpty ? mockFunds[0] : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fund = _findFund();

    // Derive tier info
    int currentTierIndex = 0;
    int nextTierPrice = 0;
    int neededParticipants = 0;

    if (fund != null && fund.tiers.isNotEmpty) {
      for (int i = fund.tiers.length - 1; i >= 0; i--) {
        if (fund.currentParticipants >= fund.tiers[i].minParticipants) {
          currentTierIndex = i + 1; // 1-based
          break;
        }
      }
      // Find next tier
      for (int i = 0; i < fund.tiers.length; i++) {
        if (fund.currentParticipants < fund.tiers[i].minParticipants) {
          nextTierPrice = fund.tiers[i].price;
          neededParticipants =
              fund.tiers[i].minParticipants - fund.currentParticipants;
          break;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('참여 완료'),
        leading: const BackButton(),
      ),
      body: fund == null
          ? Center(
              child: Text(
                '상품 정보를 찾을 수 없습니다',
                style: AppTextStyles.bodyLarge,
              ),
            )
          : ResponsiveContainer.form(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxxxl),
                    // Success icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.surface,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Title
                    Text(
                      '참여 완료!',
                      style: AppTextStyles.displayMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Subtitle
                    Text(
                      '공동구매에 참여해 주셔서 감사합니다',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Order info card
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product row
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: AppRadius.borderSm,
                                  child: FundImage(
                                    imageUrl: fund.imageUrl,
                                    width: 64,
                                    height: 64,
                                    errorIcon: Icons.image,
                                    errorIconSize: 24,
                                    errorIconColor: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fund.productName,
                                        style: AppTextStyles.titleSmall,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        fund.brandName,
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const Divider(height: 1),
                            const SizedBox(height: AppSpacing.lg),
                            // Price row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '결제 금액',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${formatPrice(fund.startPrice)} (시작가 기준)',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Status row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '현재 단계',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    '$currentTierIndex단계 진행 중 - 최종 가격이 더 내려갈 수 있어요!',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Share promotion section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderMd,
                        ),
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: [
                            Text(
                              neededParticipants > 0
                                  ? '$neededParticipants명만 더 모이면 가격이 ${formatPrice(nextTierPrice)}으로!'
                                  : '최저가 달성! 친구들에게 공유해 보세요',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '친구에게 공유하면 함께 더 싸게 살 수 있어요',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            ShareButtons(
                              shareUrl: 'https://grit.app/funds/${fund.id}',
                              productName: fund.productName,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Bottom buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).popUntil(
                                  (route) =>
                                      route.settings.name == '/my-page' ||
                                      route.isFirst,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.borderSm,
                                ),
                              ),
                              child: Text(
                                '주문 내역 보기',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            child: Text(
                              '홈으로',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
    );
  }
}
