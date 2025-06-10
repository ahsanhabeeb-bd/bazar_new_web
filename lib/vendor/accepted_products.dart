import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AcceptedProducts extends StatelessWidget {
  final String vendorId;

  const AcceptedProducts({
    super.key,
    required this.vendorId,
  }); // Accept vendorId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection("products")
                .where("status", isEqualTo: "accepted")
                .where("vendorId", isEqualTo: vendorId) // Filter by vendor ID
                .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No accepted products found."));
          }

          return ListView(
            children:
                snapshot.data!.docs.map((doc) {
                  return Card(
                    margin: EdgeInsets.all(10),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show Three Images in a Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildProductImage(doc["images"]["main"]),
                              _buildProductImage(doc["images"]["image2"]),
                              _buildProductImage(doc["images"]["image3"]),
                            ],
                          ),

                          SizedBox(height: 8),

                          // Product Name
                          Text(
                            doc["name"],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          // Prices
                          Text(
                            "Vendor Price: \$${doc["vendorPrice"]}",
                            style: TextStyle(fontSize: 14, color: Colors.green),
                          ),
                          Text(
                            "Reseller Price: \$${doc["resellerPrice"] ?? 'N/A'}",
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                          Text(
                            "Customer Price: \$${doc["customerPrice"] ?? 'N/A'}",
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          ),

                          SizedBox(height: 5),

                          // Product Details
                          Text(
                            doc["details"],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 10),

                          // Status
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              "ACCEPTED",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  /// ✅ **Helper function to display product images in a row**
  Widget _buildProductImage(String? imageUrl) {
    return Container(
      width: 90, // Adjust image size
      height: 90,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child:
          imageUrl != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              )
              : Icon(Icons.image, size: 40, color: Colors.grey),
    );
  }
}
