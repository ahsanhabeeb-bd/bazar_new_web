import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SliderProvider extends ChangeNotifier {
  List<String> imageUrls1 = [];
  List<String> imageUrls2 = [];
  List<String> imageUrls3 = [];
  List<String> imageUrls4 = [];
  List<String> imageUrls5 = [];

  // 🔹 Fetch images for "First Slide"
  Future<void> slide1() async {
    await _fetchSlideImages('firstslide', imageUrls1);
  }

  // 🔹 Fetch images for "Second Slide"
  Future<void> slide2() async {
    await _fetchSlideImages('secondslide', imageUrls2);
  }

  // 🔹 Fetch images for "Third Slide"
  Future<void> slide3() async {
    await _fetchSlideImages('thirdslide', imageUrls3);
  }

  // 🔹 Fetch images for "Fourth Slide"
  Future<void> slide4() async {
    await _fetchSlideImages('fourthslide', imageUrls4);
  }

  // 🔹 Fetch images for "Fifth Slide"
  Future<void> slide5() async {
    await _fetchSlideImages('fifthslide', imageUrls5);
  }

  // 🔹 Generic Function to Fetch Slide Images from Firebase
  Future<void> _fetchSlideImages(
    String collection,
    List<String> imageList,
  ) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collection).get();

      imageList.clear(); // Clear previous data
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('imageUrl') && data['imageUrl'] != null) {
          imageList.add(data['imageUrl']);
        }
      }

      print("Fetched $collection images: $imageList"); // Debugging Output
    } catch (e) {
      print("Error fetching $collection: $e");
    }

    notifyListeners(); // Update UI
  }
}
