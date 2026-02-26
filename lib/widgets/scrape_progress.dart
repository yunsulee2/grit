import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ScrapeProgressView extends StatelessWidget {
  final int currentStep; // 1-4
  final String message;
  final int estimatedSeconds;

  const ScrapeProgressView({
    super.key,
    required this.currentStep,
    required this.message,
    required this.estimatedSeconds,
  });

  static const _steps = [
    _StepMeta(label: '접속', subtitle: '접속 중...'),
    _StepMeta(label: '분석', subtitle: '상품 정보 읽는 중'),
    _StepMeta(label: '이미지', subtitle: '이미지 가져오는 중'),
    _StepMeta(label: '생성', subtitle: '상세페이지 생성 중'),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: AppSpacing.xxxxl,
              height: AppSpacing.xxxxl,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            _StepRow(currentStep: currentStep, steps: _steps),
            const SizedBox(height: AppSpacing.xl),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '약 $estimatedSeconds초 정도 소요됩니다',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepMeta {
  final String label;
  final String subtitle;
  const _StepMeta({required this.label, required this.subtitle});
}

class _StepRow extends StatelessWidget {
  final int currentStep;
  final List<_StepMeta> steps;

  const _StepRow({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _StepItem(
            index: i + 1,
            label: steps[i].label,
            currentStep: currentStep,
          ),
          if (i < steps.length - 1)
            _ConnectorLine(completed: currentStep > i + 1),
        ],
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final String label;
  final int currentStep;

  const _StepItem({
    required this.index,
    required this.label,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = currentStep > index;
    final isActive = currentStep == index;
    final isPending = currentStep < index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: isCompleted
              ? Icon(Icons.check_circle, color: AppColors.success, size: 28)
              : isActive
                  ? Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$index',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isPending
                              ? AppColors.textTertiary
                              : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$index',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isPending
                              ? AppColors.textTertiary
                              : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? AppColors.primary
                : isCompleted
                    ? AppColors.success
                    : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _ConnectorLine extends StatelessWidget {
  final bool completed;

  const _ConnectorLine({required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 2,
      margin: const EdgeInsets.only(bottom: 22, left: 4, right: 4),
      // Align with the center of the step circle (28/2 = 14 from top of column)
      // Column: 28px circle + 6px gap + ~14px text ≈ offset via margin above
      alignment: Alignment.center,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: 2,
          color: completed ? AppColors.success : AppColors.border,
        ),
      ),
    );
  }
}
