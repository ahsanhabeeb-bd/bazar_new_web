import 'package:flutter/material.dart';

class Vendor_ProductsR with ChangeNotifier {
  final List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'Laptop',
      'description': 'Powerful gaming laptop with RTX 3080.',
      'price': 1500,
      'images': ['assets/images/image 17.png', 'assets/images/image 18.png'],
    },
    {
      'id': 2,
      'name': 'Smartphone',
      'description': 'Latest 5G smartphone with AMOLED display.',
      'price': 899,
      'images': ['assets/images/image 19.png', 'assets/images/image 11.png'],
    },
    {
      'id': 3,
      'name': 'Laptop',
      'description': 'Powerful gaming laptop with RTX 3080.',
      'price': 1500,
      'images': ['assets/images/image 17.png', 'assets/images/image 18.png'],
    },
    {
      'id': 4,
      'name': 'Smartphone',
      'description': 'Latest 5G smartphone with AMOLED display.',
      'price': 899,
      'images': ['assets/images/image 19.png', 'assets/images/image 11.png'],
    },
    {
      'id': 5,
      'name': 'Laptop',
      'description': 'Powerful gaming laptop with RTX 3080.',
      'price': 1500,
      'images': ['assets/images/image 17.png', 'assets/images/image 18.png'],
    },
    {
      'id': 6,
      'name': 'Smartphone',
      'description': 'Latest 5G smartphone with AMOLED display.',
      'price': 899,
      'images': ['assets/images/image 19.png', 'assets/images/image 11.png'],
    },
  ];

  List<Map<String, dynamic>> get products => _products;

  // Accept Product (move it to a list or mark as accepted)
  void acceptProduct(int productId) {
    // Handle the action like moving to another list or marking as accepted
    _products.removeWhere((product) => product['id'] == productId);
    notifyListeners(); // Notify the UI to update
  }

  // Decline Product (remove from list)
  void declineProduct(int productId) {
    _products.removeWhere((product) => product['id'] == productId);
    notifyListeners(); // Notify the UI to update
  }

  // Edit Product (update details of the product)
  void editProduct(int productId, Map<String, dynamic> updatedProduct) {
    final index = _products.indexWhere((product) => product['id'] == productId);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners(); // Notify the UI to update
    }
  }
}
