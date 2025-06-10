import 'package:bazar_new_web/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationResaler extends StatefulWidget {
  const RegistrationResaler({super.key});

  @override
  _Registrationresallertate createState() => _Registrationresallertate();
}

class _Registrationresallertate extends State<RegistrationResaler> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Uint8List? _imageBytes;
  Uint8List? _logoBytes;
  Uint8List? _nidBytes;

  String? _imageUrl;
  String? _logoUrl;
  String? _nidUrl;

  bool _isLoading = false;

  // 🔹 Pick Image (for web & mobile)
  Future<void> _pickImage({required String type}) async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        setState(() {
          if (type == "profile") {
            _imageBytes = result.files.first.bytes;
          } else if (type == "logo") {
            _logoBytes = result.files.first.bytes;
          } else if (type == "nid") {
            _nidBytes = result.files.first.bytes;
          }
        });
      }
    } else {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        Uint8List imageData = await pickedFile.readAsBytes();
        setState(() {
          if (type == "profile") {
            _imageBytes = imageData;
          } else if (type == "logo") {
            _logoBytes = imageData;
          } else if (type == "nid") {
            _nidBytes = imageData;
          }
        });
      }
    }
  }

  // 🔹 Upload to Firebase Storage
  Future<String?> _uploadToStorage(Uint8List? file, String path) async {
    if (file == null) return null;
    Reference ref = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // 🔹 Register Resaler & Save Data in SharedPreferences
  Future<void> _registerResaler() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null || _logoBytes == null || _nidBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("All images must be uploaded"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    String docId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      // Upload images
      _imageUrl = await _uploadToStorage(
        _imageBytes,
        "resaller/$docId/profile.jpg",
      );
      _logoUrl = await _uploadToStorage(_logoBytes, "resaller/$docId/logo.jpg");
      _nidUrl = await _uploadToStorage(_nidBytes, "resaller/$docId/nid.jpg");

      // Resaler Data
      Map<String, dynamic> resalerData = {
        "id": docId,
        "name": _nameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "phone": _phoneController.text,
        "address": _addressController.text,
        "profilePicture": _imageUrl,
        "companyLogo": _logoUrl,
        "nid": _nidUrl,
        "status": "pending",
        "role": "reseller",
      };

      // Save to Firestore (resaller collection)
      await FirebaseFirestore.instance
          .collection("resellers")
          .doc(docId)
          .set(resalerData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Resaler registration successful!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Resaler Registration"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, "Name"),
              _buildTextField(_emailController, "Email", isEmail: true),
              _buildTextField(
                _passwordController,
                "Password",
                isPassword: true,
              ),
              _buildTextField(_phoneController, "Phone", isPhone: true),
              _buildTextField(_addressController, "Address"),

              SizedBox(height: 20),

              _buildUploadSection(
                title: "Upload Profile Picture",
                onPick: () => _pickImage(type: "profile"),
                imageBytes: _imageBytes,
              ),

              SizedBox(height: 20),

              GestureDetector(
                onTap: _registerResaler,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable Text Field
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType:
          isEmail
              ? TextInputType.emailAddress
              : isPhone
              ? TextInputType.phone
              : TextInputType.text,
      obscureText: isPassword,
      validator: (value) {
        if (value!.isEmpty) return "Enter your $label";
        if (isEmail && !value.contains("@")) return "Enter a valid email";
        if (isPassword && value.length < 6)
          return "Password must be at least 6 characters";
        return null;
      },
    );
  }

  // 🔹 Reusable Upload Section with Image Preview
  Widget _buildUploadSection({
    required String title,
    required VoidCallback onPick,
    Uint8List? imageBytes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            // Image Preview
            imageBytes != null
                ? Image.memory(
                  imageBytes,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
                : Icon(Icons.image, size: 80, color: Colors.grey),
            SizedBox(width: 10),

            // Upload Button
            ElevatedButton.icon(
              onPressed: onPick,
              icon: Icon(Icons.upload),
              label: Text("Upload"),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
