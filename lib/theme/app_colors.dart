import 'package:flutter/material.dart';

/// GRIT Design System — Color Tokens (Light Theme)
/// Aesthetic: "Clean Performance" — 깨끗하고 기능적인 피트니스 커머스
/// Target: Health-conscious Korean millennials & Gen-Z
///
/// Palette story:
///   White (#FFFFFF) — 순백. 신뢰감. 신선함.
///   Charcoal (#1A1A1A) — 강렬한 텍스트. 전문성.
///   Acid Lime (#C6F135) — 브랜드 에너지. CTA 포인트.
///   Price Red (#FF3B30) — 할인율. 긴박감. 구매 전환.

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────
  /// Primary brand color — 검정 기반 CTA, 강조
  static const primary = Color(0xFF1A1A1A);

  /// Accent — Acid Lime. 포인트 CTA, 프로모션, 브랜드 시그니처
  static const accent = Color(0xFFC6F135);

  /// Accent hover/pressed
  static const accentDark = Color(0xFF9BBF00);

  /// Accent muted (배지, 칩 배경)
  static const accentMuted = Color(0xFFF5FBDE);

  /// Text on primary buttons (white on dark)
  static const onPrimary = Color(0xFFFFFFFF);

  /// Text on accent buttons (dark on lime)
  static const onAccent = Color(0xFF1A1A1A);

  // ── Background ─────────────────────────────────────────────────────────
  /// App scaffold background
  static const background = Color(0xFFFFFFFF);

  /// Card/section surface
  static const surface = Color(0xFFF7F8F9);

  /// Elevated surface (modals, bottom sheets)
  static const surfaceElevated = Color(0xFFFFFFFF);

  /// Tinted surface (GNB, sticky bars)
  static const surfaceTinted = Color(0xFFFAFAFA);

  // ── Text ───────────────────────────────────────────────────────────────
  /// Primary text (headings, product names, prices)
  static const textPrimary = Color(0xFF1A1A1A);

  /// Secondary text (metadata, descriptions, labels)
  static const textSecondary = Color(0xFF8E8E93);

  /// Tertiary/disabled text (placeholders, inactive)
  static const textTertiary = Color(0xFFAEAEB2);

  /// Inverse text (on dark backgrounds)
  static const textInverse = Color(0xFFFFFFFF);

  // ── Semantic ───────────────────────────────────────────────────────────
  /// Error / urgency — price discount, countdown, FOMO
  static const error = Color(0xFFFF3B30);
  static const errorMuted = Color(0xFFFFF0EF);

  /// Success — confirmed, completed
  static const success = Color(0xFF34C759);
  static const successMuted = Color(0xFFECFDF3);

  /// Warning — attention needed
  static const warning = Color(0xFFFF9500);
  static const warningMuted = Color(0xFFFFF8EC);

  /// Info — links, secondary actions
  static const info = Color(0xFF007AFF);
  static const infoMuted = Color(0xFFEBF5FF);

  // ── Border ─────────────────────────────────────────────────────────────
  /// Default border (cards, inputs)
  static const border = Color(0xFFE5E5EA);

  /// Subtle divider (between list items)
  static const borderSubtle = Color(0xFFF2F2F7);

  /// Focus/active border
  static const borderFocus = Color(0xFF1A1A1A);

  // ── Price ──────────────────────────────────────────────────────────────
  /// Discount percentage color
  static const priceRed = Color(0xFFFF3B30);

  /// Special deal accent badge background
  static const priceAccentBg = Color(0xFFC6F135);

  // ── Shadow ─────────────────────────────────────────────────────────────
  /// Card shadow color
  static const shadowLight = Color(0x0A000000);
  static const shadowMedium = Color(0x12000000);

  // ── Gradient Definitions ───────────────────────────────────────────────
  /// Primary CTA gradient
  static const gradientPrimary = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF1A1A1A), Color(0xFF333333)],
  );

  /// Accent gradient (lime sweep)
  static const gradientAccent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFC6F135), Color(0xFF9BBF00)],
  );

  /// Urgency gradient (ending-soon banners)
  static const gradientUrgency = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF3B30), Color(0xFFFF9500)],
  );

  /// Image scrim (bottom-to-top dark overlay)
  static const gradientScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0x99000000)],
  );

}
