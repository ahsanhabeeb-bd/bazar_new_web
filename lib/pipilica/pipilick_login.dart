import 'package:bazar_new_web/pipilica/pipilica_regestration.dart';
import 'package:bazar_new_web/pipilica/pipilika_home2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PipilikaLogin extends StatefulWidget {
  const PipilikaLogin({super.key});

  @override
  State<PipilikaLogin> createState() => _PipilikaLoginState();
}

class _PipilikaLoginState extends State<PipilikaLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('pipilikas')
              .where('loginId', isEqualTo: _email.text.trim())
              .where('password', isEqualTo: _password.text.trim())
              .where('status', isEqualTo: 'accepted')
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials or not accepted yet'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        final userData = querySnapshot.docs.first.data();

        // ✅ Save data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("id", userData['id']);
        await prefs.setString("name", userData['name']);
        await prefs.setString("email", userData['email']);
        await prefs.setString("role", userData['role']);
        await prefs.setString(
          "profilePicture",
          userData['profilePicture'] ?? '',
        );
        await prefs.setString("status", userData['status'] ?? '');

        await prefs.setString("referredBy", userData['referredBy'] ?? '');

        // ✅ Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PipilikaHome2()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome ${userData['name']}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool isPassword,
  ) {
    return SizedBox(
      width: 250,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(labelText: label),
        validator:
            (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pipirica Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextField(_email, "Login ID", false),
                _buildTextField(_password, "Password", true),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _login,
                      child: const Text("Login"),
                    ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => PipilikaRegistration()),
                    );
                  },
                  child: const Text("Pipirica Registration"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
