import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
        return AppColors.accentRed;
      case BadgeType.completed:
        return AppColors.successGreen;
      case BadgeType.freeShipping:
        return const Color(0xFFF0F0F0);
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textColor,
          height: 1.4,
        ),
      ),
    );
  }
}
