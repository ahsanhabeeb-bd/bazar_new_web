import 'dart:io';
import 'package:bazar_new_web/clients/client_login.dart';
import 'package:bazar_new_web/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientRegistration extends StatefulWidget {
  const ClientRegistration({super.key});

  @override
  State<ClientRegistration> createState() => _ClientRegistrationState();
}

class _ClientRegistrationState extends State<ClientRegistration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  File? _profileImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<String?> _uploadProfileImage(String docId) async {
    if (_profileImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        "clients/$docId/profile.jpg",
      );

      await storageRef.putFile(_profileImage!);

      final downloadUrl = await storageRef.getDownloadURL();

      // ✅ Update Firestore
      await FirebaseFirestore.instance.collection("clients").doc(docId).update({
        "profilePicture": downloadUrl,
      });

      // ✅ Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("profilePicture", downloadUrl);

      return downloadUrl;
    } catch (e) {
      print("Image upload error: $e");
      return null;
    }
  }

  Future<void> _registerClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    String docId = DateTime.now().millisecondsSinceEpoch.toString();
    String? imageUrl = await _uploadProfileImage(docId);

    final clientData = {
      'id': docId,
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'profilePicture': imageUrl ?? '',
      'role': 'client',
      'status': 'accepted',
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('clients')
        .doc(docId)
        .set(clientData);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', docId);
    await prefs.setString('name', clientData['name'] as String);
    await prefs.setString('role', 'client');
    await prefs.setString('phone', clientData['phone'] as String);
    await prefs.setString('address', clientData['address'] as String);
    await prefs.setString('email', clientData['email'] as String);
    await prefs.setString('password', clientData['password'] as String);
    await prefs.setString('status', clientData['status'] as String);
    await prefs.setString('profilePicture', imageUrl ?? '');

    setState(() => isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Registration successful!')));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Client Registration")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Profile Picture
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                            child:
                                _profileImage == null
                                    ? Icon(Icons.add_a_photo, size: 40)
                                    : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Full Name'),
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(labelText: 'Address'),
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator:
                            (val) =>
                                val!.length < 6 ? 'Minimum 6 characters' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _registerClient,
                        child: Text("Register"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ClientLogin()),
                          );
                        },
                        child: Text("Already have an account? Login"),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
