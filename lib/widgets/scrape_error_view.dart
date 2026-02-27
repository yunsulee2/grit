import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../models/scrape_job.dart';

/// Compact inline error view for scraping failures.
/// Designed to fit inside Step 0 (not full-screen).
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

  String get _title {
    switch (errorCode) {
      case ScrapeErrorCode.invalidUrl:
        return '링크가 올바르지 않아요';
      case ScrapeErrorCode.crawlBlocked:
        return '이 사이트는 아직 지원하지 않아요';
      case ScrapeErrorCode.captchaRequired:
        return '보안 확인이 필요해요';
      case ScrapeErrorCode.parseError:
        return '상품 정보를 읽지 못했어요';
      case ScrapeErrorCode.timeout:
        return '시간이 좀 걸리고 있어요';
      case ScrapeErrorCode.notProductPage:
        return '상품 페이지가 아닌 것 같아요';
      case ScrapeErrorCode.rateLimited:
        return '잠시 후 다시 시도해 주세요';
    }
  }

  String get _description {
    switch (errorCode) {
      case ScrapeErrorCode.invalidUrl:
        return '상품 페이지에서 링크를 다시 복사해 주세요.';
      case ScrapeErrorCode.crawlBlocked:
        return '직접 입력으로 등록하시거나, 다른 쇼핑몰 링크를 시도해 주세요.';
      case ScrapeErrorCode.captchaRequired:
        return '보안 확인 때문에 자동으로 가져올 수 없어요. 잠시 후 다시 시도하거나 직접 입력해 주세요.';
      case ScrapeErrorCode.parseError:
        return '상품 정보를 자동으로 분석하지 못했어요. 직접 입력으로 등록해 주세요.';
      case ScrapeErrorCode.timeout:
        return '사이트 응답이 느려요. 다시 시도해 볼까요?';
      case ScrapeErrorCode.notProductPage:
        return '상품 상세 페이지의 링크를 복사해 주세요. 카테고리나 검색 결과 페이지는 지원하지 않아요.';
      case ScrapeErrorCode.rateLimited:
        return '요청이 너무 많아요. 30초 후에 다시 시도해 주세요.';
    }
  }

  IconData get _icon {
    switch (errorCode) {
      case ScrapeErrorCode.captchaRequired:
        return Icons.shield_outlined;
      case ScrapeErrorCode.timeout:
        return Icons.timer_outlined;
      case ScrapeErrorCode.notProductPage:
        return Icons.link_off;
      default:
        return Icons.error_outline;
    }
  }

  Color get _iconColor {
    return errorCode == ScrapeErrorCode.captchaRequired
        ? AppColors.warning
        : AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: _iconColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon + title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Description
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(
              _description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderSm,
                      ),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onManualInput,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderSm,
                      ),
                    ),
                    child: const Text('직접 입력하기'),
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
