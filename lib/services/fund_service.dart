import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/fund.dart';

class FundService extends ChangeNotifier {
  FundService._();

  static final FundService _instance = FundService._();
  static FundService get instance => _instance;

  /// User-submitted funds (persisted in memory for this session)
  final List<Fund> _userFunds = [];

  List<Fund> getAllFunds() => [..._userFunds, ...mockFunds];

  List<Fund> getUserFunds() => List<Fund>.from(_userFunds);

  Fund? getFundById(String id) {
    try {
      return getAllFunds().firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Fund> getFundsByCategory(String category) {
    if (category == '전체') return getAllFunds();
    return getAllFunds().where((f) => f.category == category).toList();
  }

  Future<bool> submitFund(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final tiers = (data['tiers'] as List?)
            ?.map((t) => PriceTier(
                  minParticipants: t['minParticipants'] as int? ?? 0,
                  price: t['price'] as int? ?? 0,
                ))
            .toList() ??
        [];

    final startPrice = tiers.isNotEmpty ? tiers.first.price : 0;
    final targetPrice = tiers.length > 1 ? tiers.last.price : startPrice;
    final maxParticipants =
        int.tryParse(data['maxParticipants']?.toString() ?? '') ?? 500;
    final endDateStr = data['endDate']?.toString() ?? '';
    final endAt = DateTime.tryParse(endDateStr) ??
        DateTime.now().add(const Duration(days: 30));

    final detailImages = (data['detailImages'] as List<String>?) ?? [];

    final fund = Fund(
      id: 'user-fund-${DateTime.now().millisecondsSinceEpoch}',
      productName: data['productName']?.toString() ?? '',
      brandName: data['brandName']?.toString() ?? '',
      category: data['category']?.toString() ?? '기타',
      imageUrl: data['mainImage']?.toString() ?? 'assets/images/placeholder.png',
      description: data['description']?.toString() ?? '',
      detailImages: detailImages,
      startPrice: startPrice,
      targetPrice: targetPrice,
      tiers: tiers,
      currentParticipants: 0,
      maxParticipants: maxParticipants,
      endAt: endAt,
      status: 'active',
      freeShipping: (data['shippingFee']?.toString() ?? '0') == '0',
    );

    _userFunds.insert(0, fund);
    notifyListeners();
    return true;
  }

  Future<bool> submitSellerApplication(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
