import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class resellermodel {
  final String id;
  final String logo;
  final String UserName;
  final String phonenumber;
  final String email;
  final String password;
  final String role;
  final String area;
  final String isapproveby;

  resellermodel({
    required this.id,
    required this.logo,
    required this.UserName,
    required this.phonenumber,
    required this.email,
    required this.password,
    required this.role,
    required this.area,
    required this.isapproveby,
  });
}

// Sample Product list
final List<resellermodel> reseller = [
  resellermodel(
    id: '1',
    UserName: 'Reseller 1',
    phonenumber: '1234567890',
    email: 'sM7H8@example.com',
    password: 'password1',
    role: 'Reseller',
    area: 'Area 1',
    isapproveby: 'Admin',
    logo: 'assets/images/baby_care.png',
  ),
  resellermodel(
    id: '2',
    UserName: 'Reseller 2',
    phonenumber: '1234567890',
    email: 'sM7H8@example.com',
    password: 'password2',
    role: 'Reseller',
    area: 'Area 2',
    isapproveby: 'Admin',
    logo: 'assets/images/baby_care.png',
  ),
  resellermodel(
    id: '3',
    UserName: 'Reseller 3',
    phonenumber: '1234567890',
    email: 'sM7H8@example.com',
    password: 'password1',
    role: 'Reseller',
    area: 'Area 1',
    isapproveby: 'Admin',
    logo: 'assets/images/baby_care.png',
  ),
];

// ignore: camel_case_types
class Requested_ResellerList extends StatelessWidget {
  const Requested_ResellerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reseller List")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: ListView.builder(
                itemCount: reseller.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color.fromARGB(255, 22, 35, 81),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white),
                    ),
                    shadowColor: const Color.fromARGB(255, 22, 86, 0),
                    elevation: 4,
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Reseller ID :${reseller[index].id}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
