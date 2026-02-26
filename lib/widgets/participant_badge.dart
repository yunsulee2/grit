import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';

class ParticipantBadge extends StatelessWidget {
  final int count;
  final double progressPercent;

  const ParticipantBadge({
    super.key,
    required this.count,
    required this.progressPercent,
  });

  String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    int start = s.length % 3;
    if (start > 0) {
      buffer.write(s.substring(0, start));
    }
    for (int i = start; i < s.length; i += 3) {
      if (buffer.isNotEmpty) buffer.write(',');
      buffer.write(s.substring(i, i + 3));
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: AppRadius.borderXs,
        ),
        child: Text(
          '${_formatNumber(count)}개 돌파!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textInverse,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.fill;

    // Draw triangle pointer at bottom center
    final path = Path();
    const triangleWidth = 8.0;
    const triangleHeight = 6.0;
    final cx = size.width / 2;
    path.moveTo(cx - triangleWidth / 2, size.height);
    path.lineTo(cx + triangleWidth / 2, size.height);
    path.lineTo(cx, size.height + triangleHeight);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
