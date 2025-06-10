import 'dart:io';
import 'package:bazar_new_web/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VendorProfile extends StatefulWidget {
  final Map<String, dynamic> vendorData;

  const VendorProfile({super.key, required this.vendorData});

  @override
  State<VendorProfile> createState() => _VendorProfileState();
}

class _VendorProfileState extends State<VendorProfile> {
  late Map<String, dynamic> vendorData;

  @override
  void initState() {
    super.initState();
    vendorData = Map.from(widget.vendorData);
  }

  /// ✅ **Updates Firestore & UI**
  void _updateVendorData(String field, String newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vendorId = prefs.getString("id");

    if (vendorId == null) {
      print("⚠️ Vendor ID not found in SharedPreferences.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("vendors")
          .doc(vendorId)
          .update({field: newValue});

      setState(() {
        vendorData[field] = newValue;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$field updated successfully!")));
    } catch (e) {
      print("❌ Error updating vendor data: $e");
    }
  }

  /// ✅ **Handles Profile Picture & Company Logo Upload**
  Future<void> _updateImage(String fieldKey) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? vendorId = prefs.getString("id");

      if (vendorId == null) {
        print("⚠️ Vendor ID not found.");
        return;
      }

      String fileName = "vendors/$vendorId/$fieldKey.jpg";

      // ✅ Upload Image to Firebase Storage
      UploadTask uploadTask = FirebaseStorage.instance
          .ref(fileName)
          .putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // ✅ Update Firestore with new URL
      await FirebaseFirestore.instance
          .collection("vendors")
          .doc(vendorId)
          .update({fieldKey: downloadUrl});

      setState(() {
        vendorData[fieldKey] = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$fieldKey updated successfully!")),
      );
    } catch (e) {
      print("❌ Error uploading $fieldKey: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update $fieldKey")));
    }
  }

  /// ✅ **Dialog Box for Editing Field**
  void _editField(BuildContext context, String fieldName, String fieldKey) {
    if (fieldKey == "profilePicture" || fieldKey == "companyLogo") {
      _updateImage(fieldKey);
      return;
    }

    TextEditingController controller = TextEditingController(
      text: vendorData[fieldKey] ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $fieldName"),
          content: TextField(
            controller: controller,
            obscureText: fieldKey.toLowerCase() == "password", // Hide password
            decoration: InputDecoration(
              labelText: fieldName,
              suffixIcon:
                  fieldKey.toLowerCase() == "password"
                      ? Icon(Icons.lock) // Show lock icon for password
                      : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  _updateVendorData(fieldKey, controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vendor Profile")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Profile Picture (Tap to Edit)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap:
                            () => _editField(
                              context,
                              "Profile Picture",
                              "profilePicture",
                            ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              vendorData["profilePicture"] != null &&
                                      vendorData["profilePicture"].isNotEmpty
                                  ? NetworkImage(vendorData["profilePicture"])
                                  : null,
                          backgroundColor: Colors.grey[300],
                          child:
                              vendorData["profilePicture"] == null ||
                                      vendorData["profilePicture"].isEmpty
                                  ? Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),

                      SizedBox(height: 10),
                      Text("profile Picture"),
                    ],
                  ),

                  Column(
                    children: [
                      GestureDetector(
                        onTap:
                            () => _editField(
                              context,
                              "Company Logo",
                              "companyLogo",
                            ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              vendorData["companyLogo"] != null &&
                                      vendorData["companyLogo"].isNotEmpty
                                  ? NetworkImage(vendorData["companyLogo"])
                                  : null,
                          backgroundColor: Colors.grey[300],
                          child:
                              vendorData["companyLogo"] == null ||
                                      vendorData["companyLogo"].isEmpty
                                  ? Icon(
                                    Icons.business,
                                    size: 40,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Company Logo"),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10),

              SizedBox(height: 20),

              // ✅ Editable Vendor Info Fields
              _editableInfoRow("Name", "name"),
              _editableInfoRow("Email", "email"),
              _editableInfoRow("Phone", "phone"),
              _editableInfoRow("Address", "address"),
              _editableInfoRow("password", "password"),

              SizedBox(height: 20),

              // ✅ Logout Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear(); // ✅ Clear SharedPreferences

                    // ✅ Navigate to SplashScreen() and clear navigation stack
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SplashScreen()),
                      (route) => false,
                    );
                  },
                  icon: Icon(Icons.logout),
                  label: Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ **Helper Widget for Editable Info**
  Widget _editableInfoRow(String label, String fieldKey) {
    return InkWell(
      onTap: () => _editField(context, label, fieldKey),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: Text(
                label.toLowerCase() == "password"
                    ? "••••••" // Hide password
                    : vendorData[fieldKey] ?? "N/A",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.blue),
              ),
            ),
            Icon(Icons.edit, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
