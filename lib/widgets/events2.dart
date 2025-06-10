import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class events2 extends StatelessWidget {
  const events2({
    super.key,
    required this.imageUrls4,
    required this.imageUrls5,
  });

  final List<String> imageUrls4;
  final List<String> imageUrls5;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // First Carousel
        Expanded(
          child: CarouselSlider(
            options: CarouselOptions(
              height: 100,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              viewportFraction: 1.0,
              enlargeCenterPage: false,
            ),
            items:
                imageUrls4.map((imageUrl) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
          ),
        ),

        SizedBox(width: 10), // Spacing between carousels
        // Second Carousel
        Expanded(
          child: CarouselSlider(
            options: CarouselOptions(
              height: 100,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 4),
              viewportFraction: 1.0,
              enlargeCenterPage: false,
            ),
            items:
                imageUrls5.map((imageUrl) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
