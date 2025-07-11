import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  String role = "";
  String clientId = "";
  bool isLoading = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> _showCheckoutDialog() async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection(
              role == "reseller"
                  ? "resellers"
                  : role == "pipilika"
                  ? "pipilikas"
                  : "clients",
            )
            .doc(clientId)
            .get();

    final userData = userDoc.data();
    if (userData == null) return;

    // Prefill user data into controllers
    nameController.text = userData["name"] ?? "";
    phoneController.text = userData["phone"] ?? "";
    addressController.text = userData["address"] ?? "";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Confirm Order"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Text("Total: ${total.toStringAsFixed(2)} Tk"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                // Updated values
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                final address = addressController.text.trim();

                await submitOrder(name: name, phone: phone, address: address);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitOrder({
    required String name,
    required String phone,
    required String address,
  }) async {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    final orderData = {
      "orderId": orderId,
      "clientId": clientId,
      "name": name,
      "phone": phone,
      "address": address,
      "status": "pending",
      "total": total,
      "timestamp": FieldValue.serverTimestamp(),
      "items":
          cartItems.map((item) {
            return {
              "productId": item["productId"],
              "productName": item["productName"],
              "productImage": item["productImage"],
              "quantity": item["quantity"],
              "price": getPrice(item),
              "subtotal": getPrice(item) * (item["quantity"] ?? 1),
              "mydecision": "pending",
              "vendorId": item["vendorId"] ?? "",
            };
          }).toList(),
    };

    // 🔥 Save to Firestore
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId)
        .set(orderData);

    // 🧹 Optional: Clear cart
    final cartRef = FirebaseFirestore.instance
        .collection(
          role == "reseller"
              ? "resellers"
              : role == "pipilika"
              ? "pipilikas"
              : "clients",
        )
        .doc(clientId)
        .collection("cart");

    final cartSnapshot = await cartRef.get();
    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }

    setState(() {
      cartItems.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Order submitted successfully!")),
    );
  }

  Future<void> loadCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    clientId = prefs.getString("id") ?? "";
    role = prefs.getString("role") ?? "";

    if (clientId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    final cartSnap =
        await FirebaseFirestore.instance
            .collection(
              role == "reseller"
                  ? "resellers"
                  : role == "pipilika"
                  ? "pipilikas"
                  : "clients",
            )
            .doc(clientId)
            .collection("cart")
            .get();

    print("🟡 Role $role");
    print("🟡 id $clientId");

    cartItems =
        cartSnap.docs.map((doc) {
          final data = doc.data();
          data["docId"] = doc.id;
          return data;
        }).toList();

    setState(() {
      isLoading = false;
    });
  }

  double getPrice(Map<String, dynamic> item) {
    switch (role) {
      case "reseller":
        return item["resellerPrice"]?.toDouble() ?? 0;
      case "pipilika":
        return item["pipilikaPrice"]?.toDouble() ?? 0;
      default:
        return item["customerPrice"]?.toDouble() ?? 0;
    }
  }

  double get total {
    return cartItems.fold(0, (sum, item) {
      return sum + getPrice(item) * (item["quantity"] ?? 1);
    });
  }

  Future<void> updateQuantity(int index, int change) async {
    final item = cartItems[index];
    int newQty = (item["quantity"] ?? 1) + change;
    if (newQty < 1) return;

    setState(() {
      item["quantity"] = newQty;
    });

    await FirebaseFirestore.instance
        .collection(
          role == "reseller"
              ? "resellers"
              : role == "pipilika"
              ? "pipilikas"
              : "clients",
        )
        .doc(clientId)
        .collection("cart")
        .doc(item["docId"])
        .update({"quantity": newQty});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty"))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (_, index) {
                        final item = cartItems[index];
                        final price = getPrice(item);
                        final qty = item["quantity"] ?? 1;
                        final subtotal = price * qty;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.network(
                                      item["productImage"] ?? "",
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.image_not_supported,
                                                size: 60,
                                              ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item["productName"] ?? "Item",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Price: ${price.toStringAsFixed(2)}",
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        const Text("Qty"),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed:
                                                  () =>
                                                      updateQuantity(index, -1),
                                            ),
                                            Text(qty.toString()),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed:
                                                  () =>
                                                      updateQuantity(index, 1),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection(
                                              role == "reseller"
                                                  ? "resellers"
                                                  : role == "pipilika"
                                                  ? "pipilikas"
                                                  : "clients",
                                            )
                                            .doc(clientId)
                                            .collection("cart")
                                            .doc(item["docId"])
                                            .delete();

                                        setState(() {
                                          cartItems.removeAt(index);
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        "Remove",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    Text(
                                      "Subtotal: ${subtotal.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showCheckoutDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[400], // A pleasant green
                            foregroundColor: Colors.white, // White text
                          ),
                          child: const Text("Buy Now"),
                        ),
                        Text(
                          "Total: ${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
