import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon — red circle with X
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.accentRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              color: AppColors.surface,
              size: 32,
            ),
          ),

          const SizedBox(height: 20),

          // Primary error message
          Text(
            _errorText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          // Optional detail message
          if (errorMessage != null && errorMessage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              // Retry — outlined
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '다시 시도',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Manual input — filled primary
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onManualInput,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '직접 입력하기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
