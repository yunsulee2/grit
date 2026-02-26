import 'package:flutter/material.dart';
import 'app_colors.dart';

/// GRIT Design System — Typography Tokens (Compact scale)
///
/// Font strategy:
///   Body / UI: "Noto Sans KR" — Korean + Latin, clean, highly legible
///
/// All sizes reduced 20-30% from original for compact, modern feel.
/// Grid: 4pt baseline (line heights are multiples of 4)

class AppFonts {
  AppFonts._();

  static const body = 'NotoSansKR';
}

class AppTextStyles {
  AppTextStyles._();

  // ── Display ─────────────────────────────────────────────────────────────
  /// Hero numbers, splash headlines
  static const displayLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Section hero, large counters
  static const displayMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  // ── Title ───────────────────────────────────────────────────────────────
  /// Page titles
  static const titleLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Section titles, modal headers
  static const titleMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  /// Card section headers, sub-titles
  static const titleSmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ── Body ────────────────────────────────────────────────────────────────
  /// Standard body copy, product descriptions
  static const bodyLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Secondary body, list items, card metadata
  static const bodyMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// Small body, footnotes
  static const bodySmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // ── Label ───────────────────────────────────────────────────────────────
  /// Button labels, emphasis text
  static const labelLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Chip labels, filter tags, input labels
  static const labelMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Small labels, nav items, badges
  static const labelSmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  // ── Caption ─────────────────────────────────────────────────────────────
  /// Timestamps, footnotes, helper text
  static const caption = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  // ── Price ───────────────────────────────────────────────────────────────
  /// Hero price on detail page
  static const priceHero = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// Card price
  static const priceCard = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Strikethrough original price
  static const priceStrike = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textTertiary,
    decoration: TextDecoration.lineThrough,
    decorationColor: AppColors.textTertiary,
  );

  /// Discount percentage
  static const discountBadge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.priceRed,
  );

  // ── Countdown ───────────────────────────────────────────────────────────
  /// Countdown timer digits
  static const countdown = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  /// Small inline countdown (card badge)
  static const countdownSmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.3,
    color: AppColors.textInverse,
  );

  // ── Logo ────────────────────────────────────────────────────────────────
  /// GRIT wordmark
  static const logo = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    height: 1.0,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );
}
