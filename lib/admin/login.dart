import 'dart:convert';
import 'dart:typed_data';
import 'package:bazar_new_web/providers/login_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class login_page extends StatefulWidget {
  @override
  _login_pageState createState() => _login_pageState();
}

class _login_pageState extends State<login_page> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Consumer(
        builder: (context, LoginProvider loginProvider, child) {
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              width:
                  MediaQuery.of(context).size.width * 0.9, // Responsive width
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                    offset: Offset(0, 5), // Slight elevation effect
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Wrap content height
                    children: [
                      Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: "Email"),
                        keyboardType: TextInputType.emailAddress,
                        validator:
                            (value) =>
                                value!.contains("@")
                                    ? null
                                    : "Enter a valid email",
                      ),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: "Password"),
                        obscureText: true,
                        validator:
                            (value) =>
                                value!.length >= 6
                                    ? null
                                    : "Password must be 6+ chars",
                      ),

                      // Role Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: "Select Role"),
                        value: _selectedRole,
                        items:
                            ["admin", "vendor", "reseller"].map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                        onChanged:
                            (value) => setState(() => _selectedRole = value),
                        validator:
                            (value) => value == null ? "Select a role" : null,
                      ),

                      SizedBox(height: 20),

                      // Register Button with Gradient
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            loginProvider.loginAdmin(
                              context: context,
                              email: _emailController.text,
                              password: _passwordController.text,
                              role: _selectedRole!,
                            );
                          }
                        },
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
                              loginProvider.isLoading
                                  ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    "Login",
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
          );
        },
      ),
    );
  }
}
