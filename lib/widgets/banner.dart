import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class banner extends StatelessWidget {
  const banner({super.key, required this.imageUrls1});

  final List<String> imageUrls1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double bannerWidth;
        if (constraints.maxWidth < 800) {
          // Mobile view
          bannerWidth = MediaQuery.of(context).size.width;
        } else {
          // Desktop view
          bannerWidth = MediaQuery.of(context).size.width * .45;
        }

        return SizedBox(
          width: bannerWidth,
          child: CarouselSlider(
            options: CarouselOptions(
              height: 400,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
            ),
            items: imageUrls1.map((imageUrl) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 300,
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
        );
      },
    );
  }
}
