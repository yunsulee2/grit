import 'package:flutter/material.dart';

/// GRIT Design System — Border Radius Tokens
/// 11가지 → 5가지로 통일
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double full = 999.0;

  // Pre-built BorderRadius for convenience
  static final borderXs = BorderRadius.circular(xs);
  static final borderSm = BorderRadius.circular(sm);
  static final borderMd = BorderRadius.circular(md);
  static final borderLg = BorderRadius.circular(lg);
  static final borderFull = BorderRadius.circular(full);
}
