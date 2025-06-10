import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Myorder extends StatefulWidget {
  const Myorder({super.key});

  @override
  State<Myorder> createState() => _MyorderState();
}

class _MyorderState extends State<Myorder> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Orders"),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Accepted"),
              Tab(text: "Declined"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PendingOrderPage(),
            AcceptedOrderPage(),
            DeclinedOrderPage(),
            OrderHistoryPage(),
          ],
        ),
      ),
    );
  }
}

class PendingOrderPage extends StatefulWidget {
  const PendingOrderPage({super.key});

  @override
  State<PendingOrderPage> createState() => _PendingOrderPageState();
}

class _PendingOrderPageState extends State<PendingOrderPage> {
  String? vendorId;

  @override
  void initState() {
    super.initState();
    _loadVendorId();
  }

  Future<void> _loadVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      vendorId = prefs.getString("id");
    });
  }

  Future<void> updateDecision({
    required String orderDocId,
    required int itemIndex,
    required String newDecision,
  }) async {
    final orderRef = FirebaseFirestore.instance
        .collection("orders")
        .doc(orderDocId);
    final doc = await orderRef.get();

    if (doc.exists) {
      final data = doc.data()!;
      List items = List.from(data["items"]);

      // Update the selected item's decision
      items[itemIndex]["mydecision"] = newDecision;

      // Update items list in Firestore
      await orderRef.update({"items": items});

      // ✅ Check if all items are now accepted
      final allAccepted = items.every(
        (item) => item["mydecision"] == "accepted",
      );

      if (allAccepted) {
        await orderRef.update({"status": "accepted"});
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Marked as $newDecision")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (vendorId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("orders")
              .where("status", isEqualTo: "pending")
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final matchingOrders =
            snapshot.data!.docs.where((order) {
              final items = List<Map<String, dynamic>>.from(order["items"]);
              return items.any(
                (item) =>
                    item["vendorId"] == vendorId &&
                    item["mydecision"] == "pending",
              );
            }).toList();

        if (matchingOrders.isEmpty) {
          return const Center(child: Text("No pending items for you."));
        }

        return ListView.builder(
          itemCount: matchingOrders.length,
          itemBuilder: (context, index) {
            final order = matchingOrders[index];
            final data = order.data() as Map<String, dynamic>;
            final items = List<Map<String, dynamic>>.from(data["items"]);

            // ✅ Filter by vendorId and mydecision == pending
            final filteredItems =
                items
                    .asMap()
                    .entries
                    .where(
                      (entry) =>
                          entry.value["vendorId"] == vendorId &&
                          entry.value["mydecision"] == "pending",
                    )
                    .toList();

            final timestamp = data["timestamp"] as Timestamp?;
            final formattedDate =
                timestamp != null
                    ? DateFormat('dd-MM-yyyy').format(timestamp.toDate())
                    : "Unknown date";

            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 3,
              child: ExpansionTile(
                title: Text("Order ID: ${data["orderId"]}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Customer: ${data["name"]}"),
                    Text("Phone: ${data["phone"]}"),
                    Text("Address: ${data["address"]}"),
                    Text("Total: ${data["total"]} Tk"),
                    Text("Status: ${data["status"]}"),
                    Text("Date: $formattedDate"),
                  ],
                ),
                children:
                    filteredItems.map((entry) {
                      final item = entry.value;
                      final i = entry.key;

                      return Card(
                        color: Colors.grey.shade100,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                item["productImage"] ?? "",
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const Icon(Icons.image),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["productName"] ?? "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text("Qty: ${item["quantity"]}"),
                                    Text("Price: ${item["price"]}"),
                                    Text("Subtotal: ${item["subtotal"]}"),
                                    Text("My Decision: ${item["mydecision"]}"),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed:
                                              () => updateDecision(
                                                orderDocId: order.id,
                                                itemIndex: i,
                                                newDecision: "accepted",
                                              ),
                                          child: const Text("Accept"),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed:
                                              () => updateDecision(
                                                orderDocId: order.id,
                                                itemIndex: i,
                                                newDecision: "declined",
                                              ),
                                          child: const Text("Decline"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}

class AcceptedOrderPage extends StatefulWidget {
  const AcceptedOrderPage({super.key});

  @override
  State<AcceptedOrderPage> createState() => _AcceptedOrderPageState();
}

class _AcceptedOrderPageState extends State<AcceptedOrderPage> {
  String? vendorId;

  @override
  void initState() {
    super.initState();
    _loadVendorId();
  }

  Future<void> _loadVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      vendorId = prefs.getString("id");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (vendorId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("orders")
              .where("status", isEqualTo: "pending")
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final matchingOrders =
            snapshot.data!.docs.where((order) {
              final items = List<Map<String, dynamic>>.from(order["items"]);
              return items.any(
                (item) =>
                    item["vendorId"] == vendorId &&
                    item["mydecision"] == "accepted",
              );
            }).toList();

        if (matchingOrders.isEmpty) {
          return const Center(child: Text("No accepted items found."));
        }

        return ListView.builder(
          itemCount: matchingOrders.length,
          itemBuilder: (context, index) {
            final order = matchingOrders[index];
            final data = order.data() as Map<String, dynamic>;
            final items = List<Map<String, dynamic>>.from(data["items"]);

            final filteredItems =
                items
                    .where(
                      (item) =>
                          item["vendorId"] == vendorId &&
                          item["mydecision"] == "accepted",
                    )
                    .toList();
            final timestamp = data["timestamp"] as Timestamp?;
            final formattedDate =
                timestamp != null
                    ? DateFormat('dd-MM-yyyy').format(timestamp.toDate())
                    : "Unknown date";
            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 3,
              child: ExpansionTile(
                title: Text("Order ID: ${data["orderId"]}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Customer: ${data["name"]}"),
                    Text("Phone: ${data["phone"]}"),
                    Text("Address: ${data["address"]}"),
                    Text("Total: ${data["total"]} Tk"),
                    Text("Status: ${data["status"]}"),
                    Text("Date: $formattedDate"),
                  ],
                ),
                children:
                    filteredItems.map((item) {
                      return Card(
                        color: Colors.green.shade50,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                item["productImage"] ?? "",
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const Icon(Icons.image),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["productName"] ?? "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text("Qty: ${item["quantity"]}"),
                                    Text("Price: ${item["price"]}"),
                                    Text("Subtotal: ${item["subtotal"]}"),
                                    Text("My Decision: ${item["mydecision"]}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}

class DeclinedOrderPage extends StatefulWidget {
  const DeclinedOrderPage({super.key});

  @override
  State<DeclinedOrderPage> createState() => _DeclinedOrderPageState();
}

class _DeclinedOrderPageState extends State<DeclinedOrderPage> {
  String? vendorId;

  @override
  void initState() {
    super.initState();
    _loadVendorId();
  }

  Future<void> _loadVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      vendorId = prefs.getString("id");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (vendorId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("orders")
              .where("status", isEqualTo: "pending")
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final matchingOrders =
            snapshot.data!.docs.where((order) {
              final items = List<Map<String, dynamic>>.from(order["items"]);
              return items.any(
                (item) =>
                    item["vendorId"] == vendorId &&
                    item["mydecision"] == "declined",
              );
            }).toList();

        if (matchingOrders.isEmpty) {
          return const Center(child: Text("No declined items found."));
        }

        return ListView.builder(
          itemCount: matchingOrders.length,
          itemBuilder: (context, index) {
            final order = matchingOrders[index];
            final data = order.data() as Map<String, dynamic>;
            final items = List<Map<String, dynamic>>.from(data["items"]);

            final filteredItems =
                items
                    .where(
                      (item) =>
                          item["vendorId"] == vendorId &&
                          item["mydecision"] == "declined",
                    )
                    .toList();
            final timestamp = data["timestamp"] as Timestamp?;
            final formattedDate =
                timestamp != null
                    ? DateFormat('dd-MM-yyyy').format(timestamp.toDate())
                    : "Unknown date";

            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 3,
              child: ExpansionTile(
                title: Text("Order ID: ${data["orderId"]}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Customer: ${data["name"]}"),
                    Text("Phone: ${data["phone"]}"),
                    Text("Address: ${data["address"]}"),
                    Text("Total: ${data["total"]} Tk"),
                    Text("Status: ${data["status"]}"),
                    Text("Date: $formattedDate"),
                  ],
                ),
                children:
                    filteredItems.map((item) {
                      return Card(
                        color: Colors.red.shade50,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                item["productImage"] ?? "",
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const Icon(Icons.image),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["productName"] ?? "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text("Qty: ${item["quantity"]}"),
                                    Text("Price: ${item["price"]}"),
                                    Text("Subtotal: ${item["subtotal"]}"),
                                    Text("My Decision: ${item["mydecision"]}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String? vendorId;

  @override
  void initState() {
    super.initState();
    _loadVendorId();
  }

  Future<void> _loadVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      vendorId = prefs.getString("id");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (vendorId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("orders")
              .where("status", isEqualTo: "accepted")
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final matchingOrders =
            snapshot.data!.docs.where((order) {
              final items = List<Map<String, dynamic>>.from(order["items"]);
              return items.any((item) => item["vendorId"] == vendorId);
            }).toList();

        if (matchingOrders.isEmpty) {
          return const Center(child: Text("No order history found."));
        }

        return ListView.builder(
          itemCount: matchingOrders.length,
          itemBuilder: (context, index) {
            final order = matchingOrders[index];
            final data = order.data() as Map<String, dynamic>;
            final items = List<Map<String, dynamic>>.from(data["items"]);
            final timestamp = data["timestamp"] as Timestamp?;
            final formattedDate =
                timestamp != null
                    ? DateFormat('dd-MM-yyyy').format(timestamp.toDate())
                    : "Unknown date";

            final filteredItems =
                items.where((item) => item["vendorId"] == vendorId).toList();

            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 3,
              child: ExpansionTile(
                title: Text("Order ID: ${data["orderId"]}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Customer: ${data["name"]}"),
                    Text("Phone: ${data["phone"]}"),
                    Text("Address: ${data["address"]}"),
                    Text("Total: ${data["total"]} Tk"),
                    Text("Status: ${data["status"]}"),
                    Text("Date: $formattedDate"),
                  ],
                ),
                children:
                    filteredItems.map((item) {
                      return Card(
                        color: Colors.blue.shade50,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                item["productImage"] ?? "",
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const Icon(Icons.image),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["productName"] ?? "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text("Qty: ${item["quantity"]}"),
                                    Text("Price: ${item["price"]}"),
                                    Text("Subtotal: ${item["subtotal"]}"),
                                    Text("My Decision: ${item["mydecision"]}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
