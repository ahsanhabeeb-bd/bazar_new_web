// import 'package:bazar_new_mobile/pages/login_pipilika.dart';
// import 'package:bazar_new_mobile/pipilika/pipilick_login.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   _RegisterPageState createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();

//   bool _isPasswordVisible = false;
//   bool _isLoading = false;

//   // Role List
//   final Map<String, String> _roles = {
//     // 'admin': 'https://oboefbazar.com/api/admins',
//     'vendor': ' https://oboefbazar.com/api/vendors',
//     'user': 'https://oboefbazar.com/api/clients',
//     'reseller': 'https://oboefbazar.com/api/resellers',
//   };

//   String? _selectedRole;

//   Future<void> _registerUser() async {
//     if (!_formKey.currentState!.validate() || _selectedRole == null) return;

//     setState(() {
//       _isLoading = true;
//     });

//     final String apiUrl = _roles[_selectedRole]!;
//     final url = Uri.parse(apiUrl);

//     final Map<String, String> body = {
//       "name": _nameController.text,
//       "email": _emailController.text,
//       "password": _passwordController.text,
//       "phone": _phoneController.text,
//       "address": _addressController.text,
//       "role": _selectedRole!,
//       "status": "active",
//     };

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "${_selectedRole!.toUpperCase()} registered successfully!",
//             ),
//             backgroundColor: Colors.green,
//           ),
//         );

//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => PipilickLogin()),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to register ${_selectedRole!.toUpperCase()}"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {}

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 25.0),
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Image.asset("assets/images/logo.png", height: 100),
//                   const SizedBox(height: 20),
//                   const Text(
//                     "User Registration",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 20),

//                   TextFormField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: "Full Name",
//                       prefixIcon: Icon(Icons.person),
//                     ),
//                     validator:
//                         (value) => value!.isEmpty ? "Enter full name" : null,
//                   ),
//                   const SizedBox(height: 15),

//                   TextFormField(
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: InputDecoration(
//                       labelText: "Email",
//                       prefixIcon: Icon(Icons.email),
//                     ),
//                     validator: (value) => value!.isEmpty ? "Enter email" : null,
//                   ),
//                   const SizedBox(height: 15),

//                   TextFormField(
//                     controller: _phoneController,
//                     keyboardType: TextInputType.phone,
//                     decoration: InputDecoration(
//                       labelText: "Phone Number",
//                       prefixIcon: Icon(Icons.phone),
//                     ),
//                     validator:
//                         (value) => value!.isEmpty ? "Enter phone number" : null,
//                   ),
//                   TextFormField(
//                     controller: _addressController,

//                     decoration: InputDecoration(
//                       labelText: "Address",
//                       prefixIcon: Icon(Icons.phone),
//                     ),
//                     validator:
//                         (value) => value!.isEmpty ? "Enter Address" : null,
//                   ),
//                   const SizedBox(height: 15),

//                   // Role Selection Dropdown
//                   DropdownButtonFormField<String>(
//                     value: _selectedRole,
//                     decoration: InputDecoration(
//                       labelText: "Select Role",
//                       prefixIcon: Icon(Icons.person_outline),
//                     ),
//                     items:
//                         _roles.keys.map((role) {
//                           return DropdownMenuItem<String>(
//                             value: role,
//                             child: Text(role),
//                           );
//                         }).toList(),
//                     onChanged: (newValue) {
//                       setState(() {
//                         _selectedRole = newValue;
//                       });
//                     },
//                     validator:
//                         (value) => value == null ? "Select a role" : null,
//                   ),
//                   const SizedBox(height: 15),

//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: !_isPasswordVisible,
//                     decoration: InputDecoration(
//                       labelText: "Password",
//                       prefixIcon: Icon(Icons.lock),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _isPasswordVisible
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                         ),
//                         onPressed:
//                             () => setState(
//                               () => _isPasswordVisible = !_isPasswordVisible,
//                             ),
//                       ),
//                     ),
//                     validator:
//                         (value) =>
//                             value!.length < 6
//                                 ? "Password must be at least 6 characters"
//                                 : null,
//                   ),
//                   const SizedBox(height: 20),

//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _registerUser,
//                     child:
//                         _isLoading
//                             ? CircularProgressIndicator(color: Colors.white)
//                             : Text("Register"),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
