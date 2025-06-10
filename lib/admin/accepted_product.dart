// Your Product model

import 'package:bazar_new_web/providers/accepted_products_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_carousel_slider/image_carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

final AcceptedProductsProvider productsProvider = AcceptedProductsProvider();

class AcceptedProduct extends StatelessWidget {
  const AcceptedProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accepted Products")),
      body:
          productsProvider.products.isEmpty
              ? const Center(
                child: Text(
                  "No products available",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
              : Container(
                height: double.infinity,
                width: double.infinity,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: productsProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productsProvider.products[index];
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
                                  items:
                                      productsProvider
                                          .products[index]['images'],
                                  imageHeight: 205,
                                  dotColor: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Product Name
                              Text(
                                productsProvider.products[index]['name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Product Price
                              Text(
                                "\$${productsProvider.products[index]['price']}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Product Description
                              Text(
                                productsProvider.products[index]['description'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Decline Button
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          final product =
                                              productsProvider.products[index];
                                          return AlertDialog(
                                            title: Text(
                                              "Delete Category",
                                              style: GoogleFonts.poppins(
                                                color: Colors.green,
                                              ),
                                            ),
                                            content: Text(
                                              "Are you sure to delete?",
                                            ),
                                            actions: [
                                              TextButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                        Color
                                                      >(Colors.green),
                                                ),
                                                onPressed: () {
                                                  productsProvider
                                                      .removeproduct(product);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "Yes",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                        Color
                                                      >(Colors.green),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "No",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Remove",
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
              ),
    );
  }
}
