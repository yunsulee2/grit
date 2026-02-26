import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../models/scrape_job.dart';

class ScrapeErrorView extends StatelessWidget {
  final ScrapeErrorCode errorCode;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onManualInput;

  const ScrapeErrorView({
    super.key,
    required this.errorCode,
    this.errorMessage,
    required this.onRetry,
    required this.onManualInput,
  });

  String get _errorText {
    switch (errorCode) {
      case ScrapeErrorCode.invalidUrl:
        return '올바른 URL을 입력해주세요';
      case ScrapeErrorCode.crawlBlocked:
        return '이 사이트에서 정보를 가져올 수 없습니다';
      case ScrapeErrorCode.parseError:
        return '상품 정보를 분석하지 못했습니다';
      case ScrapeErrorCode.timeout:
        return '시간이 초과되었습니다';
      case ScrapeErrorCode.notProductPage:
        return '상품 페이지가 아닌 것 같습니다';
      case ScrapeErrorCode.rateLimited:
        return '잠시 후 다시 시도해주세요';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon — red circle with X
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              color: AppColors.surface,
              size: 32,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Primary error message
          Text(
            _errorText,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          // Optional detail message
          if (errorMessage != null && errorMessage!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              errorMessage!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: AppSpacing.xxxl),

          // Action buttons
          Row(
            children: [
              // Retry — outlined
              Expanded(
                child: SizedBox(
                  height: AppSpacing.xxxxl,
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderSm,
                      ),
                    ),
                    child: Text(
                      '다시 시도',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Manual input — filled primary
              Expanded(
                child: SizedBox(
                  height: AppSpacing.xxxxl,
                  child: ElevatedButton(
                    onPressed: onManualInput,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderSm,
                      ),
                    ),
                    child: Text(
                      '직접 입력하기',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
