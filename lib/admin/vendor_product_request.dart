import 'package:bazar_new_web/providers/vendor_productR.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_carousel_slider/image_carousel_slider.dart';
import 'package:provider/provider.dart'; // Add this import

class Vendor_requestedProduct extends StatelessWidget {
  const Vendor_requestedProduct({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the provider using Provider.of<Vendor_ProductsR>(context)
    final vendorProductsR = Provider.of<Vendor_ProductsR>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Requested Products")),
      body:
          vendorProductsR.products.isEmpty
              ? const Center(child: Text("No products available"))
              : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: vendorProductsR.products.length,
                itemBuilder: (context, index) {
                  final product = vendorProductsR.products[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(5),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ImageCarouselSlider(
                                items: product['images'],
                                imageHeight: 300,
                                dotColor: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Product Name
                            Text(
                              product['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Product Price
                            Text(
                              "\$${product['price'].toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Product Description
                            Text(
                              product['description'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Edit Button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _showEditDialog(
                                      context,
                                      product,
                                      vendorProductsR,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Edit",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                ),
                                // Accept Button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    vendorProductsR.acceptProduct(
                                      product['id'],
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Accept",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                                // Decline Button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    vendorProductsR.declineProduct(
                                      product['id'],
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Decline",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  // Edit Dialog to modify product details
  void _showEditDialog(
    BuildContext context,
    Map<String, dynamic> product,
    Vendor_ProductsR vendorProductsR,
  ) {
    TextEditingController nameController = TextEditingController(
      text: product['name'],
    );
    TextEditingController descriptionController = TextEditingController(
      text: product['description'],
    );
    TextEditingController priceController = TextEditingController(
      text: product['price'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Edit Product"),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update the product data
                final updatedProduct = {
                  'id': product['id'],
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price':
                      double.tryParse(priceController.text) ?? product['price'],
                  'images': product['images'], // Keeping images unchanged
                };
                vendorProductsR.editProduct(product['id'], updatedProduct);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
