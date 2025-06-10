import 'package:flutter/material.dart';

class AcceptedProductsProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'Wireless Headphones',
      'description': 'High-quality sound with noise cancellation.',
      'price': 99.99,
      'images': [
        'assets/images/image 12.jpg',
        'assets/images/image 12.jpg',
        'assets/images/image 12.jpg',
      ],
      'quantity': 1,
    },
    {
      'id': 2,
      'name': 'Watch',
      'description': 'Smartwatch with advanced features.',
      'price': 99,
      'images': [
        'assets/images/image 13.jpg',
        'assets/images/image 13.jpg',
        'assets/images/image 13.jpg',
      ],
      'quantity': 1,
    },
  ];

  List<Map<String, dynamic>> get products => _products; // ✅ Safe getter

  /// ✅ Remove product by ID (safer than using index)
  void removeproduct(Map<String, dynamic> product) {
    products.removeWhere((element) {
      return element['id'] == product['id'];
    });
    notifyListeners();
  }
}
