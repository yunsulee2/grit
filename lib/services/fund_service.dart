import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/fund.dart';

class FundService extends ChangeNotifier {
  FundService._();

  static final FundService _instance = FundService._();
  static FundService get instance => _instance;

  List<Fund> getAllFunds() => List<Fund>.from(mockFunds);

  Fund? getFundById(String id) {
    try {
      return mockFunds.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Fund> getFundsByCategory(String category) {
    if (category == '전체') return getAllFunds();
    return mockFunds.where((f) => f.category == category).toList();
  }

  Future<bool> submitFund(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> submitSellerApplication(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
