import 'package:bazar_new_web/pages/product_description.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Trending_Product extends StatefulWidget {
  final String? selectedCategoryId;
  final String? selectedSubcategoryId;

  const Trending_Product({
    Key? key,
    this.selectedCategoryId,
    this.selectedSubcategoryId,
  }) : super(key: key);

  @override
  State<Trending_Product> createState() => _Trending_ProductState();
}

class _Trending_ProductState extends State<Trending_Product> {
  late List<bool> _isHovered;
  String? userRole;
  String? userStatus;
  double long = 0.0;

  @override
  void initState() {
    super.initState();
    _isHovered = [];
    _loadUserRole();
  }

  /// ✅ **Load Role & Status from SharedPreferences**
  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString("role");
      userStatus = prefs.getString("status");

      if (userRole == "vendor") {
        long = 0.45;
      } else if (userRole == "reseller") {
        long = 0.52;
      } else if (userRole == "pipilika") {
        long = 0.48; // 👈 Set this to whatever logic you want for pipilika
      } else {
        long = 0.55;
      }
    });

    print("🟢 User Role: $userRole, Status: $userStatus"); // Debugging
  }

  /// ✅ **Build Firestore Query Based on Category & Subcategory Selection**
  Query _buildProductQuery() {
    Query query = FirebaseFirestore.instance
        .collection('products')
        .where("status", isEqualTo: "accepted");

    if (widget.selectedCategoryId != null &&
        widget.selectedCategoryId!.isNotEmpty) {
      query = query.where("categoryId", isEqualTo: widget.selectedCategoryId);
    }

    if (widget.selectedSubcategoryId != null &&
        widget.selectedSubcategoryId!.isNotEmpty) {
      query = query.where(
        "subcategoryId",
        isEqualTo: widget.selectedSubcategoryId,
      );
    }

    return query;
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
        .collection(
          role == "reseller"
              ? "resellers"
              : role == "pipilika"
              ? "pipilikas"
              : "clients",
        )
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

  Future<String> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString("role");
    return role!;
  }

  Future<String> getClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clientId = prefs.getString("id");
    return clientId!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: _buildProductQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No trending products found."));
          }

          final products = snapshot.data!.docs;
          print("🟢 Fetched Products: ${products.length}"); // Debugging

          if (_isHovered.length != products.length) {
            _isHovered = List<bool>.filled(products.length, false);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (constraints.maxWidth > 800) {
                crossAxisCount = 4;
              } else {
                crossAxisCount = 2;
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Responsive columns
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  // childAspectRatio: long,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  var product = products[index];
                  String vendirid = product['vendorId'] ?? "No ID";
                  String productId = product.id;
                  String productName = product['name'] ?? "No Name";
                  // Prices
                  String customerPrice =
                      product['customerPrice']?.toString() ?? "0";
                  String resellerPrice =
                      product['resellerPrice']?.toString() ?? "0";
                  String vendorPrice = product['vendorPrice']?.toString() ?? "0";
                  String pipilikaPrice =
                      product['pipilikaPrice']?.toString() ?? "0";

                  // 🔹 Ensure main image exists
                  String productImage =
                      product['images']?['main'] ??
                      "assets/images/logo.png";

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  NewProductDescription(productId: productId),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(productImage),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          // 🔹 Product Details
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // ✅ **Show Prices Based on Role & Status**
                                if (userRole == "vendor" &&
                                    userStatus == "accepted") ...[
                                  Text(
                                    'Vendor: ${vendorPrice} Tk',
                                    style: _priceStyle(),
                                  ),
                                  Text(
                                    'Reseller: ${resellerPrice} Tk',
                                    style: _priceStyle(),
                                  ),
                                  Text(
                                    'Customer: ${customerPrice} Tk',
                                    style: _priceStyle(),
                                  ),
                                ] else if (userRole == "reseller" &&
                                    userStatus == "accepted") ...[
                                  Text(
                                    'Reseller: ${resellerPrice} Tk',
                                    style: _priceStyle(),
                                  ),
                                  Text(
                                    'Customer: ${customerPrice} Tk',
                                    style: _priceStyle(),
                                  ),
                                ] else if (userRole == "pipilika" &&
                                    userStatus == "accepted") ...[
                                  Text(
                                    'Pipirica: ${pipilikaPrice} Tk',
                                    style: _priceStyle(),
                                  ),
                                  Text(
                                    'Customer: ${customerPrice} Tk',
                                    style: _priceStyle(),
                                  ),
                                ] else ...[
                                  Text(
                                    'Price: ${customerPrice} Tk',
                                    style: _priceStyle(),
                                  ),
                                ],

                                const SizedBox(height: 5),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FutureBuilder(
                                      future: SharedPreferences.getInstance(),
                                      builder: (
                                        context,
                                        AsyncSnapshot<SharedPreferences>
                                        prefsSnapshot,
                                      ) {
                                        if (!prefsSnapshot.hasData) {
                                          return const CircularProgressIndicator(); // or empty button
                                        }

                                        final prefs = prefsSnapshot.data!;
                                        final String? clientId = prefs.getString(
                                          "id",
                                        );
                                        final String? role = prefs.getString(
                                          "role",
                                        );

                                        print(
                                          "🟢 Client ID: $clientId, Role: $role",
                                        );

                                        if (clientId == null || role == null) {
                                          return Container(
                                            height: 40,
                                            width: 70,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                5,
                                              ),
                                              color: Colors.orange,
                                            ),

                                            child: Center(
                                              child: const Text("Cart"),
                                            ),
                                          );
                                        }

                                        return StreamBuilder<DocumentSnapshot>(
                                          stream:
                                              FirebaseFirestore.instance
                                                  .collection(
                                                    role == "reseller"
                                                        ? "resellers"
                                                        : role == "pipilika"
                                                        ? "pipilikas"
                                                        : "clients",
                                                  )
                                                  .doc(clientId)
                                                  .collection("cart")
                                                  .doc(productId)
                                                  .snapshots(),
                                          builder: (context, snapshot) {
                                            bool isAdded =
                                                snapshot.data?.data() != null &&
                                                (snapshot.data!.data()
                                                        as Map<
                                                          String,
                                                          dynamic
                                                        >)["isAdded"] ==
                                                    true;

                                            return Container(
                                              height: 40,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(
                                                  5,
                                                ),
                                                color:
                                                    isAdded
                                                        ? Colors.grey
                                                        : Colors.orange,
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
                                                            productId: productId,
                                                            productName:
                                                                productName,
                                                            productImage:
                                                                productImage,
                                                            customerPrice:
                                                                double.tryParse(
                                                                  customerPrice,
                                                                ) ??
                                                                0.0,
                                                            resellerPrice:
                                                                double.tryParse(
                                                                  resellerPrice,
                                                                ) ??
                                                                0.0,
                                                            pipilikaPrice:
                                                                double.tryParse(
                                                                  pipilikaPrice,
                                                                ) ??
                                                                0.0,
                                                            vendorId: vendirid,
                                                          );
                                                        },
                                                child: Text(
                                                  isAdded ? "Added" : "Cart",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),

                                    // Container(
                                    //   height: 40,
                                    //   width: 60,
                                    //   decoration: BoxDecoration(
                                    //     borderRadius: BorderRadius.circular(5),
                                    //     color: Colors.blue,
                                    //   ),
                                    //   alignment: Alignment.center,
                                    //   child: const Text(
                                    //     "Buy",
                                    //     style: TextStyle(color: Colors.white),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// ✅ **Price Text Style**
  TextStyle _priceStyle() {
    return const TextStyle(
      fontSize: 16,
      color: Colors.teal,
      fontWeight: FontWeight.bold,
    );
  }
}
