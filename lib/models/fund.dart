class PriceTier {
  final int minParticipants;
  final int price;

  const PriceTier({required this.minParticipants, required this.price});
}

class Fund {
  final String id;
  final String productName;
  final String brandName;
  final String category;
  final String imageUrl;
  final String description;
  final List<String> detailImages;
  final int startPrice;
  final int targetPrice;
  final List<PriceTier> tiers;
  final int currentParticipants;
  final int maxParticipants;
  final DateTime endAt;
  final String status;
  final bool freeShipping;

  const Fund({
    required this.id,
    required this.productName,
    required this.brandName,
    required this.category,
    required this.imageUrl,
    this.description = '',
    this.detailImages = const [],
    required this.startPrice,
    required this.targetPrice,
    required this.tiers,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.endAt,
    required this.status,
    required this.freeShipping,
  });

  double get progressRatio =>
      (currentParticipants / maxParticipants).clamp(0.0, 1.0);

  int get discountPercent =>
      ((1 - targetPrice / startPrice) * 100).round();
}
