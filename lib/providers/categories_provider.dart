import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> categories = [];
  List<String> _dropdownItems = [];

  List<String> get dropdownItems => _dropdownItems;

  // 🔹 Fetch Products from Firestore
  Future<void> fetchCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      categories =
          querySnapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return {
              'name': data['name'] ?? 'No Name',
              'imageUrl': data['imageUrl'] ?? '',
            };
          }).toList();

      // ✅ Explicitly cast as List<String> to prevent type errors
      _dropdownItems =
          categories.map<String>((item) => item['name'].toString()).toList();

      notifyListeners();
      print("✅ Fetched Products: $categories");
    } catch (e) {
      print("🚨 Error fetching products: $e");
    }
  }
}
