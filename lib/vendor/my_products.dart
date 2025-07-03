import 'dart:typed_data';

import 'package:bazar_new_web/vendor/accepted_products.dart';
import 'package:bazar_new_web/vendor/pending_products.dart';
import 'package:bazar_new_web/vendor/rejected_products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({super.key});

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vendorPriceController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  String? _vendorId;
  bool _isLoading = false;

  // Use Uint8List for web compatibility
  Uint8List? _mainImageBytes;
  Uint8List? _image2Bytes;
  Uint8List? _image3Bytes;

  @override
  void initState() {
    super.initState();
    _getVendorId();
  }

  /// Retrieve Vendor ID from SharedPreferences
  Future<void> _getVendorId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _vendorId = prefs.getString('id'); // Ensure correct key
    });
  }

  /// Pick image from gallery and read bytes
  Future<void> _pickImage(String imageType, Function setState) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (imageType == "main") _mainImageBytes = bytes;
        if (imageType == "image2") _image2Bytes = bytes;
        if (imageType == "image3") _image3Bytes = bytes;
      });
    }
  }

  /// Compress and upload the image to Firebase Storage from bytes
  Future<String?> _uploadImage(Uint8List? imageBytes, String fileName) async {
    if (imageBytes == null) return null;

    try {
      print("Original Image Size: ${imageBytes.lengthInBytes / 1024} KB");

      // Compress the image
      Uint8List? compressedBytes = await _compressImage(imageBytes);

      if (compressedBytes != null) {
        print("Compressed Image Size: ${compressedBytes.lengthInBytes / 1024} KB");

        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child("products")
            .child("$fileName.jpg");

        await storageRef.putData(compressedBytes);
        return await storageRef.getDownloadURL();
      } else {
        print("Image compression failed");
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error uploading image: $e")));
      return null;
    }
  }

  /// Compress the image using flutter_image_compress from a list of bytes
  Future<Uint8List?> _compressImage(Uint8List imageBytes) async {
    try {
      return await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: 70, // Adjust compression quality (1-100)
      );
    } catch (e) {
      print("Compression error: $e");
    }
    return null;
  }

  /// Save product to Firestore
  Future<void> _addProduct() async {
    if (_vendorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vendor ID not found! Please log in again.")),
      );
      return;
    }
    if (_nameController.text.isEmpty ||
        _vendorPriceController.text.isEmpty ||
        _selectedCategoryId == null ||
        _selectedSubcategoryId == null ||
        _mainImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String? mainImageUrl = await _uploadImage(_mainImageBytes, "main_$timestamp");
      String? image2Url = await _uploadImage(_image2Bytes, "image2_$timestamp");
      String? image3Url = await _uploadImage(_image3Bytes, "image3_$timestamp");

      await FirebaseFirestore.instance
          .collection("products")
          .doc(timestamp)
          .set({
            "name": _nameController.text,
            "vendorId": _vendorId,
            "categoryId": _selectedCategoryId,
            "subcategoryId": _selectedSubcategoryId,
            "images": {
              "main": mainImageUrl,
              "image2": image2Url,
              "image3": image3Url,
            },
            "vendorPrice": double.parse(_vendorPriceController.text),
            "details": _detailsController.text,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Product added successfully!")));

      _nameController.clear();
      _vendorPriceController.clear();
      _detailsController.clear();
      _selectedCategoryId = null;
      _selectedSubcategoryId = null;
      _mainImageBytes = null;
      _image2Bytes = null;
      _image3Bytes = null;

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding product: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show Product Dialog Box
  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Product"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Product Name"),
                    ),
                    SizedBox(height: 10),

                    // Category Dropdown
                    StreamBuilder(
                      stream:
                          FirebaseFirestore.instance
                              .collection("categories")
                              .snapshots(),
                      builder: (
                        context,
                        AsyncSnapshot<QuerySnapshot> snapshot,
                      ) {
                        if (!snapshot.hasData)
                          return CircularProgressIndicator();
                        List<DropdownMenuItem<String>> categoryItems =
                            snapshot.data!.docs.map((doc) {
                              return DropdownMenuItem(
                                value: doc.id,
                                child: Text(doc["name"]),
                              );
                            }).toList();

                        return DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          items: categoryItems,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                              _selectedSubcategoryId = null;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Select Category",
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 10),

                    // Subcategory Dropdown
                    if (_selectedCategoryId != null)
                      StreamBuilder(
                        stream:
                            FirebaseFirestore.instance
                                .collection("categories")
                                .doc(_selectedCategoryId)
                                .collection("subcategories")
                                .snapshots(),
                        builder: (
                          context,
                          AsyncSnapshot<QuerySnapshot> snapshot,
                        ) {
                          if (!snapshot.hasData)
                            return CircularProgressIndicator();
                          List<DropdownMenuItem<String>> subcategoryItems =
                              snapshot.data!.docs.map((doc) {
                                return DropdownMenuItem(
                                  value: doc.id,
                                  child: Text(doc["name"]),
                                );
                              }).toList();

                          return DropdownButtonFormField<String>(
                            value: _selectedSubcategoryId,
                            items: subcategoryItems,
                            onChanged: (value) {
                              setState(() {
                                _selectedSubcategoryId = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Select Subcategory",
                            ),
                          );
                        },
                      ),

                    SizedBox(height: 10),

                    // Image Upload with Immediate Preview
                    _buildImageUploadButton(
                      "Main Picture",
                      _mainImageBytes,
                      "main",
                      setState,
                    ),
                    _buildImageUploadButton(
                      "Picture 2",
                      _image2Bytes,
                      "image2",
                      setState,
                    ),
                    _buildImageUploadButton(
                      "Picture 3",
                      _image3Bytes,
                      "image3",
                      setState,
                    ),

                    SizedBox(height: 10),

                    TextField(
                      controller: _vendorPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Vendor Price"),
                    ),

                    SizedBox(height: 10),

                    TextField(
                      controller: _detailsController,
                      maxLines: 3,
                      decoration: InputDecoration(labelText: "Product Details"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addProduct,
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildImageUploadButton(
    String label,
    Uint8List? imageBytes,
    String imageType,
    Function setState,
  ) {
    return Row(
      children: [
        // Display Image in a Container
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                imageBytes != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(imageBytes, fit: BoxFit.cover),
                    )
                    : Icon(Icons.image, size: 40, color: Colors.grey),
          ),
        ),
        SizedBox(width: 10), // Spacing between container and button
        // Upload Button
        ElevatedButton(
          onPressed: () => _pickImage(imageType, setState),
          child: Text(label),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Products"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Accepted"),
              Tab(text: "Rejected"),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: _showAddProductDialog,
              child: Text("Add Product"),
            ),
            SizedBox(width: 10),
          ],
        ),
        body: TabBarView(
          children: [
            if (_vendorId != null) ...[
              PendingProducts(vendorId: _vendorId!),
              AcceptedProducts(vendorId: _vendorId!),
              RejectedProducts(vendorId: _vendorId!),
            ] else ...[
              Center(child: CircularProgressIndicator()),
              Center(child: CircularProgressIndicator()),
              Center(child: CircularProgressIndicator()),
            ]
          ],
        ),
      ),
    );
  }
}