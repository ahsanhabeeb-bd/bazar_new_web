import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(Map<String, dynamic> product) {
    // Ensure product has a default quantity of 1 if not set
    product['quantity'] =
        product.containsKey('quantity') ? product['quantity'] : 1;
    _cartItems.add(product);
    notifyListeners();
  }

  /*************  ✨ Codeium Command ⭐  *************/
  /// Clear all items in the cart
  ///
  /// This method simply clears the list of items in the cart and notifies
  /// any listeners that the cart has changed.
  /******  dde734d5-01a5-48be-ac6d-34e5580ffaa1  *******/
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void updateQuantity(int index, int change) {
    int newQuantity = (_cartItems[index]['quantity'] ?? 1) + change;
    if (newQuantity >= 1) {
      _cartItems[index]['quantity'] = newQuantity;
      notifyListeners();
    }
  }

  void removeFromCart(Map<String, dynamic> product) {
    _cartItems.remove(product);
    notifyListeners();
  }
}
