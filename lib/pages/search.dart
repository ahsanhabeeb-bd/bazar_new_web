import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchProductDialog extends StatefulWidget {
  @override
  _SearchProductDialogState createState() => _SearchProductDialogState();
}

class _SearchProductDialogState extends State<SearchProductDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // ✅ FocusNode for auto keyboard
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus(); // ✅ Opens keyboard automatically
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// ✅ Search products by name
  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .where("status", isEqualTo: "accepted")
              .get(); // 🔹 Get all accepted products

      final lowerQuery = query.toLowerCase(); // 🔹 Convert query to lowercase

      List<Map<String, dynamic>> filteredResults = [];

      for (var doc in snapshot.docs) {
        var product = doc.data() as Map<String, dynamic>;

        // Ensure name is available
        String productName = (product['name'] ?? '').toString().toLowerCase();

        if (productName.contains(lowerQuery)) {
          filteredResults.add({
            "id": doc.id,
            "name": product["name"],
            "image": product["images"]?["main"] ?? "",
          });
        }
      }

      setState(() {
        _searchResults = filteredResults;
      });

      print("🔍 Search results: ${_searchResults.length} products found");
    } catch (e) {
      print("❌ Error searching products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.infinity,
        height: 500, // ✅ Increased dialog height
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Search Product",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              focusNode: _focusNode, // ✅ Auto-focus here
              decoration: InputDecoration(
                hintText: "Search by product name...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (query) => _searchProducts(query),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  _searchResults.isEmpty
                      ? const Center(child: Text("No products found"))
                      : Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final product = _searchResults[index];
                            return ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child:
                                      product["image"].isNotEmpty
                                          ? Image.network(
                                            product["image"],
                                            fit: BoxFit.cover,
                                          )
                                          : const Icon(
                                            Icons.image_not_supported,
                                            size: 30,
                                          ),
                                ),
                              ),
                              title: Text(product["name"]),
                              onTap: () {
                                Navigator.pop(context, product["id"]);
                              },
                            );
                          },
                        ),
                      ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
