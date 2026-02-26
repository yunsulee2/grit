import 'package:flutter/material.dart';
import '../models/extracted_product.dart';
import '../theme/app_colors.dart';

class ExtractionStatusIcon extends StatelessWidget {
  final ExtractionConfidence confidence;
  final double size;

  const ExtractionStatusIcon({
    super.key,
    required this.confidence,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _icon,
      color: _color,
      size: size,
    );
  }

  IconData get _icon {
    switch (confidence) {
      case ExtractionConfidence.high:
        return Icons.check_circle;
      case ExtractionConfidence.medium:
        return Icons.warning_amber_rounded;
      case ExtractionConfidence.low:
        return Icons.help_outline;
      case ExtractionConfidence.failed:
        return Icons.cancel;
    }
  }

  Color get _color {
    switch (confidence) {
      case ExtractionConfidence.high:
        return AppColors.success;
      case ExtractionConfidence.medium:
        return AppColors.warning;
      case ExtractionConfidence.low:
        return AppColors.textSecondary;
      case ExtractionConfidence.failed:
        return AppColors.error;
    }
  }
}
