import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Brand_Scroll extends StatefulWidget {
  const Brand_Scroll({super.key});

  @override
  State<Brand_Scroll> createState() => _Brand_ScrollState();
}

class _Brand_ScrollState extends State<Brand_Scroll> {
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  List<String> brands = []; // Stores fetched brand names
  final Map<int, bool> _hovering = {}; // Tracks hover state for each brand

  @override
  void initState() {
    super.initState();
    fetchBrands(); // Fetch brands from Firebase

    // Auto-scroll functionality
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_scrollController.hasClients) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        final currentPosition = _scrollController.offset;

        if (currentPosition < maxScrollExtent) {
          _scrollController.animateTo(
            currentPosition + 100, // Scrolls by 100 pixels
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(0); // Reset to the start
        }
      }
    });
  }

  // 🔹 Fetch Brands from Firebase Firestore
  Future<void> fetchBrands() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('brands').get();

      setState(() {
        brands =
            querySnapshot.docs
                .map((doc) => doc['name'].toString()) // Extract brand names
                .toList();

        // Initialize hover states
        for (var i = 0; i < brands.length; i++) {
          _hovering[i] = false;
        }
      });

      print("✅ Fetched Brands: $brands"); // Debugging Output
    } catch (e) {
      print("🚨 Error fetching brands: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      // padding: const EdgeInsets.symmetric(vertical: 10),
      child:
          brands.isEmpty
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loader if empty
              : ListView.builder(
                controller: _scrollController,
                itemCount: brands.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return MouseRegion(
                    onEnter: (_) => setState(() => _hovering[index] = true),
                    onExit: (_) => setState(() => _hovering[index] = false),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          brands[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                _hovering[index] ?? false
                                    ? Colors.black
                                    : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
