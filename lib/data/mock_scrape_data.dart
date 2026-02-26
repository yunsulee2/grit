import '../models/extracted_product.dart';

/// Provides mock scrape results for different product URLs.
/// Maps URL patterns to realistic ExtractedProduct data.
/// Uses existing local asset images from assets/images/.
class MockScrapeData {
  static ExtractedProduct getForUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('coupang')) {
      return coupangChicken;
    }
    if (lower.contains('naver') || lower.contains('smartstore')) {
      return naverProtein;
    }
    if (lower.contains('kakao')) {
      return kakaoSnack;
    }
    return coupangChicken;
  }

  /// 쿠팡 닭가슴살
  static ExtractedProduct get coupangChicken => const ExtractedProduct(
        productName: ExtractedField(
          value: '퍼포먼스 닭가슴살 스팀 오리지널 1kg',
          confidence: ExtractionConfidence.high,
        ),
        brandName: ExtractedField(
          value: '잇메이트',
          confidence: ExtractionConfidence.high,
        ),
        originalPrice: ExtractedField(
          value: 12900,
          confidence: ExtractionConfidence.high,
        ),
        description: ExtractedField(
          value: '국내산 닭가슴살 100% 사용. 저염 저지방 고단백 스팀 닭가슴살로 다이어트와 근육 증진에 최적화된 제품입니다.',
          confidence: ExtractionConfidence.high,
        ),
        category: ExtractedField(
          value: '닭가슴살',
          confidence: ExtractionConfidence.high,
        ),
        origin: ExtractedField(
          value: '국내산',
          confidence: ExtractionConfidence.high,
        ),
        weight: ExtractedField(
          value: '1kg (100g x 10팩)',
          confidence: ExtractionConfidence.high,
        ),
        mainImage: ExtractedField(
          value: 'assets/images/chicken1.jpg',
          confidence: ExtractionConfidence.high,
        ),
        galleryImages: ExtractedField(
          value: ['assets/images/chicken1.jpg', 'assets/images/chicken2.jpg'],
          confidence: ExtractionConfidence.high,
        ),
        detailImages: ExtractedField(
          value: ['assets/images/chicken1.jpg'],
          confidence: ExtractionConfidence.medium,
        ),
        options: ExtractedField(
          value: [
            ProductOption(name: '맛', values: ['오리지널', '훈제', '매콤']),
            ProductOption(name: '용량', values: ['1kg', '2kg']),
          ],
          confidence: ExtractionConfidence.high,
        ),
        nutritionInfo: ExtractedField(
          value: NutritionInfo(
            calories: 109,
            protein: 23.0,
            fat: 1.2,
            carbs: 0.5,
            sodium: 280,
          ),
          confidence: ExtractionConfidence.high,
        ),
        sourceUrl: 'https://www.coupang.com/vp/products/example-chicken',
        detectedSite: '쿠팡',
      );

  /// 네이버 프로틴
  static ExtractedProduct get naverProtein => const ExtractedProduct(
        productName: ExtractedField(
          value: '프로틴 바 초코 크런치 12개입',
          confidence: ExtractionConfidence.high,
        ),
        brandName: ExtractedField(
          value: '머슬팜',
          confidence: ExtractionConfidence.high,
        ),
        originalPrice: ExtractedField(
          value: 24000,
          confidence: ExtractionConfidence.high,
        ),
        description: ExtractedField(
          value: '한 개당 단백질 20g. 운동 후 단백질 보충에 최적화된 초코 크런치 프로틴 바. 인공색소 무첨가.',
          confidence: ExtractionConfidence.high,
        ),
        category: ExtractedField(
          value: '프로틴',
          confidence: ExtractionConfidence.high,
        ),
        origin: ExtractedField(
          value: '미국산',
          confidence: ExtractionConfidence.medium,
        ),
        weight: ExtractedField(
          value: '60g x 12개입',
          confidence: ExtractionConfidence.high,
        ),
        mainImage: ExtractedField(
          value: 'assets/images/protein_bar.jpg',
          confidence: ExtractionConfidence.high,
        ),
        galleryImages: ExtractedField(
          value: ['assets/images/protein_bar.jpg'],
          confidence: ExtractionConfidence.high,
        ),
        detailImages: ExtractedField(
          value: ['assets/images/protein_bar.jpg'],
          confidence: ExtractionConfidence.medium,
        ),
        options: ExtractedField(
          value: [
            ProductOption(name: '맛', values: ['초코 크런치', '바닐라 아몬드', '땅콩버터']),
          ],
          confidence: ExtractionConfidence.high,
        ),
        nutritionInfo: ExtractedField(
          value: NutritionInfo(
            calories: 210,
            protein: 20.0,
            fat: 7.0,
            carbs: 18.0,
            sodium: 180,
          ),
          confidence: ExtractionConfidence.high,
        ),
        sourceUrl: 'https://smartstore.naver.com/musclefarm/products/example-protein',
        detectedSite: '네이버 스마트스토어',
      );

  /// 카카오 간식
  static ExtractedProduct get kakaoSnack => const ExtractedProduct(
        productName: ExtractedField(
          value: '곤약젤리 복숭아맛 150ml x 10팩',
          confidence: ExtractionConfidence.medium,
        ),
        brandName: ExtractedField(
          value: '로칼',
          confidence: ExtractionConfidence.medium,
        ),
        originalPrice: ExtractedField(
          value: 15000,
          confidence: ExtractionConfidence.medium,
        ),
        description: ExtractedField(
          value: '저칼로리 곤약 젤리. 칼로리 걱정 없이 즐기는 달콤한 간식. 1팩당 10kcal 이하.',
          confidence: ExtractionConfidence.medium,
        ),
        category: ExtractedField(
          value: '간식/간편식',
          confidence: ExtractionConfidence.medium,
        ),
        origin: ExtractedField(
          value: null,
          confidence: ExtractionConfidence.low,
        ),
        weight: ExtractedField(
          value: '150ml x 10팩',
          confidence: ExtractionConfidence.medium,
        ),
        mainImage: ExtractedField(
          value: 'assets/images/jelly.jpg',
          confidence: ExtractionConfidence.medium,
        ),
        galleryImages: ExtractedField(
          value: ['assets/images/jelly.jpg'],
          confidence: ExtractionConfidence.medium,
        ),
        detailImages: ExtractedField(
          value: [],
          confidence: ExtractionConfidence.low,
        ),
        options: ExtractedField(
          value: [
            ProductOption(name: '맛', values: ['복숭아', '청포도', '딸기']),
          ],
          confidence: ExtractionConfidence.medium,
        ),
        nutritionInfo: ExtractedField(
          value: NutritionInfo(
            calories: 8,
            protein: 0.1,
            fat: 0.0,
            carbs: 2.0,
            sodium: 5,
          ),
          confidence: ExtractionConfidence.low,
        ),
        sourceUrl: 'https://store.kakao.com/lokal/products/example-jelly',
        detectedSite: '카카오 톡딜',
      );
}
