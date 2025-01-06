import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;  // A list of image URLs

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(

      options: CarouselOptions(
        height: 150.0,
        enlargeCenterPage: true,
        autoPlay: true, // Enable autoplay
        aspectRatio: 16/9, // Adjust the aspect ratio
        viewportFraction: 1, // Control the size of the images in the viewport
        autoPlayInterval: Duration(seconds: 10),
        autoPlayAnimationDuration: Duration(milliseconds: 200),
      ),
      items: imageUrls.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),

              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
