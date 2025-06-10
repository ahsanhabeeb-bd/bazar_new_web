import 'dart:io';
import 'package:bazar_new_web/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ClientProfile extends StatefulWidget {
  const ClientProfile({super.key});

  @override
  State<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> {
  Map<String, dynamic> clientData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClientData();
  }

  Future<void> _fetchClientData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? clientId = prefs.getString("id");

      if (clientId == null) {
        print("⚠️ Client ID not found.");
        return;
      }

      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance
              .collection("clients")
              .doc(clientId)
              .get();

      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          clientData = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        print("⚠️ No client data found.");
      }
    } catch (e) {
      print("❌ Error fetching client data: $e");
    }
  }

  void _updateClientData(String field, String newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clientId = prefs.getString("id");

    if (clientId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection("clients")
          .doc(clientId)
          .update({field: newValue});

      setState(() {
        clientData[field] = newValue;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$field updated successfully!")));
    } catch (e) {
      print("❌ Error updating client data: $e");
    }
  }

  Future<void> _updateImage(String fieldKey) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? clientId = prefs.getString("id");

      if (clientId == null) return;

      String fileName = "clients/$clientId/$fieldKey.jpg";

      UploadTask uploadTask = FirebaseStorage.instance
          .ref(fileName)
          .putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("clients")
          .doc(clientId)
          .update({fieldKey: downloadUrl});

      // ✅ Save updated image URL to SharedPreferences
      await prefs.setString("profilePicture", downloadUrl);

      setState(() {
        clientData[fieldKey] = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$fieldKey updated successfully!")),
      );
    } catch (e) {
      print("❌ Error uploading $fieldKey: $e");
    }
  }

  void _editField(BuildContext context, String fieldName, String fieldKey) {
    if (fieldKey == "profilePicture") {
      _updateImage(fieldKey);
      return;
    }

    TextEditingController controller = TextEditingController(
      text: clientData[fieldKey] ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $fieldName"),
          content: TextField(
            controller: controller,
            obscureText: fieldKey == "password",
            decoration: InputDecoration(
              labelText: fieldName,
              suffixIcon:
                  fieldKey == "password" ? const Icon(Icons.lock) : null,
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
                  _updateClientData(fieldKey, controller.text);
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
      appBar: AppBar(title: const Text("Client Profile")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: _imageSection("Profile Picture", "profilePicture"),
                    ),
                    const SizedBox(height: 20),
                    _editableInfoRow("Name", "name"),
                    _editableInfoRow("Email", "email"),
                    _editableInfoRow("Phone", "phone"),
                    _editableInfoRow("Address", "address"),
                    _editableInfoRow("Password", "password"),
                    const SizedBox(height: 20),
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

  /// ✅ Profile Picture Widget
  Widget _imageSection(String label, String fieldKey) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _editField(context, label, fieldKey),
          child: CircleAvatar(
            radius: 50,
            backgroundImage:
                clientData[fieldKey] != null && clientData[fieldKey].isNotEmpty
                    ? NetworkImage(clientData[fieldKey])
                    : null,
            backgroundColor: Colors.grey[300],
            child:
                clientData[fieldKey] == null || clientData[fieldKey].isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
          ),
        ),
        const SizedBox(height: 10),
        Text(label),
      ],
    );
  }

  /// ✅ Editable Info Row
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
                fieldKey == "password"
                    ? "••••••"
                    : clientData[fieldKey] ?? "N/A",
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
