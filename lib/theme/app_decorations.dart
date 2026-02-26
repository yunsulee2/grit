import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// GRIT Design System — Shared Decorations
/// 카드, 인풋, 버튼 등 공통 BoxDecoration/InputDecoration

class AppDecorations {
  AppDecorations._();

  // ── Card Styles ────────────────────────────────────────────────────────

  /// Default card — subtle shadow, no border
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderMd,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Color(0x05000000),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      );

  /// Elevated card — hover/featured state
  static BoxDecoration get cardElevated => BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderMd,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      );

  /// Flat card — with border, no shadow (for form sections)
  static BoxDecoration get cardFlat => BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border),
      );

  /// Surface section — subtle background
  static BoxDecoration get section => BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
      );

  // ── Input Decoration ───────────────────────────────────────────────────

  /// Unified input decoration for all form fields
  static InputDecoration input({
    String? hint,
    String? label,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        hintText: hint,
        labelText: label,
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 15,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
      );

  // ── Badge ──────────────────────────────────────────────────────────────

  /// Small tag/badge decoration
  static BoxDecoration badge({Color? color}) => BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: AppRadius.borderXs,
        border: Border.all(color: AppColors.border),
      );

  /// Accent badge (e.g. 추천, NEW)
  static BoxDecoration get badgeAccent => BoxDecoration(
        color: AppColors.accent,
        borderRadius: AppRadius.borderFull,
      );

  /// Status badge with custom color
  static BoxDecoration statusBadge(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderFull,
      );
}
