import 'package:flutter/material.dart';

class NetworkImageGrid extends StatelessWidget {
  final List<String> imageUrls = [
    "https://source.unsplash.com/random/800x600?sig=1",
    "https://source.unsplash.com/random/800x600?sig=2",
    "https://source.unsplash.com/random/800x600?sig=3",
    "https://source.unsplash.com/random/800x600?sig=4",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Adjust number of columns
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1, // Adjust aspect ratio if needed
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200], // Background color
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(),
                  ); // Show loader
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ); // Show error icon
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
