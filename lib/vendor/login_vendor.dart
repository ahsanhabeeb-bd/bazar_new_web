import 'package:bazar_new_web/splash_screen.dart';
import 'package:bazar_new_web/vendor/registration_vendor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginVendor extends StatefulWidget {
  const LoginVendor({super.key});

  @override
  _LoginVendorState createState() => _LoginVendorState();
}

class _LoginVendorState extends State<LoginVendor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // 🔹 Function to check credentials in Firestore & Save in SharedPreferences
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection("vendors")
              .where("email", isEqualTo: _emailController.text)
              .where("password", isEqualTo: _passwordController.text)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get Vendor Data
        Map<String, dynamic> vendorData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;

        String status = vendorData["status"] ?? "pending";

        if (status == "accepted") {
          // ✅ Save Data in SharedPreferences Only If Approved
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("id", vendorData["id"] ?? "");
          await prefs.setString("name", vendorData["name"] ?? "");
          await prefs.setString("email", vendorData["email"] ?? "");
          await prefs.setString("password", vendorData["password"] ?? "");
          await prefs.setString("phone", vendorData["phone"] ?? "");
          await prefs.setString("address", vendorData["address"] ?? "");
          await prefs.setString(
            "profilePicture",
            vendorData["profilePicture"] ?? "",
          );
          await prefs.setString("companyLogo", vendorData["companyLogo"] ?? "");
          await prefs.setString("nid", vendorData["nid"] ?? "");
          await prefs.setString("status", vendorData["status"] ?? "");
          await prefs.setString("role", vendorData["role"] ?? "");

          // ✅ Login Success - Navigate to VendorHome()
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Successful!"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
          );
        } else {
          // ❌ Status Not Approved
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Your account is not approved yet."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // ❌ Invalid Email or Password
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid email or password"),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/images/logo.png", height: 120),
                  const SizedBox(height: 20),

                  const Text(
                    "Welcome Back! 👋",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Login to continue",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        print("Forgot Password Clicked");
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Login",
                                style: TextStyle(fontSize: 18),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Up Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegistrationVendor(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
