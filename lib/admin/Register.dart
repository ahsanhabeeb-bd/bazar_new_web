import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Uint8List? _imageBytes;
  Uint8List? _logoBytes;
  Uint8List? _nidBytes;

  String? _imageName;
  String? _logoName;
  String? _nidName;

  File? _selectedImage;
  File? _selectedLogo;
  File? _selectedNID;

  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _pickImage({required String type}) async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        setState(() {
          if (type == "profile") {
            _imageBytes = result.files.first.bytes;
            _imageName = result.files.first.name;
          } else if (type == "logo") {
            _logoBytes = result.files.first.bytes;
            _logoName = result.files.first.name;
          } else if (type == "nid") {
            _nidBytes = result.files.first.bytes;
            _nidName = result.files.first.name;
          }
        });
      }
    } else {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          if (type == "profile") {
            _selectedImage = File(pickedFile.path);
          } else if (type == "logo") {
            _selectedLogo = File(pickedFile.path);
          } else if (type == "nid") {
            _selectedNID = File(pickedFile.path);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Name Field
                  _buildTextField(_nameController, "Name"),

                  // Email Field
                  _buildTextField(_emailController, "Email", isEmail: true),

                  // Password Field
                  _buildTextField(
                    _passwordController,
                    "Password",
                    isPassword: true,
                  ),

                  // Phone Field
                  _buildTextField(_phoneController, "Phone", isPhone: true),

                  // Address Field
                  _buildTextField(_addressController, "Address"),

                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Select Role"),
                    value: _selectedRole,
                    items:
                        ["Vendor", "Reseller"].map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                    onChanged: (value) => setState(() => _selectedRole = value),
                    validator:
                        (value) => value == null ? "Select a role" : null,
                  ),

                  SizedBox(height: 20),

                  // Profile Picture Upload
                  _buildUploadSection(
                    title: "Upload Profile Picture",
                    onPick: () => _pickImage(type: "profile"),
                    imageBytes: _imageBytes,
                    selectedImage: _selectedImage,
                  ),

                  // Company Logo Upload
                  _buildUploadSection(
                    title: "Upload Company Logo",
                    onPick: () => _pickImage(type: "logo"),
                    imageBytes: _logoBytes,
                    selectedImage: _selectedLogo,
                  ),

                  // NID/Trade License Upload
                  _buildUploadSection(
                    title: "Upload NID/Trade License",
                    onPick: () => _pickImage(type: "nid"),
                    imageBytes: _nidBytes,
                    selectedImage: _selectedNID,
                  ),

                  SizedBox(height: 20),

                  // Register Button with Gradient
                  GestureDetector(
                    onTap: () {},
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

  // 🔹 Reusable Upload Section
  Widget _buildUploadSection({
    required String title,
    required VoidCallback onPick,
    Uint8List? imageBytes,
    File? selectedImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  imageBytes != null
                      ? MemoryImage(imageBytes)
                      : selectedImage != null
                      ? FileImage(selectedImage)
                      : AssetImage("assets/images/vendor.png") as ImageProvider,
              radius: 20,
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.file_upload, color: Colors.grey),
              onPressed: onPick,
            ),
            Text(
              "Upload",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
