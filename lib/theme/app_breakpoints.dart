import 'package:flutter/widgets.dart';

/// GRIT Design System — Responsive Breakpoints
/// 기존 4종류(768, 800, 960px) → 3단계로 통일
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 960;

  // Max-width constraints for content areas
  static const double maxContentWidth = 960.0;
  static const double maxFormWidth = 560.0;
  static const double maxLoginWidth = 400.0;
  static const double maxDetailWidth = 1080.0;
  static const double maxPageWidth = 1280.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobile && w < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static int gridColumns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < mobile) return 2;
    if (w < tablet) return 3;
    return 4;
  }

  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < mobile) return 16.0;
    if (w < tablet) return 20.0;
    return 24.0;
  }
}
