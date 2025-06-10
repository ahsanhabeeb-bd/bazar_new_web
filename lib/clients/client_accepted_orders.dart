import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ClientAcceptedOrders extends StatefulWidget {
  const ClientAcceptedOrders({super.key});

  @override
  State<ClientAcceptedOrders> createState() => _ClientAcceptedOrdersState();
}

class _ClientAcceptedOrdersState extends State<ClientAcceptedOrders> {
  String? clientId;

  @override
  void initState() {
    super.initState();
    _loadClientId();
  }

  Future<void> _loadClientId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      clientId = prefs.getString("id");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (clientId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("orders")
              .where("clientId", isEqualTo: clientId)
              .where("status", isEqualTo: "accepted")
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        final acceptedOrders = snapshot.data?.docs ?? [];

        if (acceptedOrders.isEmpty) {
          return const Center(child: Text("No accepted orders found"));
        }

        return ListView.builder(
          itemCount: acceptedOrders.length,
          itemBuilder: (context, index) {
            final order = acceptedOrders[index];
            final data = order.data() as Map<String, dynamic>;
            final orderId = data["orderId"];
            final items = List<Map<String, dynamic>>.from(data["items"] ?? []);
            final timestamp = data["timestamp"] as Timestamp?;
            final formattedDate =
                timestamp != null
                    ? DateFormat('dd-MM-yyyy').format(timestamp.toDate())
                    : "Unknown date";

            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 2,
              child: ListTile(
                title: Text("Order ID: $orderId"),
                subtitle: Text("Total: ${data["total"]} Tk"),
                trailing: const Icon(Icons.visibility),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text("Order ID: $orderId"),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Status: ${data["status"]}"),
                              Text("Name: ${data["name"]}"),
                              Text("Phone: ${data["phone"]}"),
                              Text("Address: ${data["address"]}"),
                              Text("Total: ${data["total"]} Tk"),
                              Text("Date: $formattedDate"),
                              const SizedBox(height: 12),
                              const Text(
                                "Products:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...items.map((item) {
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          item["productImage"] ?? "",
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => const Icon(
                                                Icons.image_not_supported,
                                              ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item["productName"] ?? "",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text("Qty: ${item["quantity"]}"),
                                              Text("Price: ${item["price"]}"),
                                              Text(
                                                "Subtotal: ${item["subtotal"]}",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
