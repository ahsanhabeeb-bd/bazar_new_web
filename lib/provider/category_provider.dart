import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController categoryController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  File? _selectedImage;

  // Getters
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  File? get selectedImage => _selectedImage;

  // Set selected image
  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  // Pick and compress image
  Future<File?> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        return await _compressImage(File(pickedFile.path));
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    return null;
  }

  // Compress image to <50 KB
  Future<File> _compressImage(File imageFile) async {
    try {
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return imageFile;
      img.Image resizedImage = img.copyResize(image, width: 300);
      List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 50);
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/compressed_image.jpg');
      await compressedFile.writeAsBytes(compressedBytes);
      return compressedFile;
    } catch (e) {
      print("Error compressing image: $e");
      return imageFile;
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage(File imageFile, String categoryId) async {
    try {
      Reference ref = _storage.ref().child('categories/$categoryId.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Save category in Firestore
  Future<void> saveCategory(String categoryName, File? imageFile) async {
    if (categoryName.isEmpty || imageFile == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    String categoryId = DateTime.now().millisecondsSinceEpoch.toString();
    String? imageUrl = await _uploadImage(imageFile, categoryId);

    if (imageUrl != null) {
      await _firestore.collection("products").doc(categoryId).set({
        "id": categoryId,
        "name": categoryName,
        "imageUrl": imageUrl,
        "createdAt": FieldValue.serverTimestamp(),
      });

      fetchCategories(); // Refresh list
    }

    _isLoading = false;
    _selectedImage = null;
    categoryController.clear();
    notifyListeners();
  }

  // Fetch categories from Firestore
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    QuerySnapshot snapshot =
        await _firestore
            .collection("products")
            .orderBy("createdAt", descending: true)
            .get();

    _categories =
        snapshot.docs.map((doc) {
          return {"id": doc.id, ...doc.data() as Map<String, dynamic>};
        }).toList();

    _isLoading = false;
    notifyListeners();
  }

  // Update category
  Future<void> updateCategory(
    String categoryId,
    String newName,
    File? newImage,
  ) async {
    String? imageUrl;
    if (newImage != null) {
      imageUrl = await _uploadImage(newImage, categoryId);
    }

    await _firestore.collection("products").doc(categoryId).update({
      "name": newName,
      "imageUrl":
          imageUrl ??
          _categories.firstWhere((c) => c['id'] == categoryId)['imageUrl'],
    });

    fetchCategories(); // Refresh list
  }
}
