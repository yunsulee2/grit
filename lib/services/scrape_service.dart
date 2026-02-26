import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scrape_job.dart';
import '../models/extracted_product.dart';
import '../services/site_detector.dart';

class ScrapeService {
  /// Backend server URL (local development)
  static const String _baseUrl = 'http://localhost:8001';

  /// Proxy an image URL through the backend to avoid CORS issues.
  static String proxyImageUrl(String originalUrl) {
    if (originalUrl.startsWith('assets/')) return originalUrl;
    return '$_baseUrl/api/proxy/image?url=${Uri.encodeComponent(originalUrl)}';
  }

  /// Starts scraping by calling the Python backend.
  /// Returns a stream of ScrapeJob updates for UI progress.
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

    // Step 0: pending
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
      estimatedSeconds: 10,
      createdAt: createdAt,
    );

    // Step 1: crawling — call backend API
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

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/scrape'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'url': url}),
          )
          .timeout(const Duration(seconds: 30));

      // Step 2: parsing
      yield ScrapeJob(
        jobId: jobId,
        sourceUrl: url,
        detectedSite: siteName,
        status: ScrapeStatus.parsing,
        progress: const ScrapeProgress(
          step: 2,
          totalSteps: totalSteps,
          message: '상품 정보를 분석하고 있습니다...',
        ),
        estimatedSeconds: 4,
        createdAt: createdAt,
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || body['success'] != true) {
        final errorCode = body['errorCode']?.toString() ?? '';
        ScrapeErrorCode mappedCode;
        switch (errorCode) {
          case 'BLOCKED':
            mappedCode = ScrapeErrorCode.crawlBlocked;
          case 'NO_DATA':
            mappedCode = ScrapeErrorCode.notProductPage;
          case 'MISSING_URL':
            mappedCode = ScrapeErrorCode.invalidUrl;
          default:
            mappedCode = ScrapeErrorCode.parseError;
        }
        yield ScrapeJob(
          jobId: jobId,
          sourceUrl: url,
          detectedSite: siteName,
          status: ScrapeStatus.failed,
          errorCode: mappedCode,
          errorMessage: body['error']?.toString() ?? '서버에서 데이터를 가져오지 못했습니다.',
          estimatedSeconds: 0,
          createdAt: createdAt,
          completedAt: DateTime.now(),
        );
        return;
      }

      // Step 3: processing images
      yield ScrapeJob(
        jobId: jobId,
        sourceUrl: url,
        detectedSite: siteName,
        status: ScrapeStatus.processing,
        progress: const ScrapeProgress(
          step: 3,
          totalSteps: totalSteps,
          message: '이미지를 처리하고 있습니다...',
        ),
        estimatedSeconds: 2,
        createdAt: createdAt,
      );

      // Parse the response into ExtractedProduct
      final data = body['data'] as Map<String, dynamic>;
      final result = _parseApiResponse(data, url, siteName);

      // Step 4: done
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
    } catch (e) {
      yield ScrapeJob(
        jobId: jobId,
        sourceUrl: url,
        detectedSite: siteName,
        status: ScrapeStatus.failed,
        errorCode: ScrapeErrorCode.timeout,
        errorMessage: '서버에 연결할 수 없습니다. 백엔드 서버가 실행 중인지 확인하세요.\n(${e.runtimeType})',
        estimatedSeconds: 0,
        createdAt: createdAt,
        completedAt: DateTime.now(),
      );
    }
  }

  /// Converts the backend API JSON response into an ExtractedProduct.
  static ExtractedProduct _parseApiResponse(
    Map<String, dynamic> data,
    String sourceUrl,
    String detectedSite,
  ) {
    return ExtractedProduct(
      productName: _extractStringField(data, 'productName'),
      brandName: _extractStringField(data, 'brandName'),
      originalPrice: _extractIntField(data, 'originalPrice'),
      description: _extractStringField(data, 'description'),
      category: _extractStringField(data, 'category'),
      origin: _extractStringField(data, 'origin'),
      weight: _extractStringField(data, 'weight'),
      mainImage: _extractStringField(data, 'mainImage'),
      galleryImages: ExtractedField<List<String>>(
        value: _extractStringList(data, 'galleryImages'),
        confidence: _listConfidence(data, 'galleryImages'),
      ),
      detailImages: ExtractedField<List<String>>(
        value: _extractStringList(data, 'detailImages'),
        confidence: _listConfidence(data, 'detailImages'),
      ),
      options: ExtractedField<List<ProductOption>>(
        value: _extractOptions(data),
        confidence: data['options'] != null
            ? ExtractionConfidence.medium
            : ExtractionConfidence.low,
      ),
      nutritionInfo: const ExtractedField<NutritionInfo>(
        value: null,
        confidence: ExtractionConfidence.low,
      ),
      sourceUrl: data['sourceUrl']?.toString() ?? sourceUrl,
      detectedSite: data['detectedSite']?.toString() ?? detectedSite,
    );
  }

  static ExtractedField<String> _extractStringField(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];
    if (value == null || (value is String && value.isEmpty)) {
      return const ExtractedField<String>(
        value: null,
        confidence: ExtractionConfidence.failed,
      );
    }
    return ExtractedField<String>(
      value: value.toString(),
      confidence: ExtractionConfidence.high,
    );
  }

  static ExtractedField<int> _extractIntField(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];
    if (value == null) {
      return const ExtractedField<int>(
        value: null,
        confidence: ExtractionConfidence.failed,
      );
    }
    final intVal = value is int ? value : int.tryParse(value.toString());
    return ExtractedField<int>(
      value: intVal,
      confidence: intVal != null
          ? ExtractionConfidence.high
          : ExtractionConfidence.failed,
    );
  }

  static List<String> _extractStringList(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static ExtractionConfidence _listConfidence(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];
    if (value is List && value.isNotEmpty) return ExtractionConfidence.high;
    if (value is List && value.isEmpty) return ExtractionConfidence.low;
    return ExtractionConfidence.failed;
  }

  static List<ProductOption>? _extractOptions(Map<String, dynamic> data) {
    final value = data['options'];
    if (value is! List || value.isEmpty) return null;
    return value.map((opt) {
      if (opt is Map<String, dynamic>) {
        return ProductOption(
          name: opt['name']?.toString() ?? '',
          values: (opt['values'] as List?)
                  ?.map((v) => v.toString())
                  .toList() ??
              [],
        );
      }
      return ProductOption(name: opt.toString(), values: []);
    }).toList();
  }
}
