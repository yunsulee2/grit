import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';

enum BadgeType {
  active,
  endingSoon,
  completed,
  freeShipping,
  custom,
}

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final Color? customBgColor;
  final Color? customTextColor;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
    this.customBgColor,
    this.customTextColor,
  });

  const StatusBadge.active({
    super.key,
    required this.text,
  })  : type = BadgeType.active,
        customBgColor = null,
        customTextColor = null;

  const StatusBadge.endingSoon({
    super.key,
    required this.text,
  })  : type = BadgeType.endingSoon,
        customBgColor = null,
        customTextColor = null;

  const StatusBadge.completed({
    super.key,
    required this.text,
  })  : type = BadgeType.completed,
        customBgColor = null,
        customTextColor = null;

  const StatusBadge.freeShipping({
    super.key,
    required this.text,
  })  : type = BadgeType.freeShipping,
        customBgColor = null,
        customTextColor = null;

  Color get _bgColor {
    switch (type) {
      case BadgeType.active:
        return AppColors.primary;
      case BadgeType.endingSoon:
        return AppColors.error;
      case BadgeType.completed:
        return AppColors.success;
      case BadgeType.freeShipping:
        return AppColors.borderSubtle;
      case BadgeType.custom:
        return customBgColor ?? AppColors.primary;
    }
  }

  Color get _textColor {
    switch (type) {
      case BadgeType.active:
      case BadgeType.endingSoon:
      case BadgeType.completed:
        return AppColors.surface;
      case BadgeType.freeShipping:
        return AppColors.textSecondary;
      case BadgeType.custom:
        return customTextColor ?? AppColors.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: _textColor,
          height: 1.4,
        ),
      ),
    );
  }
}
