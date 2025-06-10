import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final String token;
  final String userId;

  const EditProfilePage({required this.token, required this.userId, super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAdminDetails();
  }

  Future<void> _fetchAdminDetails() async {
    final url = Uri.parse(
      "https://oboefbazar.com/api/admins/${widget.userId}",
    ); // Make sure userId is correct

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}", // Send token
          "Accept": "application/json", // Ensure JSON response
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _nameController.text =
              jsonResponse["admins"][0]["name"]; // Ensure correct JSON structure
        });
      } else {
        debugPrint("Failed to fetch admin details: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching admin details: $e");
    }
  }

  Future<void> _updateAdminName() async {
    final url = Uri.parse("https://oboefbazar.com/api/admins/${widget.userId}");

    setState(() {
      _isLoading = true;
    });

    final Map<String, String> body = {"name": _nameController.text};

    try {
      final response = await http.put(
        url,
        headers: {
          "Authorization":
              "Bearer ${widget.token}", // Ensure token is sent properly
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Admin Name Updated Successfully!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Name Updated Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        debugPrint("❌ Failed to update admin: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error updating admin: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Update Name"),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _updateAdminName,
            child:
                _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Update Name"),
          ),
        ],
      ),
    );
  }
}
