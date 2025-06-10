import 'package:bazar_new_web/vendor/my_products.dart';
import 'package:bazar_new_web/vendor/myorder.dart';
import 'package:bazar_new_web/vendor/vendor_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorHomelist extends StatefulWidget {
  const VendorHomelist({super.key});
  @override
  State<VendorHomelist> createState() => _VendorHomelistState();
}

class _VendorHomelistState extends State<VendorHomelist> {
  String? vendorId; // Store Vendor ID

  @override
  void initState() {
    super.initState();
    _getVendorId(); // Get vendor ID first
  }

  /// ✅ Fetch Vendor ID from SharedPreferences
  Future<void> _getVendorId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      vendorId = prefs.getString("id");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vendor Home"),
        actions: [
          if (vendorId != null)
            StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection("vendors")
                      .doc(vendorId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.error, color: Colors.red),
                  );
                }

                var vendorData = snapshot.data!.data() as Map<String, dynamic>;
                String? vendorLogoUrl = vendorData["companyLogo"];

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  VendorProfile(vendorData: vendorData),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black, // Black border
                          width: 2, // Border thickness
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            vendorLogoUrl != null && vendorLogoUrl.isNotEmpty
                                ? NetworkImage(vendorLogoUrl)
                                : null, // Only set image if vendorLogoUrl is available
                        child:
                            vendorLogoUrl == null || vendorLogoUrl.isEmpty
                                ? Icon(
                                  Icons.business,
                                  size: 24,
                                  color: Colors.white,
                                )
                                : null, // Default icon
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ My Products Container
            GestureDetector(
              onTap: () {
                print("🚀 Navigating to My Products...");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyProducts()),
                );
              },
              child: _buildContainer(
                icon: Icons.storefront,
                text: "My Products",
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20), // Spacing
            // ✅ My Orders Container
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Myorder()),
                );
              },
              child: _buildContainer(
                icon: Icons.shopping_cart,
                text: "My Orders",
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 **Reusable Container Widget**
  Widget _buildContainer({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
