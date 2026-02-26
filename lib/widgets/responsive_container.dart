import 'package:flutter/material.dart';
import '../theme/app_breakpoints.dart';

/// Responsive wrapper that constrains content width and applies padding.
/// Use this on every screen to ensure consistent responsive behavior.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  /// For content pages (home, category, dashboard)
  const ResponsiveContainer.content({
    super.key,
    required this.child,
  })  : maxWidth = AppBreakpoints.maxContentWidth,
        padding = null;

  /// For form pages (login, profile, inquiry, seller form)
  const ResponsiveContainer.form({
    super.key,
    required this.child,
  })  : maxWidth = AppBreakpoints.maxFormWidth,
        padding = null;

  /// For login/auth pages
  const ResponsiveContainer.auth({
    super.key,
    required this.child,
  })  : maxWidth = AppBreakpoints.maxLoginWidth,
        padding = null;

  /// For detail pages
  const ResponsiveContainer.detail({
    super.key,
    required this.child,
  })  : maxWidth = AppBreakpoints.maxDetailWidth,
        padding = null;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: AppBreakpoints.horizontalPadding(context),
        );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? AppBreakpoints.maxContentWidth,
        ),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}
