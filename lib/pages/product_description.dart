import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewProductDescription extends StatefulWidget {
  final String productId;

  const NewProductDescription({super.key, required this.productId});

  @override
  State<NewProductDescription> createState() => _NewProductDescriptionState();
}

class _NewProductDescriptionState extends State<NewProductDescription> {
  bool isLoading = true;
  Map<String, dynamic>? product;
  late String mainImage;
  String? userRole;
  String? userStatus;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    fetchProductDetails();
  }

  /// ✅ **Load Role & Status from SharedPreferences**
  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString("role");
      userStatus = prefs.getString("status");
    });
    print("🟢 User Role: $userRole, Status: $userStatus"); // Debugging
  }

  /// ✅ **Fetch Product Details from Firestore**
  Future<void> fetchProductDetails() async {
    try {
      DocumentSnapshot productSnapshot =
          await FirebaseFirestore.instance
              .collection("products")
              .doc(widget.productId)
              .get();

      if (productSnapshot.exists) {
        setState(() {
          product = productSnapshot.data() as Map<String, dynamic>;
          mainImage = product!['images']['main'] ?? 'assets/images/default.jpg';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("⚠️ Product not found in Firestore");
      }
    } catch (e) {
      print("❌ Error fetching product: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// ✅ **Price Text Style**
  TextStyle _priceStyle() {
    return const TextStyle(
      fontSize: 22,
      color: Colors.teal,
      fontWeight: FontWeight.bold,
    );
  }

  String _getCollectionForRole(String role) {
    switch (role) {
      case "vendor":
        return "vendors";
      case "reseller":
        return "resellers";
      case "pipilika":
        return "pipilikas";
      default:
        return "clients";
    }
  }

  Future<void> addToCart({
    required BuildContext context,
    required String clientId,
    required String role,
    required String productId,
    required String productName,
    required String productImage,
    required double customerPrice,
    required double resellerPrice,
    required double pipilikaPrice,
    required String vendorId,
  }) async {
    final collection = FirebaseFirestore.instance
        .collection(_getCollectionForRole(role))
        .doc(clientId)
        .collection("cart");

    final doc = await collection.doc(productId).get();

    if (doc.exists) {
      await collection.doc(productId).update({
        "quantity": FieldValue.increment(1),
        "timestamp": FieldValue.serverTimestamp(),
      });
    } else {
      await collection.doc(productId).set({
        "productId": productId,
        "productName": productName,
        "productImage": productImage,
        "customerPrice": customerPrice,
        "resellerPrice": resellerPrice,
        "pipilikaPrice": pipilikaPrice,
        "vendorId": vendorId,
        "quantity": 1,
        "timestamp": FieldValue.serverTimestamp(),
        "isAdded": true,
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Product added to cart")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : product == null
              ? const Center(child: Text("Product not found"))
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Main Row - বাম পাশে ছোট ছবি, দান পাশে বড় ছবি ও details
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 বাম পাশের Column - 3টি ছোট ছবি
                          Column(
                            children: [
                              _thumbnailImage(product!['images']['main']),
                              const SizedBox(height: 8),
                              if (product!['images']['image2'] != null)
                                _thumbnailImage(product!['images']['image2']),
                              const SizedBox(height: 8),
                              if (product!['images']['image3'] != null)
                                _thumbnailImage(product!['images']['image3']),
                            ],
                          ),

                          const SizedBox(width: 10),

                          // 🔹 দান পাশের Column - বড় ছবি ও Product Details
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // বড় ছবি
                              Container(
                                height: 370,
                                width: 370,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(mainImage),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),
                            ],
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Product Name
                                Text(
                                  product!['name'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                const SizedBox(height: 15),

                                // Details
                                Text(
                                  "Details:",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  product!['details'] ??
                                      "No description available",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 Add to Cart Button - Row এর নিচে
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Spacer(), // Pushes the price to the center
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (userRole == "vendor" &&
                                  userStatus == "accepted") ...[
                                Text(
                                  'Vendor: ${product!['vendorPrice']} Tk',
                                  style: _priceStyle(),
                                ),
                                Text(
                                  'Reseller: ${product!['resellerPrice']} Tk',
                                  style: _priceStyle(),
                                ),
                                Text(
                                  'Customer: ${product!['customerPrice']} Tk',
                                  style: _priceStyle(),
                                ),
                              ] else if (userRole == "reseller" &&
                                  userStatus == "accepted") ...[
                                Text(
                                  'Reseller: ${product!['resellerPrice']} Tk',
                                  style: _priceStyle(),
                                ),
                                Text(
                                  'Customer: ${product!['customerPrice']} Tk',
                                  style: _priceStyle(),
                                ),
                              ] else if (userRole == "pipilika" &&
                                  userStatus == "accepted") ...[
                                Text(
                                  'Pipirica: ${product!['pipilikaPrice']} Tk',
                                  style: _priceStyle(),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Price: ${product!['customerPrice']} Tk',
                                    style: _priceStyle(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Spacer(), // Pushes the button to the right
                          FutureBuilder(
                            future: SharedPreferences.getInstance(),
                            builder: (
                              context,
                              AsyncSnapshot<SharedPreferences> prefsSnapshot,
                            ) {
                              if (!prefsSnapshot.hasData) {
                                return const CircularProgressIndicator();
                              }

                              final prefs = prefsSnapshot.data!;
                              final String? clientId = prefs.getString("id");
                              final String? role = prefs.getString("role");

                              if (clientId == null || role == null) {
                                return const Text("Please login first");
                              }

                              return StreamBuilder<DocumentSnapshot>(
                                stream:
                                    FirebaseFirestore.instance
                                        .collection(_getCollectionForRole(role))
                                        .doc(clientId)
                                        .collection("cart")
                                        .doc(widget.productId)
                                        .snapshots(),
                                builder: (context, snapshot) {
                                  bool isAdded =
                                      snapshot.data?.data() != null &&
                                      (snapshot.data!.data()
                                              as Map<String,
                                                dynamic>)["isAdded"] ==
                                          true;

                                  return Container(
                                    height: 58,
                                    width: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          isAdded ? Colors.grey : Colors.orange,
                                    ),
                                    child: TextButton(
                                      onPressed:
                                          isAdded
                                              ? null
                                              : () async {
                                                await addToCart(
                                                  context: context,
                                                  clientId: clientId,
                                                  role: role,
                                                  productId: widget.productId,
                                                  productName: product!['name'],
                                                  productImage:
                                                      product!['images']['main'],
                                                  customerPrice:
                                                      (product!['customerPrice']
                                                              as num)
                                                          .toDouble(),
                                                  resellerPrice:
                                                      (product!['resellerPrice']
                                                              as num)
                                                          .toDouble(),
                                                  pipilikaPrice:
                                                      (product!['pipilikaPrice']
                                                              as num)
                                                          .toDouble(),
                                                  vendorId:
                                                      product!['vendorId'],
                                                );
                                              },
                                      child: Text(
                                        isAdded ? "Added" : "Add to Cart",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }

  /// ✅ **Thumbnail Image Widget**
  Widget _thumbnailImage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        setState(() {
          mainImage = imageUrl;
        });
      },
      child: Container(
        height: 120,
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 2),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  /// ✅ **Reusable Action Button**
  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
