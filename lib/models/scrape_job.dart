import 'extracted_product.dart';

enum ScrapeStatus {
  pending,
  crawling,
  parsing,
  processing,
  done,
  failed,
}

enum ScrapeErrorCode {
  invalidUrl,
  crawlBlocked,
  parseError,
  timeout,
  notProductPage,
  rateLimited,
}

class ScrapeProgress {
  final int step;
  final int totalSteps;
  final String message;

  const ScrapeProgress({
    required this.step,
    required this.totalSteps,
    required this.message,
  });
}

class ScrapeJob {
  final String jobId;
  final String sourceUrl;
  final String detectedSite;
  final ScrapeStatus status;
  final ScrapeProgress? progress;
  final ExtractedProduct? result;
  final ScrapeErrorCode? errorCode;
  final String? errorMessage;
  final int estimatedSeconds;
  final DateTime createdAt;
  final DateTime? completedAt;

  const ScrapeJob({
    required this.jobId,
    required this.sourceUrl,
    required this.detectedSite,
    required this.status,
    this.progress,
    this.result,
    this.errorCode,
    this.errorMessage,
    required this.estimatedSeconds,
    required this.createdAt,
    this.completedAt,
  });
}
