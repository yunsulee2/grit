import 'package:flutter/material.dart';
import '../models/fund.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import 'volume_pricing_bar.dart';
import 'price_tier_label.dart';

class PriceTierPreview extends StatelessWidget {
  final List<PriceTier> tiers;
  final int maxParticipants;

  const PriceTierPreview({
    super.key,
    required this.tiers,
    required this.maxParticipants,
  });

  @override
  Widget build(BuildContext context) {
    final safeTiers = tiers.isEmpty
        ? [const PriceTier(minParticipants: 1, price: 0)]
        : tiers;
    final safeMax = maxParticipants <= 0 ? 100 : maxParticipants;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.borderMd,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '미리보기',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          VolumePricingBar(
            tiers: safeTiers,
            currentParticipants: 0,
            maxParticipants: safeMax,
            isLarge: true,
          ),
          const SizedBox(height: AppSpacing.md),
          PriceTierLabel(
            tiers: safeTiers,
            currentParticipants: 0,
          ),
        ],
      ),
    );
  }
}
