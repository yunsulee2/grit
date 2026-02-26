import 'package:flutter/material.dart';
import '../models/fund.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'participant_badge.dart';

class VolumePricingBar extends StatelessWidget {
  final List<PriceTier> tiers;
  final int currentParticipants;
  final int maxParticipants;
  final bool isLarge;

  const VolumePricingBar({
    super.key,
    required this.tiers,
    required this.currentParticipants,
    required this.maxParticipants,
    this.isLarge = false,
  });

  double get _progress =>
      (currentParticipants / maxParticipants).clamp(0.0, 1.0);

  String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    int start = s.length % 3;
    if (start > 0) buffer.write(s.substring(0, start));
    for (int i = start; i < s.length; i += 3) {
      if (buffer.isNotEmpty) buffer.write(',');
      buffer.write(s.substring(i, i + 3));
    }
    return buffer.toString();
  }

  String _formatPrice(int price) => '${_formatNumber(price)}원';

  @override
  Widget build(BuildContext context) {
    if (!isLarge) {
      return _SmallBar(
        currentParticipants: currentParticipants,
        maxParticipants: maxParticipants,
        progress: _progress,
        formatNumber: _formatNumber,
      );
    }
    return _LargeBar(
      tiers: tiers,
      currentParticipants: currentParticipants,
      maxParticipants: maxParticipants,
      progress: _progress,
      formatNumber: _formatNumber,
      formatPrice: _formatPrice,
    );
  }
}

// ─── Small variant ────────────────────────────────────────────────────────────

class _SmallBar extends StatelessWidget {
  final int currentParticipants;
  final int maxParticipants;
  final double progress;
  final String Function(int) formatNumber;

  const _SmallBar({
    required this.currentParticipants,
    required this.maxParticipants,
    required this.progress,
    required this.formatNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${formatNumber(currentParticipants)}개',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '목표 ${formatNumber(maxParticipants)}개',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        _ProgressTrack(height: 4, progress: progress, useGradient: false),
      ],
    );
  }
}

// ─── Large variant ────────────────────────────────────────────────────────────

class _LargeBar extends StatelessWidget {
  final List<PriceTier> tiers;
  final int currentParticipants;
  final int maxParticipants;
  final double progress;
  final String Function(int) formatNumber;
  final String Function(int) formatPrice;

  const _LargeBar({
    required this.tiers,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.progress,
    required this.formatNumber,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Speech bubble badge above the bar, aligned to progress position
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final badgeOffset = (barWidth * progress).clamp(0.0, barWidth);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox(height: 36, width: double.infinity),
                Positioned(
                  bottom: 0,
                  left: (badgeOffset - 40).clamp(0.0, barWidth - 80),
                  child: ParticipantBadge(
                    count: currentParticipants,
                    progressPercent: progress,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        // Progress bar with tier markers and end dot
        _LargeProgressTrack(
          tiers: tiers,
          maxParticipants: maxParticipants,
          progress: progress,
        ),
        const SizedBox(height: AppSpacing.sm),
        // Tier labels below the bar
        _TierLabels(
          tiers: tiers,
          maxParticipants: maxParticipants,
          currentParticipants: currentParticipants,
          formatNumber: formatNumber,
          formatPrice: formatPrice,
        ),
      ],
    );
  }
}

// ─── Large progress track ─────────────────────────────────────────────────────

class _LargeProgressTrack extends StatelessWidget {
  final List<PriceTier> tiers;
  final int maxParticipants;
  final double progress;

  const _LargeProgressTrack({
    required this.tiers,
    required this.maxParticipants,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        const barHeight = 8.0;
        const dotSize = 12.0;

        return SizedBox(
          height: dotSize,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Track background
              Positioned.fill(
                child: _ProgressTrack(
                  height: barHeight,
                  progress: progress,
                  useGradient: true,
                ),
              ),
              // Tier marker circles
              ...tiers.map((tier) {
                final tierPos =
                    (tier.minParticipants / maxParticipants).clamp(0.0, 1.0);
                final achieved =
                    currentParticipants >= tier.minParticipants;
                final left = barWidth * tierPos - dotSize / 2;
                return Positioned(
                  left: left.clamp(0.0, barWidth - dotSize),
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: achieved
                          ? AppColors.primary
                          : AppColors.border,
                      border: Border.all(
                        color: AppColors.textInverse,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),
              // End dot at current progress
              Positioned(
                left:
                    (barWidth * progress - dotSize / 2).clamp(0.0, barWidth - dotSize),
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.25),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int get currentParticipants =>
      (progress * maxParticipants).round();
}

// ─── Shared track painter ─────────────────────────────────────────────────────

class _ProgressTrack extends StatelessWidget {
  final double height;
  final double progress;
  final bool useGradient;

  const _ProgressTrack({
    required this.height,
    required this.progress,
    required this.useGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: CustomPaint(
        painter: _TrackPainter(
          progress: progress,
          useGradient: useGradient,
          height: height,
        ),
        child: SizedBox(height: height, width: double.infinity),
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  final double progress;
  final bool useGradient;
  final double height;

  _TrackPainter({
    required this.progress,
    required this.useGradient,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Track background
    final trackPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), trackPaint);

    // Fill
    final fillWidth = size.width * progress;
    if (fillWidth <= 0) return;

    final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.height);

    final Paint fillPaint;
    if (useGradient) {
      fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [AppColors.primary, AppColors.error],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      fillPaint = Paint()..color = AppColors.primary;
    }
    canvas.drawRect(fillRect, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _TrackPainter old) =>
      old.progress != progress || old.useGradient != useGradient;
}

// ─── Tier labels ──────────────────────────────────────────────────────────────

class _TierLabels extends StatelessWidget {
  final List<PriceTier> tiers;
  final int maxParticipants;
  final int currentParticipants;
  final String Function(int) formatNumber;
  final String Function(int) formatPrice;

  const _TierLabels({
    required this.tiers,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.formatNumber,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    // Build label entries: first one is "시작가", rest are tier milestones
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < tiers.length; i++)
          _TierLabel(
            label: i == 0
                ? '시작가'
                : '${formatNumber(tiers[i].minParticipants)}개 달성 시',
            subLabel: i == 0
                ? '${formatNumber(tiers[i].minParticipants)}만개'
                : null,
            price: formatPrice(tiers[i].price),
            achieved: currentParticipants >= tiers[i].minParticipants,
          ),
      ],
    );
  }
}

class _TierLabel extends StatelessWidget {
  final String label;
  final String? subLabel;
  final String price;
  final bool achieved;

  const _TierLabel({
    required this.label,
    this.subLabel,
    required this.price,
    required this.achieved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: achieved ? AppColors.primary : AppColors.textSecondary,
            fontWeight: achieved ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
        if (subLabel != null)
          Text(
            subLabel!,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        Text(
          price,
          style: AppTextStyles.bodySmall.copyWith(
            color: achieved ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
