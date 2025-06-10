import 'package:bazar_new_web/admin/accepted_product.dart';
import 'package:bazar_new_web/admin/category_screen.dart';
import 'package:bazar_new_web/admin/requested_reseller_list.dart';
import 'package:bazar_new_web/admin/vendor_product_request.dart';
import 'package:bazar_new_web/admin/vendorlist.dart';
import 'package:bazar_new_web/providers/login_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 1,
        leading: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: screenWidth * 0.05,
              child: Text(
                "A",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 15, 44, 58),
        title: Text(
          'Admin Home',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
          ),
        ),
        centerTitle: true,
      ),
      drawer: drawer(context: context),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: screenHeight * 0.06,
            width: screenWidth,
            decoration: BoxDecoration(
              color: const Color.fromARGB(227, 223, 194, 0),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: const Color.fromARGB(255, 177, 177, 177),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              "Dashboard",
              style: TextStyle(
                color: const Color.fromARGB(255, 75, 75, 75),
                fontSize: screenWidth * 0.05,
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.50, // Adjust height as needed
            width: screenWidth,
            child: GridView.builder(
              padding: EdgeInsets.all(screenWidth * 0.02),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 items per row
                crossAxisSpacing: 10, // Space between columns
                mainAxisSpacing: 10, // Space between rows
                childAspectRatio: 0.9, // Adjust the aspect ratio for tile shape
              ),
              itemCount: 5, // Update according to the number of items
              itemBuilder: (context, index) {
                final items = [
                  {
                    "title": "Accepted Product",
                    "image": "assets/images/Accepted.png",
                    "page": AcceptedProduct(),
                  },
                  {
                    "title": "Requested Product",
                    "image": "assets/images/requested.png",
                    "page": Vendor_requestedProduct(),
                  },
                  {
                    "title": "Requested Vendor",
                    "image": "assets/images/vendor.png",
                    "page": Requested_Vendorlist(),
                  },
                  {
                    "title": "Requested Reseller",
                    "image": "assets/images/reseller.png",
                    "page": Requested_ResellerList(),
                  },
                  {
                    "title": "Add Category",
                    "image": "assets/images/catagory.png",
                    "page": CategoryScreen(),
                  },
                ];

                return _buildDashboardTile(
                  context,
                  items[index]["title"] as String,
                  items[index]["image"] as String,
                  items[index]["page"] as Widget,
                  screenWidth,
                  screenHeight,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile(
    BuildContext context,
    String title,
    String imagePath,
    Widget page,
    double screenWidth,
    double screenHeight,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.02),
        child: Container(
          height: 400,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromARGB(255, 15, 44, 58),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: const Color.fromARGB(255, 177, 177, 177),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, height: 30, width: 30),
              const Divider(color: Colors.white, thickness: 0.5),
              Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class drawer extends StatelessWidget {
  const drawer({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, loginprovider, child) {
        return Drawer(
          elevation: 1,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      offset: Offset(0, 2),
                      color: Color.fromARGB(255, 164, 164, 164),
                    ),
                  ],
                  color: Color.fromARGB(255, 15, 44, 58),
                ),
                accountName: Text(
                  loginprovider.adminName.isNotEmpty
                      ? loginprovider.adminName
                      : "Unknown",
                ),
                accountEmail: const Text('Admin@example.com'),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text('A', style: TextStyle(fontSize: 40.0)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.blue),
                title: const Text('Requested Product'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Vendor_requestedProduct(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Accepted Product'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AcceptedProduct()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.list,
                  color: Color.fromARGB(255, 201, 151, 13),
                ),
                title: const Text('Vendor List'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Requested_Vendorlist(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.category,
                  color: Color.fromARGB(255, 0, 146, 0),
                ),
                title: const Text('Add Category'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.lock,
                  color: Color.fromARGB(255, 2, 17, 95),
                ),
                title: const Text('Change password'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => Container(
                          child: AlertDialog(
                            title: const Text('Update Password'),
                            content: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Curent Password',
                                  ),
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'New Password',
                                  ),
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Confirm Password',
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              CupertinoButton(
                                sizeStyle: CupertinoButtonSize.small,
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              CupertinoButton(
                                sizeStyle: CupertinoButtonSize.small,
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Update',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts, color: Colors.blue),
                title: const Text('Update Profile'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => Container(
                          child: AlertDialog(
                            title: const Text('Update Profile'),
                            content: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                  ),
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                  ),
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Phone',
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              CupertinoButton(
                                sizeStyle: CupertinoButtonSize.small,
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              CupertinoButton(
                                sizeStyle: CupertinoButtonSize.small,
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Update',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  // Add logout functionality here
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
