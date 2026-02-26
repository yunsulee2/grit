class NutritionInfo {
  final int? calories;
  final double? protein;
  final double? fat;
  final double? carbs;
  final double? sodium;

  const NutritionInfo({
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
    this.sodium,
  });
}

class ProductOption {
  final String name;
  final List<String> values;

  const ProductOption({
    required this.name,
    required this.values,
  });
}

enum ExtractionConfidence { high, medium, low, failed }

class ExtractedField<T> {
  final T? value;
  final ExtractionConfidence confidence;

  const ExtractedField({
    this.value,
    required this.confidence,
  });
}

class ExtractedProduct {
  final ExtractedField<String> productName;
  final ExtractedField<String> brandName;
  final ExtractedField<int> originalPrice;
  final ExtractedField<String> description;
  final ExtractedField<String> category;
  final ExtractedField<String> origin;
  final ExtractedField<String> weight;
  final ExtractedField<String> mainImage;
  final ExtractedField<List<String>> galleryImages;
  final ExtractedField<List<String>> detailImages;
  final ExtractedField<List<ProductOption>> options;
  final ExtractedField<NutritionInfo> nutritionInfo;
  final String sourceUrl;
  final String detectedSite;

  const ExtractedProduct({
    required this.productName,
    required this.brandName,
    required this.originalPrice,
    required this.description,
    required this.category,
    required this.origin,
    required this.weight,
    required this.mainImage,
    required this.galleryImages,
    required this.detailImages,
    required this.options,
    required this.nutritionInfo,
    required this.sourceUrl,
    required this.detectedSite,
  });

  ExtractedProduct copyWith({
    ExtractedField<String>? productName,
    ExtractedField<String>? brandName,
    ExtractedField<int>? originalPrice,
    ExtractedField<String>? description,
    ExtractedField<String>? category,
    ExtractedField<String>? origin,
    ExtractedField<String>? weight,
    ExtractedField<String>? mainImage,
    ExtractedField<List<String>>? galleryImages,
    ExtractedField<List<String>>? detailImages,
    ExtractedField<List<ProductOption>>? options,
    ExtractedField<NutritionInfo>? nutritionInfo,
    String? sourceUrl,
    String? detectedSite,
  }) {
    return ExtractedProduct(
      productName: productName ?? this.productName,
      brandName: brandName ?? this.brandName,
      originalPrice: originalPrice ?? this.originalPrice,
      description: description ?? this.description,
      category: category ?? this.category,
      origin: origin ?? this.origin,
      weight: weight ?? this.weight,
      mainImage: mainImage ?? this.mainImage,
      galleryImages: galleryImages ?? this.galleryImages,
      detailImages: detailImages ?? this.detailImages,
      options: options ?? this.options,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      detectedSite: detectedSite ?? this.detectedSite,
    );
  }
}
