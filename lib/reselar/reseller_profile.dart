import 'dart:io';

import 'package:bazar_new_web/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ResellerProfile extends StatefulWidget {
  const ResellerProfile({super.key});

  @override
  State<ResellerProfile> createState() => _ResellerProfileState();
}

class _ResellerProfileState extends State<ResellerProfile> {
  Map<String, dynamic> resellerData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResellerData();
  }

  /// ✅ **Fetch Reseller Data from Firestore**
  Future<void> _fetchResellerData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? resellerId = prefs.getString("id");

      if (resellerId == null) {
        print("⚠️ Reseller ID not found.");
        return;
      }

      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance
              .collection("resellers")
              .doc(resellerId)
              .get();

      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          resellerData = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        print("⚠️ No reseller data found.");
      }
    } catch (e) {
      print("❌ Error fetching reseller data: $e");
    }
  }

  /// ✅ **Update Firestore Field**
  void _updateResellerData(String field, String newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? resellerId = prefs.getString("id");

    if (resellerId == null) {
      print("⚠️ Reseller ID not found.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("resellers")
          .doc(resellerId)
          .update({field: newValue});

      setState(() {
        resellerData[field] = newValue;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$field updated successfully!")));
    } catch (e) {
      print("❌ Error updating reseller data: $e");
    }
  }

  /// ✅ **Handle Profile Picture & Logo Upload**
  Future<void> _updateImage(String fieldKey) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? resellerId = prefs.getString("id");

      if (resellerId == null) {
        print("⚠️ Reseller ID not found.");
        return;
      }

      String fileName = "resellers/$resellerId/$fieldKey.jpg";

      // ✅ Upload to Firebase Storage
      UploadTask uploadTask = FirebaseStorage.instance
          .ref(fileName)
          .putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // ✅ Update Firestore
      await FirebaseFirestore.instance
          .collection("resellers")
          .doc(resellerId)
          .update({fieldKey: downloadUrl});

      setState(() {
        resellerData[fieldKey] = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$fieldKey updated successfully!")),
      );
    } catch (e) {
      print("❌ Error uploading $fieldKey: $e");
    }
  }

  /// ✅ **Dialog for Editing Fields**
  void _editField(BuildContext context, String fieldName, String fieldKey) {
    if (fieldKey == "profilePicture" || fieldKey == "companyLogo") {
      _updateImage(fieldKey);
      return;
    }

    TextEditingController controller = TextEditingController(
      text: resellerData[fieldKey] ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $fieldName"),
          content: TextField(
            controller: controller,
            obscureText: fieldKey.toLowerCase() == "password",
            decoration: InputDecoration(
              labelText: fieldName,
              suffixIcon:
                  fieldKey.toLowerCase() == "password"
                      ? const Icon(Icons.lock)
                      : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  _updateResellerData(fieldKey, controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reseller Profile")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Profile & Logo Images
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _imageSection("Profile Picture", "profilePicture"),
                        _imageSection("Company Logo", "companyLogo"),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ✅ Editable Info Fields
                    _editableInfoRow("Name", "name"),
                    _editableInfoRow("Email", "email"),
                    _editableInfoRow("Phone", "phone"),
                    _editableInfoRow("Address", "address"),
                    _editableInfoRow("Password", "password"),

                    const SizedBox(height: 20),

                    // ✅ Logout Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SplashScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  /// ✅ **Profile Picture & Logo Widget**
  Widget _imageSection(String label, String fieldKey) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _editField(context, label, fieldKey),
          child: CircleAvatar(
            radius: 50,
            backgroundImage:
                resellerData[fieldKey] != null &&
                        resellerData[fieldKey].isNotEmpty
                    ? NetworkImage(resellerData[fieldKey])
                    : null,
            backgroundColor: Colors.grey[300],
            child:
                resellerData[fieldKey] == null || resellerData[fieldKey].isEmpty
                    ? Icon(
                      fieldKey == "profilePicture"
                          ? Icons.person
                          : Icons.business,
                      size: 40,
                      color: Colors.white,
                    )
                    : null,
          ),
        ),
        const SizedBox(height: 10),
        Text(label),
      ],
    );
  }

  /// ✅ **Editable Info Row**
  Widget _editableInfoRow(String label, String fieldKey) {
    return InkWell(
      onTap: () => _editField(context, label, fieldKey),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                label.toLowerCase() == "password"
                    ? "••••••"
                    : resellerData[fieldKey] ?? "N/A",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            const Icon(Icons.edit, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
