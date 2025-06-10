import 'package:bazar_new_web/clients/client_login.dart';
import 'package:bazar_new_web/pages/cart_page.dart';
import 'package:bazar_new_web/pages/product_description.dart';
import 'package:bazar_new_web/pages/search.dart';
import 'package:bazar_new_web/pages/trending_product.dart';
import 'package:bazar_new_web/pipilica/pipilica_nav.dart';
import 'package:bazar_new_web/pipilica/pipilick_login.dart';
import 'package:bazar_new_web/providers/sliders_provider.dart';
import 'package:bazar_new_web/reselar/login_reselar.dart';
import 'package:bazar_new_web/vendor/login_vendor.dart';
import 'package:bazar_new_web/widgets/banner.dart';
import 'package:bazar_new_web/widgets/brand_scroll.dart';
import 'package:bazar_new_web/widgets/events.dart';
import 'package:bazar_new_web/widgets/events2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PipilikaHome2 extends StatefulWidget {
  const PipilikaHome2({super.key});

  @override
  State<PipilikaHome2> createState() => _PipilikaHome2State();
}

class _PipilikaHome2State extends State<PipilikaHome2> {
  final SliderProvider sliderProvider = SliderProvider();
  String? profilePictureUrl;

  @override
  void initState() {
    super.initState();
    fetchSliders();
    _loadProfilePicture();
  }

  Future<void> fetchSliders() async {
    await sliderProvider.slide1();
    await sliderProvider.slide2();
    await sliderProvider.slide3();
    await sliderProvider.slide4();
    await sliderProvider.slide5();
    setState(() {});
  }

  Future<void> _loadProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePictureUrl = prefs.getString("profilePicture") ?? "";
    });
  }

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .where("status", isEqualTo: "accepted")
              .get();

      List<Map<String, dynamic>> filteredResults =
          snapshot.docs
              .map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return {
                  "id": doc.id,
                  "name": data["name"] ?? "",
                  "image": data["images"]?["main"] ?? "",
                };
              })
              .where(
                (product) =>
                    product["name"].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

      setState(() {
        _searchResults = filteredResults;
      });
    } catch (e) {
      print("\u274c Error searching products: $e");
    }
  }

  Future<Map<String, dynamic>?> _getPipilikaUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString("id");

    if (uid == null || uid.isEmpty) return null;

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('pipilikas')
              .where('id', isEqualTo: uid)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Error fetching user data: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', height: 50, width: 80),
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.group, size: 30, color: Colors.black),
            onSelected: (String value) {
              // Handle selection
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ClientLogin()),
                      );
                    },
                    value: 'User Account',
                    child: Text('User Account'),
                  ),
                  PopupMenuItem<String>(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginVendor()),
                      );
                    },
                    value: 'vendor',
                    child: Text('Vendor Account'),
                  ),
                  PopupMenuItem<String>(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginResaler()),
                      );
                    },
                    value: 'reseller',
                    child: Text('Reseller Account'),
                  ),
                  PopupMenuItem<String>(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PipilikaLogin(),
                        ),
                      );
                    },
                    value: 'pipilika',
                    child: Text('Pipirica Account'),
                  ),
                ],
          ),
          IconButton(
            icon:
                profilePictureUrl != null && profilePictureUrl!.isNotEmpty
                    ? CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(profilePictureUrl!),
                    )
                    : const Icon(Icons.person, size: 30, color: Colors.black),
            onPressed: () async {
              final userData = await _getPipilikaUserData();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PipilickNav(userData: userData!),
                ),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 24),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String? id = prefs.getString("id");

                  if (id == null || id.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please login to view cart"),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartPage()),
                  );
                },
              ),
              Positioned(
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 6,
                  child: Text(
                    "0",
                    style: const TextStyle(fontSize: 8, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final selectedProductId = await showDialog(
                    context: context,
                    builder: (context) => SearchProductDialog(),
                  );

                  if (selectedProductId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => NewProductDescription(
                              productId: selectedProductId,
                            ),
                      ),
                    );
                  }
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(width: 10),
                      Icon(Icons.search, color: Colors.black, size: 30),
                      SizedBox(width: 10),
                      Text(
                        "Search...",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              banner(imageUrls1: sliderProvider.imageUrls1),
              const SizedBox(height: 8),
              events1(
                imageUrls2: sliderProvider.imageUrls2,
                imageUrls3: sliderProvider.imageUrls3,
              ),
              const SizedBox(height: 8),
              events2(
                imageUrls4: sliderProvider.imageUrls4,
                imageUrls5: sliderProvider.imageUrls5,
              ),
              const SizedBox(height: 8),
              Brand_Scroll(),
              const SizedBox(height: 8),
              Trending_Product(),
            ],
          ),
        ),
      ),
    );
  }
}
