import 'package:flutter/material.dart';
import 'package:grit/models/fund.dart';
import 'package:grit/theme/app_colors.dart';
import 'package:grit/utils/formatters.dart';

class PriceTierLabel extends StatelessWidget {
  final List<PriceTier> tiers;
  final int currentParticipants;

  const PriceTierLabel({
    super.key,
    required this.tiers,
    required this.currentParticipants,
  });

  @override
  Widget build(BuildContext context) {
    if (tiers.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < tiers.length; i++)
          _TierItem(
            tier: tiers[i],
            index: i,
            tiersLength: tiers.length,
            currentParticipants: currentParticipants,
          ),
      ],
    );
  }
}

// ─── Single tier item ─────────────────────────────────────────────────────────

class _TierItem extends StatelessWidget {
  final PriceTier tier;
  final int index;
  final int tiersLength;
  final int currentParticipants;

  const _TierItem({
    required this.tier,
    required this.index,
    required this.tiersLength,
    required this.currentParticipants,
  });

  bool get _achieved => currentParticipants >= tier.minParticipants;

  String get _label {
    if (index == 0) return '시작가';
    if (index == tiersLength - 1) {
      return '${formatNumber(tier.minParticipants)}개 달성 시';
    }
    return '${formatNumber(tier.minParticipants)}개';
  }

  CrossAxisAlignment get _alignment {
    if (index == 0) return CrossAxisAlignment.start;
    if (index == tiersLength - 1) return CrossAxisAlignment.end;
    return CrossAxisAlignment.center;
  }

  TextAlign get _textAlign {
    if (index == 0) return TextAlign.start;
    if (index == tiersLength - 1) return TextAlign.end;
    return TextAlign.center;
  }

  @override
  Widget build(BuildContext context) {
    final color = _achieved ? AppColors.primary : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: _alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _label,
          textAlign: _textAlign,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: _achieved ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatPrice(tier.price),
          textAlign: _textAlign,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
