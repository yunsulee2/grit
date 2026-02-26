import 'dart:async';
import '../models/scrape_job.dart';
import '../models/extracted_product.dart';
import '../services/site_detector.dart';
import '../data/mock_scrape_data.dart';

class ScrapeService {
  /// Starts a mock scraping job. Returns a stream of ScrapeJob updates.
  /// Simulates: pending (1s) → crawling (3s) → parsing (3s) → processing (2s) → done
  static Stream<ScrapeJob> startScraping(String url) async* {
    final createdAt = DateTime.now();
    final jobId = 'job-${createdAt.millisecondsSinceEpoch}';

    // Validate URL
    if (!SiteDetector.isValidUrl(url)) {
      yield ScrapeJob(
        jobId: jobId,
        sourceUrl: url,
        detectedSite: '알 수 없음',
        status: ScrapeStatus.failed,
        errorCode: ScrapeErrorCode.invalidUrl,
        errorMessage: '올바른 URL 형식이 아닙니다. https://로 시작하는 URL을 입력해 주세요.',
        estimatedSeconds: 0,
        createdAt: createdAt,
        completedAt: DateTime.now(),
      );
      return;
    }

    final site = SiteDetector.detect(url);
    final siteName = SiteDetector.displayName(site);
    const totalSteps = 4;

    // pending
    yield ScrapeJob(
      jobId: jobId,
      sourceUrl: url,
      detectedSite: siteName,
      status: ScrapeStatus.pending,
      progress: const ScrapeProgress(
        step: 0,
        totalSteps: totalSteps,
        message: '요청을 준비하고 있습니다...',
      ),
      estimatedSeconds: 9,
      createdAt: createdAt,
    );
    await Future.delayed(const Duration(seconds: 1));

    // crawling
    yield ScrapeJob(
      jobId: jobId,
      sourceUrl: url,
      detectedSite: siteName,
      status: ScrapeStatus.crawling,
      progress: const ScrapeProgress(
        step: 1,
        totalSteps: totalSteps,
        message: '페이지에 접속하고 있습니다...',
      ),
      estimatedSeconds: 8,
      createdAt: createdAt,
    );
    await Future.delayed(const Duration(seconds: 3));

    // parsing
    yield ScrapeJob(
      jobId: jobId,
      sourceUrl: url,
      detectedSite: siteName,
      status: ScrapeStatus.parsing,
      progress: const ScrapeProgress(
        step: 2,
        totalSteps: totalSteps,
        message: '상품 정보를 읽고 있습니다...',
      ),
      estimatedSeconds: 5,
      createdAt: createdAt,
    );
    await Future.delayed(const Duration(seconds: 3));

    // processing
    yield ScrapeJob(
      jobId: jobId,
      sourceUrl: url,
      detectedSite: siteName,
      status: ScrapeStatus.processing,
      progress: const ScrapeProgress(
        step: 3,
        totalSteps: totalSteps,
        message: '이미지를 가져오고 있습니다...',
      ),
      estimatedSeconds: 2,
      createdAt: createdAt,
    );
    await Future.delayed(const Duration(seconds: 2));

    // done
    final result = _getMockResult(url, siteName);
    yield ScrapeJob(
      jobId: jobId,
      sourceUrl: url,
      detectedSite: siteName,
      status: ScrapeStatus.done,
      progress: const ScrapeProgress(
        step: 4,
        totalSteps: totalSteps,
        message: '완료되었습니다.',
      ),
      result: result,
      estimatedSeconds: 0,
      createdAt: createdAt,
      completedAt: DateTime.now(),
    );
  }

  /// Returns mock extracted product data for demo purposes.
  static ExtractedProduct _getMockResult(String url, String site) {
    return MockScrapeData.getForUrl(url);
  }
}
