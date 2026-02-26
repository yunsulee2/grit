import 'package:flutter/foundation.dart';

class CartItem {
  final String fundId;
  final String productName;
  final String brandName;
  final String imageUrl;
  final int price;
  int quantity;

  CartItem({
    required this.fundId,
    required this.productName,
    required this.brandName,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });
}

class CartService extends ChangeNotifier {
  CartService._internal();
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  void addItem({
    required String fundId,
    required String productName,
    required String brandName,
    required String imageUrl,
    required int price,
  }) {
    final existing = _items.where((i) => i.fundId == fundId).firstOrNull;
    if (existing != null) {
      existing.quantity += 1;
    } else {
      _items.add(CartItem(
        fundId: fundId,
        productName: productName,
        brandName: brandName,
        imageUrl: imageUrl,
        price: price,
      ));
    }
    notifyListeners();
  }

  void removeItem(String fundId) {
    _items.removeWhere((i) => i.fundId == fundId);
    notifyListeners();
  }

  void updateQuantity(String fundId, int quantity) {
    if (quantity <= 0) {
      removeItem(fundId);
      return;
    }
    final item = _items.where((i) => i.fundId == fundId).firstOrNull;
    if (item != null) {
      item.quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
