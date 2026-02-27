import 'dart:async';
import 'package:flutter/material.dart';
import 'fund_image.dart';
import '../models/fund.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class FundCard extends StatefulWidget {
  final Fund fund;
  final VoidCallback? onTap;
  final bool showProgressOverlay;

  const FundCard({
    super.key,
    required this.fund,
    this.onTap,
    this.showProgressOverlay = false,
  });

  @override
  State<FundCard> createState() => _FundCardState();
}

class _FundCardState extends State<FundCard> {
  late Timer _timer;
  late Duration _remaining;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.fund.endAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining = widget.fund.endAt.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return '마감';
    if (d.inDays >= 1) return '마감 ${d.inDays}일전';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s 남음';
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '${buffer.toString()}원';
  }

  @override
  Widget build(BuildContext context) {
    final fund = widget.fund;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.borderMd,
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.shadowMedium
                    : AppColors.shadowLight,
                offset: Offset(0, _isHovered ? 4 : 1),
                blurRadius: _isHovered ? 12 : 3,
              ),
            ],
          ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image with timer badge and optional progress overlay
            AspectRatio(
              aspectRatio: 0.85,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: FundImage(
                      imageUrl: fund.imageUrl,
                      errorIcon: Icons.fastfood,
                      errorBgColor: AppColors.surface,
                    ),
                  ),

                  // Timer badge — top left
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xCC000000),
                        borderRadius: AppRadius.borderXs,
                      ),
                      child: Text(
                        _formatDuration(_remaining),
                        style: AppTextStyles.countdownSmall,
                      ),
                    ),
                  ),

                  // Progress overlay — bottom of image
                  if (widget.showProgressOverlay)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: const Color(0xCC000000),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm, 5, AppSpacing.sm, 6,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_formatPrice(fund.currentParticipants).replaceAll('원', '')}개',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '목표 ${_formatPrice(fund.maxParticipants).replaceAll('원', '')}개',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textInverse
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: fund.progressRatio,
                                minHeight: 3,
                                backgroundColor: const Color(0x55FFFFFF),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                  AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Text area
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags row
                  if (fund.freeShipping)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          _Tag(label: '무료배송'),
                        ],
                      ),
                    ),

                  // Product name
                  Text(
                    fund.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Price section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '공구가 ',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.priceRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _formatPrice(fund.startPrice),
                          style: AppTextStyles.priceCard,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          _formatPrice(fund.targetPrice),
                          style: AppTextStyles.priceStrike,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // 최대혜택가
                  Text(
                    '최대혜택가 ${_formatPrice(fund.targetPrice)}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.priceRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
